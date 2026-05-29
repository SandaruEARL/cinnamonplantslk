import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

class MarkAsRead extends UseCase<void, MarkAsReadParams> {
  final ChatRepository repository;
  MarkAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) {
    return repository.markAsRead(params.chatId, params.userId);
  }
}

class MarkAsReadParams {
  final String chatId;
  final String userId;
  const MarkAsReadParams({required this.chatId, required this.userId});
}