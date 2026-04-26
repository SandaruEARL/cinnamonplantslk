import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/marketplace_repository.dart';

class SubmitAdEditParams {
  final String adId;
  final Map<String, dynamic> editData;

  const SubmitAdEditParams({
    required this.adId,
    required this.editData,
  });
}

class SubmitAdEdit {
  final MarketplaceRepository repository;
  const SubmitAdEdit(this.repository);

  Future<Either<Failure, void>> call(SubmitAdEditParams params) {
    return repository.submitAdEdit(params.adId, params.editData);
  }
}