import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;
  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<ExpenseEntity>>> getExpensesByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) {
    try {
      return remoteDataSource
          .getExpensesByDateRange(userId, startDate, endDate)
          .map((expenses) => Right(expenses));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Stream<Either<Failure, List<ExpenseEntity>>> getUserExpenses(
      String userId,
      ) {
    try {
      return remoteDataSource
          .getUserExpenses(userId)
          .map((expenses) => Right(expenses));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }

  @override
  Future<Either<Failure, void>> createExpense(ExpenseEntity expense) async {
    try {
      final model = ExpenseModel(
        id: expense.id,
        userId: expense.userId,
        category: expense.category,
        amount: expense.amount,
        description: expense.description,
        date: expense.date,
        createdAt: expense.createdAt,
      );
      await remoteDataSource.createExpense(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await remoteDataSource.deleteExpense(expenseId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}