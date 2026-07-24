import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUp extends UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;
  SignUp(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
      phone: params.phone,
      userType: params.userType,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String userType;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.userType,
  });
}