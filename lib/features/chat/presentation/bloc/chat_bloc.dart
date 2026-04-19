import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/block_user.dart';
import '../../domain/usecases/delete_message.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/get_user_chats.dart';
import '../../domain/usecases/mark_as_read.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetUserChats getUserChats;
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final SendImageMessage sendImageMessage;
  final MarkAsRead markAsRead;
  final DeleteMessageForMe deleteMessageForMe;
  final DeleteMessageForEveryone deleteMessageForEveryone;
  final BlockUser blockUser;
  final UnblockUser unblockUser;

  ChatBloc({
    required this.getUserChats,
    required this.getMessages,
    required this.sendMessage,
    required this.sendImageMessage,
    required this.markAsRead,
    required this.deleteMessageForMe,
    required this.deleteMessageForEveryone,
    required this.blockUser,
    required this.unblockUser

  }) : super(const ChatInitial()) {
    on<ChatListLoadRequested>(_onListLoadRequested);
    on<ChatMessagesLoadRequested>(_onMessagesLoadRequested);
    on<ChatMessageSendRequested>(_onMessageSendRequested);
    on<ChatImageSendRequested>(_onImageSendRequested);
    on<ChatMarkAsReadRequested>(_onMarkAsReadRequested);
    on<ChatMessageDeleteForMeRequested>(_onDeleteForMeRequested);
    on<ChatMessageDeleteForEveryoneRequested>(_onDeleteForEveryoneRequested);
    on<ChatUserBlockRequested>(_onBlockRequested);
    on<ChatUserUnblockRequested>(_onUnblockRequested);
  }

  Future<void> _onListLoadRequested(
      ChatListLoadRequested event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());
    await emit.forEach(
      getUserChats(event.userId),
      onData: (result) => result.fold(
            (failure) => ChatError(failure.message),
            (chats) => ChatListLoaded(
          chats: chats,
          currentUserId: event.userId,
        ),
      ),
    );
  }

  Future<void> _onBlockRequested(
      ChatUserBlockRequested event,
      Emitter<ChatState> emit,
      ) async {
    final result = await blockUser(BlockUserParams(
      currentUserId: event.currentUserId,
      targetUserId: event.targetUserId,
    ));
    result.fold(
          (failure) => emit(ChatError(failure.message)),
          (_) => emit(const ChatUserBlocked()),
    );
  }

  Future<void> _onUnblockRequested(
      ChatUserUnblockRequested event,
      Emitter<ChatState> emit,
      ) async {
    final result = await unblockUser(BlockUserParams(
      currentUserId: event.currentUserId,
      targetUserId: event.targetUserId,
    ));
    result.fold(
          (failure) => emit(ChatError(failure.message)),
          (_) => emit(const ChatUserUnblocked()),
    );
  }

  Future<void> _onDeleteForMeRequested(
      ChatMessageDeleteForMeRequested event,
      Emitter<ChatState> emit,
      ) async {
    final result = await deleteMessageForMe(
      DeleteMessageForMeParams(
        chatId: event.chatId,
        messageId: event.messageId,
        userId: event.userId,
      ),
    );
    result.fold(
          (failure) => emit(ChatError(failure.message)),
          (_) => null, // stream updates UI automatically
    );
  }

  Future<void> _onDeleteForEveryoneRequested(
      ChatMessageDeleteForEveryoneRequested event,
      Emitter<ChatState> emit,
      ) async {
    final result = await deleteMessageForEveryone(
      DeleteMessageForEveryoneParams(
        chatId: event.chatId,
        messageId: event.messageId,
      ),
    );
    result.fold(
          (failure) => emit(ChatError(failure.message)),
          (_) => null,
    );
  }

  Future<void> _onMessagesLoadRequested(
      ChatMessagesLoadRequested event,
      Emitter<ChatState> emit,
      ) async {
    emit(const ChatLoading());
    await emit.forEach(
      getMessages(GetMessagesParams(
        currentUserId: event.currentUserId,
        otherUserId: event.otherUserId,
      )),
      onData: (result) => result.fold(
            (failure) => ChatError(failure.message),
            (messages) => ChatMessagesLoaded(messages),
      ),
    );
  }

  Future<void> _onMessageSendRequested(
      ChatMessageSendRequested event,
      Emitter<ChatState> emit,
      ) async {
    // Don't emit ChatSending — it kills the messages stream
    final result = await sendMessage(SendMessageParams(
      senderId: event.senderId,
      receiverId: event.receiverId,
      text: event.text,
    ));
    result.fold(
          (failure) => emit(ChatError(failure.message)),
          (_) => null, // stream from _onMessagesLoadRequested updates UI
    );
  }

  Future<void> _onImageSendRequested(
      ChatImageSendRequested event,
      Emitter<ChatState> emit,
      ) async {
    // Don't emit ChatSending
    final result = await sendImageMessage(SendImageParams(
      senderId: event.senderId,
      receiverId: event.receiverId,
      chatId: event.chatId,
      image: event.image,
    ));
    result.fold(
          (failure) => emit(ChatError(failure.message)),
          (_) => null,
    );
  }

  Future<void> _onMarkAsReadRequested(
      ChatMarkAsReadRequested event,
      Emitter<ChatState> emit,
      ) async {
    await markAsRead(
      MarkAsReadParams(chatId: event.chatId, userId: event.userId),
    );
  }
}