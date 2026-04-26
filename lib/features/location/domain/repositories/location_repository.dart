import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/business_location_entity.dart';

abstract class LocationRepository {
  Stream<Either<Failure, List<BusinessLocationEntity>>> getApprovedLocations(
      LocationType type,
      );

  Stream<Either<Failure, List<BusinessLocationEntity>>> getUserLocations(
      String userId,
      );

  /// Creates or updates a location document in-place.
  /// Used for new submissions and PENDING location edits.
  Future<Either<Failure, void>> saveLocation({
    required BusinessLocationEntity location,
    required List<File> newPhotos,
  });

  /// Submits an edit for an APPROVED location to the `pendingEdit`
  /// subcollection under `locations/{locationId}/pendingEdit/{editId}`.
  Future<Either<Failure, void>> submitLocationEdit(
      String locationId,
      Map<String, dynamic> editData,
      );

  Future<Either<Failure, void>> deleteLocation(String locationId);


  Future<Either<Failure, List<String>>> uploadPhotos(List<File> photos);
}