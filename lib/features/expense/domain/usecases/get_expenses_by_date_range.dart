import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesByDateRange {
  final ExpenseRepository repository;
  GetExpensesByDateRange(this.repository);

  Stream<Either<Failure, List<ExpenseEntity>>> call(
      GetExpensesByDateRangeParams params,
      ) {
    return repository.getExpensesByDateRange(
      params.userId,
      params.startDate,
      params.endDate,
      params.farmerType,
    );
  }
}

class GetExpensesByDateRangeParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String farmerType;
  const GetExpensesByDateRangeParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.farmerType,
  });
}