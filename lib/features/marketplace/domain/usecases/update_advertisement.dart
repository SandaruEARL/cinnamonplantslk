import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/marketplace_repository.dart';

class UpdateAdvertisement {
  final MarketplaceRepository repository;
  UpdateAdvertisement(this.repository);

  Future<Either<Failure, void>> call(UpdateAdvertisementParams params) =>
      repository.updateAdvertisement(params.adId, params.data);
}

class UpdateAdvertisementParams {
  final String adId;
  final Map<String, dynamic> data;
  const UpdateAdvertisementParams({required this.adId, required this.data});
}