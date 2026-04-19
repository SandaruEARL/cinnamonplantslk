import 'package:dartz/dartz.dart';
import '../error/failures.dart';

// Every use case returns Either<Failure, T>
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// For use cases that need no parameters
class NoParams {}