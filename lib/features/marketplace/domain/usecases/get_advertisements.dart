import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/advertisement_entity.dart';
import '../repositories/marketplace_repository.dart';

class GetAdvertisements {
  final MarketplaceRepository repository;
  GetAdvertisements(this.repository);

  Stream<Either<Failure, List<AdvertisementEntity>>> call(
      GetAdvertisementsParams params,
      ) {
    return repository.getAdvertisements(
      category: params.category,
      limit: params.limit,
    );
  }
}

class GetAdvertisementsParams {
  final String? category;
  final int? limit;
  const GetAdvertisementsParams({this.category, this.limit});
}