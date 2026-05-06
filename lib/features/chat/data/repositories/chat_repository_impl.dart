import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../data/services/firebase/auth_service.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final AuthService authService; // only for fetching other user's profile

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.authService,
  });

  @override
  String getChatId(String userId1, String userId2) {
    return remoteDataSource.getChatId(userId1, userId2);
  }

  @override
  Stream<Either<Failure, List<ChatEntity>>> getUserChats(String userId) {
    try {
      return remoteDataSource.getUserChats(userId).asyncMap((chats) async {
        final validChats = chats.where((chat) {
          final participants =
              (chat['participants'] as List?)?.cast<String>() ?? [];
          final hiddenFor =
              (chat['hiddenFor'] as List?)?.cast<String>() ?? [];
          return participants.isNotEmpty &&
              !hiddenFor.contains(userId) &&
              chat['lastMessageTime'] != null;
        }).toList();

        final entities = <ChatEntity>[];
        for (final chat in validChats) {
          final participants =
          (chat['participants'] as List).cast<String>();
          final otherUserId = participants.firstWhere(
                (id) => id != userId,
            orElse: () => '',
          );
          if (otherUserId.isEmpty) continue;
          try {
            final otherUser = await authService.getUserData(otherUserId);
            if (otherUser == null) continue;
            entities.add(ChatEntity(
              chatId: chat['chatId'] as String,
              participants: participants,
              lastMessage: chat['lastMessage'] as String? ?? '',
              lastMessageSender: chat['lastMessageSender'] as String? ?? '',
              lastMessageTime: chat['lastMessageTime'] is Timestamp
                  ? (chat['lastMessageTime'] as Timestamp).toDate()
                  : DateTime.tryParse(chat['lastMessageTime'] as String? ?? '') ?? DateTime.now(),
              otherUserId: otherUserId,
              otherUserName: otherUser['name'] as String? ?? '',
              otherUserImage: otherUser['profilePicUrl'] as String?,
              isVerified: otherUser['isVerified'] as bool? ?? false,
              readBy: (chat['readBy'] as List?)?.cast<String>() ?? [],
            ));
          } catch (_) {
            continue;
          }
        }
        return Right<Failure, List<ChatEntity>>(entities);
      });
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessageForMe(String chatId, String messageId, String userId) async {
    try {
      await remoteDataSource.deleteMessageForMe(chatId, messageId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessageForEveryone(String chatId, String messageId) async {
    try {
      await remoteDataSource.deleteMessageForEveryone(chatId, messageId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }


  @override
  Future<Either<Failure, void>> blockUser(String currentUserId, String targetUserId) async {
    try {
      await remoteDataSource.blockUser(currentUserId, targetUserId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser(String currentUserId, String targetUserId) async {
    try {
      await remoteDataSource.unblockUser(currentUserId, targetUserId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(
      String currentUserId,
      String otherUserId,
      ) {
    try {
      final chatId = getChatId(currentUserId, otherUserId);
      return remoteDataSource
          .getMessages(chatId)
          .map((messages) => Right(messages));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String senderId,
    required String receiverId,
    String? localId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final chatId = getChatId(senderId, receiverId);
      final message = MessageModel(
        id: '',
        senderId: senderId,
        receiverId: receiverId,
        text: text,
          localId: localId ?? '',
        imageUrl: imageUrl,
          deletedFor: const [],
        timestamp: DateTime.now(),
          status: MessageStatus.sent
      );
      await remoteDataSource.sendMessage(message, chatId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }


  @override
  Future<Either<Failure, String>> uploadChatImage({
    required String chatId,
    required File image,
    void Function(double)? onProgress,
  }) async {
    try {
      final url = await remoteDataSource.uploadChatImage(
        chatId,
        image,
        onProgress: onProgress,
      );
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String chatId, String userId) async {
    try {
      await remoteDataSource.deleteChat(chatId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(
      String chatId,
      String userId,
      ) async {
    try {
      await remoteDataSource.markAsRead(chatId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}