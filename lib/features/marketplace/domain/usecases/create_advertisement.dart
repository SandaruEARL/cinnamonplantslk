import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/advertisement_entity.dart';
import '../repositories/marketplace_repository.dart';

class CreateAdvertisement extends UseCase<void, CreateAdvertisementParams> {
  final MarketplaceRepository repository;
  CreateAdvertisement(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateAdvertisementParams params) {
    return repository.createAdvertisement(
      ad: params.ad,
      images: params.images,
    );
  }
}

class CreateAdvertisementParams {
  final AdvertisementEntity ad;
  final List<File> images;
  const CreateAdvertisementParams({required this.ad, required this.images});
}