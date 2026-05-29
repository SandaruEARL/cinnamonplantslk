import 'dart:io';

abstract class ChatEvent {
  const ChatEvent();
}

class ChatListLoadRequested extends ChatEvent {
  final String userId;
  const ChatListLoadRequested(this.userId);
}

class ChatMessagesLoadRequested extends ChatEvent {
  final String currentUserId;
  final String otherUserId;
  final String adId;
  const ChatMessagesLoadRequested({
    required this.currentUserId,
    required this.otherUserId,
    required this.adId,
  });
}

class ChatMessageSendRequested extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String text;
  final String localId;
  final String adId;
  final String adTitle;
  final String? adImageUrl;
  final double adPrice;

  const ChatMessageSendRequested({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.localId,
    required this.adId,
    required this.adTitle,
    this.adImageUrl,
    required this.adPrice,
  });
}

class ChatImageSendRequested extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String chatId;
  final String pendingId;
  final File image;
  final String adId;
  final String adTitle;
  final String? adImageUrl;
  final double adPrice;

  const ChatImageSendRequested({
    required this.senderId,
    required this.pendingId,
    required this.receiverId,
    required this.chatId,
    required this.image,
    required this.adId,
    required this.adTitle,
    this.adImageUrl,
    required this.adPrice,
  });
}

class ChatMarkAsReadRequested extends ChatEvent {
  final String chatId;
  final String userId;
  const ChatMarkAsReadRequested({
    required this.chatId,
    required this.userId,
  });
}

class ChatMessageDeleteForMeRequested extends ChatEvent {
  final String chatId;
  final String messageId;
  final String userId;
  const ChatMessageDeleteForMeRequested({
    required this.chatId,
    required this.messageId,
    required this.userId,
  });
}

class ChatMessageDeleteForEveryoneRequested extends ChatEvent {
  final String chatId;
  final String messageId;
  final String senderId;
  const ChatMessageDeleteForEveryoneRequested({
    required this.chatId,
    required this.messageId,
    required this.senderId,
  });
}

class ChatUserBlockRequested extends ChatEvent {
  final String currentUserId;
  final String targetUserId;
  const ChatUserBlockRequested({
    required this.currentUserId,
    required this.targetUserId,
  });
}

class ChatUserUnblockRequested extends ChatEvent {
  final String currentUserId;
  final String targetUserId;
  const ChatUserUnblockRequested({
    required this.currentUserId,
    required this.targetUserId,
  });
}

class ChatDeleteRequested extends ChatEvent {
  final String chatId;
  final String userId;
  const ChatDeleteRequested({
    required this.chatId,
    required this.userId,
  });
}