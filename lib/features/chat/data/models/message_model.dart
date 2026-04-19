import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.text,
    required super.deletedFor,
    super.imageUrl,
    required super.timestamp,
    super.status,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: MessageStatus.values.firstWhere(
            (s) => s.name == (data['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      deletedFor: List<String>.from(data['deletedFor'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'text': text,
    'imageUrl': imageUrl,
    'timestamp': Timestamp.fromDate(timestamp),
    'status': status.name,
    'deletedFor': deletedFor,
  };
}