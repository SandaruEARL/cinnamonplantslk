class ChatEntity {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSender;
  final DateTime lastMessageTime;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final bool isVerified;

  bool get isUnread => true; // resolved in BLoC against current user

  const ChatEntity({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    this.isVerified = false,
  });
}