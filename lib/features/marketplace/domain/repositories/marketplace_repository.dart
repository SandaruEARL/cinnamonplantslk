import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/advertisement_entity.dart';

abstract class MarketplaceRepository {
  Stream<Either<Failure, List<AdvertisementEntity>>> getAdvertisements({
    String? category,
    int? limit,
  });

  Stream<Either<Failure, List<AdvertisementEntity>>> getAnnouncements({
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

  Future<Either<Failure, void>> addToFavorites(String userId, String adId);

  Future<Either<Failure, void>> removeFromFavorites(String userId, String adId);

  /// In-place update for PENDING ads — replaces document fields directly.
  Future<Either<Failure, void>> updateAdvertisement(
      String adId,
      Map<String, dynamic> data,
      );

  /// Submits an edit for a LIVE/APPROVED ad into the `pendingEdit`
  /// subcollection under `advertisements/{adId}/pendingEdit/{editId}`.
  /// The original ad remains live until admin approves.
  Future<Either<Failure, void>> submitAdEdit(
      String adId,
      Map<String, dynamic> editData,
      );

  Future<Either<Failure, List<String>>> uploadImages(List<File> images);
}