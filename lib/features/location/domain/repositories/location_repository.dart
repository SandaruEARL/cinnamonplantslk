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

  Future<Either<Failure, void>> saveLocation({
    required BusinessLocationEntity location,
    required List<File> newPhotos,
  });

  Future<Either<Failure, void>> deleteLocation(String locationId);
}