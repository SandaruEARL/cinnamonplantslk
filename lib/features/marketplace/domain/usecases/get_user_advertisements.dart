import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/advertisement_entity.dart';
import '../repositories/marketplace_repository.dart';

class GetUserAdvertisements {
  final MarketplaceRepository repository;
  GetUserAdvertisements(this.repository);

  Stream<Either<Failure, List<AdvertisementEntity>>> call(String userId) {
    return repository.getUserAdvertisements(userId);
  }
}