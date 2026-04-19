import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read }

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final MessageStatus status;
  final List<String> deletedFor;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.deletedFor = const [],
  });

  @override
  List<Object?> get props => [id, senderId, receiverId, timestamp];
}