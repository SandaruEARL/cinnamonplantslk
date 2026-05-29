import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/chat_repository.dart';

class BlockUser implements UseCase<void, BlockUserParams> {
  final ChatRepository repository;
  BlockUser(this.repository);

  @override
  Future<Either<Failure, void>> call(BlockUserParams params) {
    return repository.blockUser(params.currentUserId, params.targetUserId);
  }
}

class BlockUserParams {
  final String currentUserId;
  final String targetUserId;
  const BlockUserParams({required this.currentUserId, required this.targetUserId});
}

class UnblockUser implements UseCase<void, BlockUserParams> {
  final ChatRepository repository;
  UnblockUser(this.repository);

  @override
  Future<Either<Failure, void>> call(BlockUserParams params) {
    return repository.unblockUser(params.currentUserId, params.targetUserId);
  }
}