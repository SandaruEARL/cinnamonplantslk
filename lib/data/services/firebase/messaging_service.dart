import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/constants.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String?  imageUrl;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this. imageUrl,
    required this. timestamp,
    this.isRead = false,
  });

  factory Message. fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ??  false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get chat ID between two users
  String getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2].. sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Send message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final chatId = getChatId(senderId, receiverId);
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );

      // Add message
      await _firestore
          .collection(AppConstants.chatsCollection)
          . doc(chatId)
          .collection(AppConstants.messagesCollection)
          . doc(message.id)
          .set(message.toJson());

      // Update chat metadata
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .set({
        'participants': [senderId, receiverId],
        'lastMessage': text,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastMessageSender': senderId,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String userId1, String userId2) {
    try {
      final chatId = getChatId(userId1, userId2);

      return _firestore
          . collection(AppConstants.chatsCollection)
          . doc(chatId)
          .collection(AppConstants.messagesCollection)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc. data();
          data['id'] = doc.id;
          return Message.fromJson(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  // Get user chats
  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    try {
      return _firestore
          .collection(AppConstants.chatsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          . map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc. data();
          data['chatId'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      final messages = await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  // Get unread count
  Stream<int> getUnreadCount(String userId) {
    try {
      return _firestore
          .collectionGroup(AppConstants.messagesCollection)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}