import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/advertisement_entity.dart';
import '../repositories/marketplace_repository.dart';

class GetAnnouncementsParams {
  final String? category;
  final int? limit;
  const GetAnnouncementsParams({this.category, this.limit});
}

class GetAnnouncements {
  final MarketplaceRepository repository;
  GetAnnouncements(this.repository);

  Stream<Either<Failure, List<AdvertisementEntity>>> call(
      GetAnnouncementsParams params,
      ) =>
      repository.getAnnouncements(
        category: params.category,
        limit: params.limit,
      );
}