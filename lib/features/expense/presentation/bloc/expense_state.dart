import '../../domain/entities/expense_entity.dart';

abstract class ExpenseState {
  const ExpenseState();
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final double total;
  const ExpenseLoaded({required this.expenses, required this.total});
}

class ExpenseCreating extends ExpenseState {
  const ExpenseCreating();
}

class ExpenseCreated extends ExpenseState {
  const ExpenseCreated();
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);
}