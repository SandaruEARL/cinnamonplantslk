import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../data/services/cloudinary/cloudinary_service.dart';
import '../../../../data/services/firebase/storage_service.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<Map<String, dynamic>>> getUserChats(String userId);
  Stream<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(MessageModel message, String chatId);
  Future<void> markAsRead(String chatId, String userId);
  String getChatId(String userId1, String userId2);
  Future<void> deleteMessageForMe(String chatId, String messageId, String userId);
  Future<void> deleteMessageForEveryone(String chatId, String messageId);
  Future<void> blockUser(String currentUserId, String targetUserId);
  Future<void> unblockUser(String currentUserId, String targetUserId);
  Future<String> uploadChatImage(String chatId, File image, {void Function(double)? onProgress});
  Future<void> deleteChat(String chatId, String userId);

}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final StorageService _storage;
  final CloudinaryService _cloudinary = CloudinaryService();

  ChatRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required StorageService storage,
  })  : _firestore = firestore,
        _storage = storage;

  @override
  String getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  @override
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    try {
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((doc) {
        final data = doc.data();
        data['chatId'] = doc.id;
        return data;
      }).toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteChat(String chatId, String userId) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) return;

      final hiddenFor = (chatDoc.data()?['hiddenFor'] as List?)
          ?.cast<String>() ?? [];
      final participants = (chatDoc.data()?['participants'] as List?)
          ?.cast<String>() ?? [];

      // Mark all messages deletedFor this user
      final messages = await chatRef.collection('messages').get();
      if (messages.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in messages.docs) {
          batch.update(doc.reference, {
            'deletedFor': FieldValue.arrayUnion([userId]),
          });
        }
        await batch.commit();
      }

      // Check if other user already deleted
      final updatedHiddenFor = {...hiddenFor, userId};
      final allHidden = participants.every((id) => updatedHiddenFor.contains(id));

      if (allHidden) {
        // Both deleted — wipe everything
        final allMessages = await chatRef.collection('messages').get();
        final deleteBatch = _firestore.batch();
        for (final doc in allMessages.docs) {
          deleteBatch.delete(doc.reference);
        }
        deleteBatch.delete(chatRef);
        await deleteBatch.commit();
      } else {
        // Just hide for this user — participants stays intact
        await chatRef.update({
          'hiddenFor': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([targetUserId]),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([targetUserId]),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }


  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snap) =>
          snap.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteMessageForMe(String chatId, String messageId, String userId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'deletedFor': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteMessageForEveryone(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendMessage(MessageModel message, String chatId) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);

      await chatRef.set({
        'participants': ([message.senderId, message.receiverId]..sort()),
        'lastMessage': message.text ?? '',
        'lastMessageSender': message.senderId,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'readBy': [message.senderId],
        'hiddenFor': [],
      }, SetOptions(merge: true));

      await chatRef.collection('messages').add(message.toFirestore());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadChatImage(
      String chatId,
      File imageFile, {
        void Function(double)? onProgress,
      }) async {
    try {
      return await _cloudinary.uploadChatImage(
        imageFile,
        chatId,
        onProgress: onProgress,
      );
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);

      // Mark individual messages as read
      final messages = await chatRef
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('status', isNotEqualTo: 'read')
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.update(doc.reference, {'status': 'read'});
      }

      // also update readBy on the chat doc so tile updates immediately
      batch.update(chatRef, {
        'readBy': FieldValue.arrayUnion([userId]),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}