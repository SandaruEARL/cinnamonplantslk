import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatListLoaded extends ChatState {
  final List<ChatEntity> chats;
  final String currentUserId;
  const ChatListLoaded({required this.chats, required this.currentUserId});
}

class ChatMessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  const ChatMessagesLoaded(this.messages);
}

class ChatSending extends ChatState {
  const ChatSending();
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}

class ChatMessageDeleted extends ChatState {
  const ChatMessageDeleted();
}

class ChatUserBlocked extends ChatState {
  const ChatUserBlocked();
}

class ChatUserUnblocked extends ChatState {
  const ChatUserUnblocked();
}

class ChatImageUploadProgress extends ChatState {
  final String pendingId;
  final double progress;
  const ChatImageUploadProgress({
    required this.pendingId,
    required this.progress,
  });
}

class ChatImageSent extends ChatState {
  final String pendingId;
  const ChatImageSent({required this.pendingId});
}

class ChatDeleted extends ChatState {
  const ChatDeleted();
}