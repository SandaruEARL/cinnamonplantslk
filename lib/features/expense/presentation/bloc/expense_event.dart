import '../../domain/entities/expense_entity.dart';

abstract class ExpenseEvent {
  const ExpenseEvent();
}

class ExpenseLoadByDateRange extends ExpenseEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  const ExpenseLoadByDateRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
}

class ExpenseHistoryLoadRequested extends ExpenseEvent {
  final String userId;
  const ExpenseHistoryLoadRequested(this.userId);
}

class ExpenseCreateRequested extends ExpenseEvent {
  final ExpenseEntity expense;
  const ExpenseCreateRequested(this.expense);
}