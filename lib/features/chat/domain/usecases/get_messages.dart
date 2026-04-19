import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;
  GetMessages(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(
      GetMessagesParams params,
      ) {
    return repository.getMessages(
      params.currentUserId,
      params.otherUserId,
    );
  }
}

class GetMessagesParams {
  final String currentUserId;
  final String otherUserId;
  const GetMessagesParams({
    required this.currentUserId,
    required this.otherUserId,
  });
}