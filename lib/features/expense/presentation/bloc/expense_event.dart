import '../../domain/entities/expense_entity.dart';

abstract class ExpenseEvent {
  const ExpenseEvent();
}

class ExpenseLoadByDateRange extends ExpenseEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String farmerType;
  const ExpenseLoadByDateRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.farmerType,
  });
}

class ExpenseHistoryLoadRequested extends ExpenseEvent {
  final String userId;
  final String farmerType;
  const ExpenseHistoryLoadRequested(this.userId, this.farmerType);
}

class ExpenseCreateRequested extends ExpenseEvent {
  final ExpenseEntity expense;
  const ExpenseCreateRequested(this.expense);
}