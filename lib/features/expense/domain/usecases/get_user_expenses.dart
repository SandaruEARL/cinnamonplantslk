import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetUserExpenses {
  final ExpenseRepository repository;
  GetUserExpenses(this.repository);

  Stream<Either<Failure, List<ExpenseEntity>>> call(String userId) {
    return repository.getUserExpenses(userId);
  }
}