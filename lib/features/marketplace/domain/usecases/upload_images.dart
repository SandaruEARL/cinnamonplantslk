import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/marketplace_repository.dart';

class UploadImages {
  final MarketplaceRepository repository;
  UploadImages(this.repository);

  Future<Either<Failure, List<String>>> call(List<File> images) =>
      repository.uploadImages(images);
}