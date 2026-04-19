import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteMessageForMe implements UseCase<void, DeleteMessageForMeParams> {
  final ChatRepository repository;
  DeleteMessageForMe(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMessageForMeParams params) {
    return repository.deleteMessageForMe(params.chatId, params.messageId, params.userId);
  }
}

class DeleteMessageForMeParams {
  final String chatId;
  final String messageId;
  final String userId;
  const DeleteMessageForMeParams({required this.chatId, required this.messageId, required this.userId});
}

class DeleteMessageForEveryone implements UseCase<void, DeleteMessageForEveryoneParams> {
  final ChatRepository repository;
  DeleteMessageForEveryone(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMessageForEveryoneParams params) {
    return repository.deleteMessageForEveryone(params.chatId, params.messageId);
  }
}

class DeleteMessageForEveryoneParams {
  final String chatId;
  final String messageId;
  const DeleteMessageForEveryoneParams({required this.chatId, required this.messageId});
}