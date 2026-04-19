import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class CreateExpense extends UseCase<void, ExpenseEntity> {
  final ExpenseRepository repository;
  CreateExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(ExpenseEntity params) {
    return repository.createExpense(params);
  }
}