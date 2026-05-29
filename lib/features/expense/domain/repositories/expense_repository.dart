import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Stream<Either<Failure, List<ExpenseEntity>>> getExpensesByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      String farmerType,
      );

  Stream<Either<Failure, List<ExpenseEntity>>> getUserExpenses(
      String userId,
      String farmerType,
      );

  Future<Either<Failure, void>> createExpense(ExpenseEntity expense);

  Future<Either<Failure, void>> deleteExpense(String expenseId);
}