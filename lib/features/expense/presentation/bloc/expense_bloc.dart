import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_expense.dart';
import '../../domain/usecases/get_expenses_by_date_range.dart';
import '../../domain/usecases/get_user_expenses.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesByDateRange getExpensesByDateRange;
  final GetUserExpenses getUserExpenses;
  final CreateExpense createExpense;

  ExpenseBloc({
    required this.getExpensesByDateRange,
    required this.getUserExpenses,
    required this.createExpense,
  }) : super(const ExpenseInitial()) {
    on<ExpenseLoadByDateRange>(_onLoadByDateRange);
    on<ExpenseHistoryLoadRequested>(_onHistoryLoadRequested);
    on<ExpenseCreateRequested>(_onCreateRequested);
  }

  Future<void> _onLoadByDateRange(
      ExpenseLoadByDateRange event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());
    await emit.forEach(
      getExpensesByDateRange(GetExpensesByDateRangeParams(
        userId: event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
        farmerType: event.farmerType,
      )),
      onData: (result) => result.fold(
            (failure) => ExpenseError(failure.message),
            (expenses) => ExpenseLoaded(
          expenses: expenses,
          total: expenses.fold(0, (sum, e) => sum + e.amount),
        ),
      ),
    );
  }

  Future<void> _onHistoryLoadRequested(
      ExpenseHistoryLoadRequested event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());
    await emit.forEach(
      getUserExpenses(GetUserExpensesParams(
        userId: event.userId,
        farmerType: event.farmerType,
      )),
      onData: (result) => result.fold(
            (failure) => ExpenseError(failure.message),
            (expenses) => ExpenseLoaded(
          expenses: expenses,
          total: expenses.fold(0, (sum, e) => sum + e.amount),
        ),
      ),
    );
  }

  Future<void> _onCreateRequested(
      ExpenseCreateRequested event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseCreating());
    final result = await createExpense(event.expense);
    result.fold(
          (failure) => emit(ExpenseError(failure.message)),
          (_) => emit(const ExpenseCreated()),
    );
  }
}