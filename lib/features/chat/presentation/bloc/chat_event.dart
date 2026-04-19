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
  const ChatMessagesLoadRequested({
    required this.currentUserId,
    required this.otherUserId,
  });
}

class ChatMessageSendRequested extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String text;
  const ChatMessageSendRequested({
    required this.senderId,
    required this.receiverId,
    required this.text,
  });
}

class ChatImageSendRequested extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String chatId;
  final File image;
  const ChatImageSendRequested({
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    required this.image,
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