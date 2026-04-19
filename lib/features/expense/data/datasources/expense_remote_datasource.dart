import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Stream<List<ExpenseModel>> getExpensesByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      );

  Stream<List<ExpenseModel>> getUserExpenses(String userId);

  Future<void> createExpense(ExpenseModel expense);

  Future<void> deleteExpense(String expenseId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;
  ExpenseRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<ExpenseModel>> getExpensesByDateRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) {
    try {
      return _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .snapshots()
          .map((snap) => snap.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ExpenseModel>> getUserExpenses(String userId) {
    try {
      return _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snap) => snap.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createExpense(ExpenseModel expense) async {
    try {
      await _firestore.collection('expenses').add(expense.toFirestore());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}