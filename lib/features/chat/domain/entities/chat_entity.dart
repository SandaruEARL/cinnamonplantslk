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
  final List<String> readBy;
  final String adId;
  final String adTitle;
  final String? adImageUrl;
  final double adPrice;

  bool isUnreadFor(String userId) =>
      lastMessageSender != userId && !readBy.contains(userId);

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
    this.readBy = const [],
    required this.adId,
    required this.adTitle,
    this.adImageUrl,
    required this.adPrice,
  });
}