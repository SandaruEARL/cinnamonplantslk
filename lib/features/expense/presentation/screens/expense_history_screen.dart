import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/farmertype.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  final FarmerTypeConfig farmerType;
  const ExpenseHistoryScreen({super.key, required this.farmerType});

  @override
  State<ExpenseHistoryScreen> createState() =>
      _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  String? _selectedCategoryKey;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
          body: Center(child: Text('Please login')));
    }

    return BlocProvider(
      create: (_) => sl<ExpenseBloc>()
        ..add(ExpenseHistoryLoadRequested(
          authState.user.id,
          widget.farmerType.typeKey, // ← ADDED: scopes history to correct farmerType
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.farmerType.emoji} History'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) => setState(() {
                _selectedCategoryKey =
                value == 'All' ? null : value;
              }),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'All', child: Text('All Categories')),
                const PopupMenuDivider(),
                ...widget.farmerType.expenseCategories.map((cat) =>
                    PopupMenuItem(
                      value: cat.key,
                      child: Row(children: [
                        Icon(cat.icon, size: 18, color: cat.color),
                        const SizedBox(width: 8),
                        Text(cat.label),
                      ]),
                    )),
              ],
            ),
          ],
        ),
        body: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExpenseError) {
              return Center(child: Text(state.message));
            }
            if (state is ExpenseLoaded) {
              // ← UI category filter only (farmerType already filtered by Firestore)
              var expenses = _selectedCategoryKey != null
                  ? state.expenses
                  .where((e) => e.category == _selectedCategoryKey)
                  .toList()
                  : state.expenses;

              if (expenses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.farmerType.emoji,
                          style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 16),
                      const Text('No expenses yet',
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }

              final grouped = <String, List<ExpenseEntity>>{};
              for (final e in expenses) {
                final key = DateFormat('MMMM yyyy').format(e.date);
                grouped.putIfAbsent(key, () => []).add(e);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final monthKey = grouped.keys.elementAt(index);
                  final monthExpenses = grouped[monthKey]!;
                  final monthTotal = monthExpenses.fold<double>(
                      0, (sum, e) => sum + e.amount);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(monthKey,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              'Rs. ${monthTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                      ...monthExpenses.map((e) => _ExpenseTile(
                          expense: e, config: widget.farmerType)),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseEntity expense;
  final FarmerTypeConfig config;

  const _ExpenseTile({required this.expense, required this.config});

  @override
  Widget build(BuildContext context) {
    final cat = config.expenseCategories
        .where((c) => c.key == expense.category)
        .firstOrNull;
    final label = cat?.label ?? expense.category;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  '${expense.description}  ·  ${DateFormat('MMM dd, yyyy').format(expense.date)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Rs. ${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}