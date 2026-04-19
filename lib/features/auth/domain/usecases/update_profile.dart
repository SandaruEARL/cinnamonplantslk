import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams {
  final String uid;
  final String? name;
  final String? phone;
  final String? location;

  const UpdateProfileParams({
    required this.uid,
    this.name,
    this.phone,
    this.location,
  });
}

class UpdateProfile extends UseCase<void, UpdateProfileParams> {
  final AuthRepository repository;
  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      uid:      params.uid,
      name:     params.name,
      phone:    params.phone,
      location: params.location,
    );
  }
}