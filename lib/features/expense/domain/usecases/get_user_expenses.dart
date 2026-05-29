import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetUserExpenses {
  final ExpenseRepository repository;
  GetUserExpenses(this.repository);

  Stream<Either<Failure, List<ExpenseEntity>>> call(GetUserExpensesParams params) {
    return repository.getUserExpenses(params.userId, params.farmerType);
  }
}

class GetUserExpensesParams {
  final String userId;
  final String farmerType;
  const GetUserExpensesParams({
    required this.userId,
    required this.farmerType,
  });
}