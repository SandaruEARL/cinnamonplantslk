import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/business_location_entity.dart';
import '../repositories/location_repository.dart';

class GetApprovedLocations {
  final LocationRepository repository;
  GetApprovedLocations(this.repository);

  Stream<Either<Failure, List<BusinessLocationEntity>>> call(
      LocationType type,
      ) {
    return repository.getApprovedLocations(type);
  }
}