import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repositories/location_repository.dart';

class DeleteLocation extends UseCase<void, String> {
  final LocationRepository repository;
  DeleteLocation(this.repository);

  @override
  Future<Either<Failure, void>> call(String locationId) {
    return repository.deleteLocation(locationId);
  }
}