import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/business_location_entity.dart';
import '../repositories/location_repository.dart';

class SaveLocation extends UseCase<void, SaveLocationParams> {
  final LocationRepository repository;
  SaveLocation(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveLocationParams params) {
    return repository.saveLocation(
      location: params.location,
      newPhotos: params.newPhotos,
    );
  }
}

class SaveLocationParams {
  final BusinessLocationEntity location;
  final List<File> newPhotos;
  const SaveLocationParams({
    required this.location,
    required this.newPhotos,
  });
}