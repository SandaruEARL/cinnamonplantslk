import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

class DeleteChat extends UseCase<void, DeleteChatParams> {
  final ChatRepository repository;
  DeleteChat(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteChatParams params) {
    return repository.deleteChat(params.chatId, params.userId);
  }
}

class DeleteChatParams {
  final String chatId;
  final String userId;
  const DeleteChatParams({required this.chatId, required this.userId});
}