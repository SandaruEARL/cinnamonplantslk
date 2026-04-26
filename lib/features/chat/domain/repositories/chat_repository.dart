import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, void>> deleteMessageForMe(String chatId, String messageId, String userId);
  Future<Either<Failure, void>> deleteMessageForEveryone(String chatId, String messageId);
  Stream<Either<Failure, List<ChatEntity>>> getUserChats(String userId);
  Future<Either<Failure, void>> blockUser(String currentUserId, String targetUserId);
  Future<Either<Failure, void>> unblockUser(String currentUserId, String targetUserId);
  Future<Either<Failure, void>> deleteChat(String chatId, String userId);

  Stream<Either<Failure, List<MessageEntity>>> getMessages(
      String currentUserId,
      String otherUserId,
      );

  Future<Either<Failure, void>> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    String? imageUrl,
  });


  Future<Either<Failure, String>> uploadChatImage({
    required String chatId,
    required File image,
    void Function(double)? onProgress,
  });

  Future<Either<Failure, void>> markAsRead(
      String chatId,
      String userId,
      );

  String getChatId(String userId1, String userId2);
}