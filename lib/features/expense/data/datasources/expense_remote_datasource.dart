import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Stream<List<ExpenseModel>> getExpensesByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      String farmerType,
      );

  Stream<List<ExpenseModel>> getUserExpenses(
      String userId,
      String farmerType,
      );

  Future<void> createExpense(ExpenseModel expense);

  Future<void> deleteExpense(String expenseId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;
  ExpenseRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ExpenseModel>> getExpensesByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      String farmerType,
      ) {
    try {
      return firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('farmerType', isEqualTo: farmerType)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ExpenseModel>> getUserExpenses(
      String userId,
      String farmerType,
      ) {
    try {
      return firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('farmerType', isEqualTo: farmerType)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createExpense(ExpenseModel expense) async {
    try {
      await firestore
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toFirestore());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await firestore.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}