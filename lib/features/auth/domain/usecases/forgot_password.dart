import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository repository;
  const ForgotPassword(this.repository);

  Future<Either<Failure, void>> call(ForgotPasswordParams params) {
    return repository.forgotPassword(email: params.email);
  }
}

class ForgotPasswordParams {
  final String email;
  const ForgotPasswordParams({required this.email});
}