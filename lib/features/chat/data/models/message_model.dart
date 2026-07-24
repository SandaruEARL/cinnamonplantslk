import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  final String adId;
  final String adTitle;
  final String? adImageUrl;
  final double adPrice;

  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.text,
    required super.localId,
    required super.deletedFor,
    super.imageUrl,
    required super.timestamp,
    super.status,
    required this.adId,
    required this.adTitle,
    this.adImageUrl,
    required this.adPrice,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['timestamp'];
    final timestamp = ts != null ? (ts as Timestamp).toDate() : DateTime.now();

    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      localId: data['localId'] ?? '',
      timestamp: timestamp,
      status: MessageStatus.values.firstWhere(
            (s) => s.name == (data['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      deletedFor: List<String>.from(data['deletedFor'] ?? []),
      adId: data['adId'] ?? '',
      adTitle: data['adTitle'] ?? '',
      adImageUrl: data['adImageUrl'],
      adPrice: (data['adPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'text': text,
    'imageUrl': imageUrl,
    'localId': localId,
    'timestamp': Timestamp.fromDate(timestamp),
    'status': status.name,
    'deletedFor': deletedFor,
    'adId': adId,
    'adTitle': adTitle,
    'adImageUrl': adImageUrl,
    'adPrice': adPrice,
  };
}