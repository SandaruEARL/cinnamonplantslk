import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/location_repository.dart';

class UploadLocationPhotos {
  final LocationRepository repository;
  UploadLocationPhotos(this.repository);

  Future<Either<Failure, List<String>>> call(List<File> photos) =>
      repository.uploadPhotos(photos);
}