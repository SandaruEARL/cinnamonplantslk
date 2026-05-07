import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../data/services/cloudinary/cloudinary_service.dart';
import '../../../../data/services/firebase/storage_service.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<Map<String, dynamic>>> getUserChats(String userId);
  Stream<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(MessageModel message, String chatId);
  Future<void> markAsRead(String chatId, String userId);
  String getChatId(String userId1, String userId2, String adId); // ✅ adId added
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
  String getChatId(String userId1, String userId2, String adId) { // ✅ fixed
    final ids = [userId1, userId2]..sort();
    return '${ids.join('_')}_$adId';
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
        'adId': message.adId,
        'adTitle': message.adTitle,
        'adImageUrl': message.adImageUrl,
        'adPrice': message.adPrice,
      }, SetOptions(merge: true));

      await chatRef.collection('messages').add({
        ...message.toFirestore(),
        'timestamp': FieldValue.serverTimestamp(),
        'localId': message.localId,
      });

      await _sendChatNotification(
        senderId: message.senderId,
        receiverId: message.receiverId,
        text: message.text ?? '',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> _sendChatNotification({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final senderDoc =
      await _firestore.collection('users').doc(senderId).get();
      final senderName = senderDoc.data()?['name'] as String? ?? 'Someone';

      final secret = dotenv.env['NOTIFY_SECRET'] ?? '';
      final url = dotenv.env['NOTIFY_URL'] ?? '';

      if (url.isEmpty) return;

      await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $secret',
        },
        body: jsonEncode({
          'userId': receiverId,
          'type': 'chat',
          'title': senderName,
          'body': text.length > 50 ? '${text.substring(0, 50)}...' : text,
        }),
      );
    } catch (_) {
      // Fail silently — message is already saved
    }
  }

  @override
  Future<void> deleteChat(String chatId, String userId) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) return;

      final hiddenFor =
          (chatDoc.data()?['hiddenFor'] as List?)?.cast<String>() ?? [];
      final participants =
          (chatDoc.data()?['participants'] as List?)?.cast<String>() ?? [];

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

      final updatedHiddenFor = {...hiddenFor, userId};
      final allHidden =
      participants.every((id) => updatedHiddenFor.contains(id));

      if (allHidden) {
        final allMessages = await chatRef.collection('messages').get();
        final deleteBatch = _firestore.batch();
        for (final doc in allMessages.docs) {
          deleteBatch.delete(doc.reference);
        }
        deleteBatch.delete(chatRef);
        await deleteBatch.commit();
      } else {
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
  Future<void> deleteMessageForMe(
      String chatId, String messageId, String userId) async {
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
  Future<void> deleteMessageForEveryone(
      String chatId, String messageId) async {
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

      final messages = await chatRef
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('status', isNotEqualTo: 'read')
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.update(doc.reference, {'status': 'read'});
      }
      batch.update(chatRef, {
        'readBy': FieldValue.arrayUnion([userId]),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}