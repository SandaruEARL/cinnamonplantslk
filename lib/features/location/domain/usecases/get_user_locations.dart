import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/business_location_entity.dart';
import '../repositories/location_repository.dart';

class GetUserLocations {
  final LocationRepository repository;
  GetUserLocations(this.repository);

  Stream<Either<Failure, List<BusinessLocationEntity>>> call(String userId) {
    return repository.getUserLocations(userId);
  }
}