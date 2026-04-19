import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/business_location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';
import '../models/business_location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<BusinessLocationEntity>>> getApprovedLocations(
      LocationType type,
      ) {
    try {
      return remoteDataSource
          .getApprovedLocations(type)
          .map((locations) => Right(locations));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Stream<Either<Failure, List<BusinessLocationEntity>>> getUserLocations(
      String userId,
      ) {
    try {
      return remoteDataSource
          .getUserLocations(userId)
          .map((locations) => Right(locations));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocation({
    required BusinessLocationEntity location,
    required List<File> newPhotos,
  }) async {
    try {
      List<String> newUrls = [];
      if (newPhotos.isNotEmpty) {
        newUrls = await remoteDataSource.uploadPhotos(newPhotos);
      }
      final allPhotos = [...location.photoUrls, ...newUrls];
      final model = BusinessLocationModel(
        id: location.id,
        userId: location.userId,
        ownerName: location.ownerName,
        ownerPhone: location.ownerPhone,
        ownerProfilePic: location.ownerProfilePic,
        type: location.type,
        businessName: location.businessName,
        description: location.description,
        address: location.address,
        latitude: location.latitude,
        longitude: location.longitude,
        openingHours: location.openingHours,
        photoUrls: allPhotos,
        createdAt: location.createdAt,
        updatedAt: location.updatedAt,
        status: location.status,
        rejectionReason: location.rejectionReason,
      );
      await remoteDataSource.saveLocation(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String locationId) async {
    try {
      await remoteDataSource.deleteLocation(locationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}