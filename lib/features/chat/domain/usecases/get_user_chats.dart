import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetUserChats {
  final ChatRepository repository;
  GetUserChats(this.repository);

  Stream<Either<Failure, List<ChatEntity>>> call(String userId) {
    return repository.getUserChats(userId);
  }
}