import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/advertisement_entity.dart';

abstract class MarketplaceRepository {
  Stream<Either<Failure, List<AdvertisementEntity>>> getAdvertisements({
    String? category,
    int? limit,
  });

  Stream<Either<Failure, List<AdvertisementEntity>>> getUserAdvertisements(
      String userId,
      );

  Future<Either<Failure, void>> createAdvertisement({
    required AdvertisementEntity ad,
    required List<File> images,
  });

  Future<Either<Failure, void>> addToFavorites(
      String userId,
      String adId,
      );

  Future<Either<Failure, void>> removeFromFavorites(
      String userId,
      String adId,
      );
}