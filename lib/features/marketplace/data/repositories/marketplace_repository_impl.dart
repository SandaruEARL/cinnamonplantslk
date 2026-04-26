import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/advertisement_entity.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_datasource.dart';
import '../models/advertisement_model.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource remoteDataSource;
  MarketplaceRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<AdvertisementEntity>>> getAdvertisements({
    String? category,
    int? limit,
  }) {
    try {
      return remoteDataSource
          .getAdvertisements(category: category, limit: limit)
          .map((ads) => Right(ads));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Stream<Either<Failure, List<AdvertisementEntity>>> getAnnouncements({
    String? category,
    int? limit,
  }) {
    try {
      return remoteDataSource
          .getAnnouncements(category: category, limit: limit)
          .map((ads) => Right(ads));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadImages(List<File> images) async {
    try {
      final urls = await remoteDataSource.uploadImages(images);
      return Right(urls);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateAdvertisement(String adId, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateAdvertisement(adId, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<Either<Failure, List<AdvertisementEntity>>> getUserAdvertisements(
      String userId,
      ) {
    try {
      return remoteDataSource
          .getUserAdvertisements(userId)
          .map((ads) => Right(ads));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Future<Either<Failure, void>> createAdvertisement({
    required AdvertisementEntity ad,
    required List<File> images,
  }) async {
    try {
      // Announcements don't have images — skip upload if empty
      final imageUrls =
      images.isNotEmpty ? await remoteDataSource.uploadImages(images) : <String>[];

      final model = AdvertisementModel(
        id: ad.id,
        sellerId: ad.sellerId,
        sellerName: ad.sellerName,
        sellerPhone: ad.sellerPhone,
        sellerProfilePic: ad.sellerProfilePic,
        sellerVerified: ad.sellerVerified,
        title: ad.title,
        description: ad.description,
        category: ad.category,
        price: ad.price,
        grade: ad.grade,
        quantity: ad.quantity,
        location: ad.location,
        imageUrls: imageUrls,
        createdAt: ad.createdAt,
        status: ad.status,
        type: ad.type,
      );
      await remoteDataSource.createAdvertisement(model, imageUrls);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(
      String userId,
      String adId,
      ) async {
    try {
      await remoteDataSource.addToFavorites(userId, adId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(
      String userId,
      String adId,
      ) async {
    try {
      await remoteDataSource.removeFromFavorites(userId, adId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}