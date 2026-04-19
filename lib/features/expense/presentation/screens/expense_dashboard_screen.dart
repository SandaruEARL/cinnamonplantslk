import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/expense/presentation/screens/add_expense_screen.dart';
import '../../../../features/expense/presentation/screens/expense_history_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/farmertype.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';


class ExpenseDashboardScreen extends StatefulWidget {
  final FarmerTypeConfig? initialFarmerType;
  const ExpenseDashboardScreen({super.key, this.initialFarmerType});

  @override
  State<ExpenseDashboardScreen> createState() =>
      _ExpenseDashboardScreenState();
}

class _ExpenseDashboardScreenState
    extends State<ExpenseDashboardScreen> {
  DateTime _selectedMonth = DateTime.now();
  late FarmerTypeConfig _farmerType;

  @override
  void initState() {
    super.initState();
    _farmerType =
        widget.initialFarmerType ?? FarmerTypeConfig.landOwner;
  }

  void _loadExpenses(BuildContext context, String userId) {
    final start = DateTime(
        _selectedMonth.year, _selectedMonth.month, 1);
    final end = DateTime(
        _selectedMonth.year, _selectedMonth.month + 1, 0);
    context.read<ExpenseBloc>().add(ExpenseLoadByDateRange(
      userId: userId,
      startDate: start,
      endDate: end,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        body: Center(child: Text(l10n.pleaseLogin)),
      );
    }

    return BlocProvider(
      create: (ctx) {
        final bloc = sl<ExpenseBloc>();
        _loadExpensesWithBloc(bloc, authState.user.id);
        return bloc;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: Text(l10n.expenseTrackerTitle),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient),
          ),
          actions: [
            PopupMenuButton<FarmerType>(
              tooltip: l10n.switchFarmerType,
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (type) => setState(() {
                switch (type) {
                  case FarmerType.landOwner:
                    _farmerType = FarmerTypeConfig.landOwner;
                  case FarmerType.nurseryOwner:
                    _farmerType = FarmerTypeConfig.nurseryOwner;
                  case FarmerType.baleBuyer:
                    _farmerType = FarmerTypeConfig.baleBuyer;
                }
              }),
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: FarmerType.landOwner,
                    child: Text(l10n.landOwnerLabel)),
                PopupMenuItem(
                    value: FarmerType.nurseryOwner,
                    child: Text(l10n.nurseryOwnerLabel)),
                PopupMenuItem(
                    value: FarmerType.baleBuyer,
                    child: Text(l10n.baleBuyerShopLabel)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExpenseHistoryScreen(
                      farmerType: _farmerType),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  AddExpenseScreen(farmerType: _farmerType),
            ));
            if (context.mounted) {
              _loadExpenses(context, authState.user.id);
            }
          },
          backgroundColor: AppColors.primaryGreen,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final expenses = state is ExpenseLoaded
                ? state.expenses
                .where((e) =>
                _farmerType.categoryKeys.contains(e.category))
                .toList()
                : <ExpenseEntity>[];

            final total =
            expenses.fold<double>(0, (s, e) => s + e.amount);

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month selector
                  _MonthSelector(
                    selectedMonth: _selectedMonth,
                    onPrevious: () {
                      setState(() => _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month - 1));
                      _loadExpenses(context, authState.user.id);
                    },
                    onNext: _selectedMonth.month != DateTime.now().month
                        ? () {
                      setState(() => _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1));
                      _loadExpenses(context, authState.user.id);
                    }
                        : null,
                  ),

                  // Total card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n
                                .totalExpensesLabel(
                                _farmerType.localizedLabel(l10n))
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 10),
                          Text('Rs. ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                  Icons.receipt_long_outlined,
                                  color: Colors.white60,
                                  size: 13),
                              const SizedBox(width: 4),
                              Text(
                                  l10n.transactionsThisMonth(
                                      expenses.length),
                                  style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent transactions
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(l10n.recentTransactions,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ),
                  const SizedBox(height: 4),

                  if (expenses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 48,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(l10n.noExpensesThisMonth,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...expenses.take(5).map((e) => Column(
                      children: [
                        _ExpenseTile(
                            expense: e, config: _farmerType),
                        const Divider(
                            height: 1,
                            indent: 70,
                            endIndent: 16,
                            color: Colors.grey),
                      ],
                    )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _loadExpensesWithBloc(ExpenseBloc bloc, String userId) {
    final start = DateTime(
        _selectedMonth.year, _selectedMonth.month, 1);
    final end = DateTime(
        _selectedMonth.year, _selectedMonth.month + 1, 0);
    bloc.add(ExpenseLoadByDateRange(
        userId: userId, startDate: start, endDate: end));
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: const Color(0xFFF7F7F7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right,
                color: onNext != null
                    ? Colors.black87
                    : Colors.grey.shade300),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseEntity expense;
  final FarmerTypeConfig config;

  const _ExpenseTile(
      {required this.expense, required this.config});

  @override
  Widget build(BuildContext context) {
    final cat = config.expenseCategories
        .where((c) => c.key == expense.category)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat?.label ?? expense.category,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(expense.description,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rs. ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                  DateFormat('MMM dd, yyyy').format(expense.date),
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}