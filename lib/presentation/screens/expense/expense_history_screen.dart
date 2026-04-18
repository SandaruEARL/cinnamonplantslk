import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/farmertype.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';


class ExpenseHistoryScreen extends StatefulWidget {
  final FarmerTypeConfig farmerType;
  const ExpenseHistoryScreen({super.key, required this.farmerType});

  @override
  State<ExpenseHistoryScreen> createState() =>
      _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState
    extends State<ExpenseHistoryScreen> {
  String? _selectedCategoryKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.farmerType.emoji} History'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedCategoryKey =
                value == 'All' ? null : value;
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'All',
                  child: Text('All Categories')),
              const PopupMenuDivider(),
              ...widget.farmerType.expenseCategories.map(
                    (cat) => PopupMenuItem(
                  value: cat.key,
                  child: Row(
                    children: [
                      Icon(cat.icon,
                          size: 18, color: cat.color),
                      const SizedBox(width: 8),
                      Text(cat.label),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Please login'));
          }

          return StreamBuilder<List<Expense>>(
            stream: context
                .read<FirestoreService>()
                .getUserExpenses(state.user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator());
              }

              var expenses = (snapshot.data ?? [])
                  .where((e) => widget.farmerType.categoryKeys
                  .contains(e.category))
                  .toList();

              if (_selectedCategoryKey != null) {
                expenses = expenses
                    .where((e) =>
                e.category == _selectedCategoryKey)
                    .toList();
              }

              if (expenses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(widget.farmerType.emoji,
                          style: const TextStyle(
                              fontSize: 56)),
                      const SizedBox(height: 16),
                      const Text('No expenses yet',
                          style: TextStyle(
                              fontSize: 18,
                              color:
                              AppColors.textSecondary)),
                    ],
                  ),
                );
              }

              // Group by month
              final grouped = <String, List<Expense>>{};
              for (var e in expenses) {
                final key =
                DateFormat('MMMM yyyy').format(e.date);
                grouped.putIfAbsent(key, () => []).add(e);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final monthKey =
                  grouped.keys.elementAt(index);
                  final monthExpenses = grouped[monthKey]!;
                  final monthTotal = monthExpenses.fold<double>(
                      0, (sum, e) => sum + e.amount);

                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(monthKey,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.bold)),
                            Text(
                              'Rs. ${monthTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...monthExpenses.map((e) =>
                          _ExpenseTile(
                              expense: e,
                              config: widget.farmerType)),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ── Expense Tile (local copy for history screen) ──────────────────────────────
class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final FarmerTypeConfig config;

  const _ExpenseTile({required this.expense, required this.config});

  @override
  Widget build(BuildContext context) {
    final cat = config.expenseCategories
        .where((c) => c.key == expense.category)
        .firstOrNull;
    final color = cat?.color ?? AppColors.primaryGreen;
    final icon = cat?.icon ?? Icons.receipt;
    final label = cat?.label ?? expense.category;

    return Card(
      margin:
      const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label,
            style:
            const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${expense.description}\n${DateFormat('MMM dd, yyyy').format(expense.date)}',
        ),
        trailing: Text(
          'Rs. ${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.accentRed),
        ),
        isThreeLine: true,
      ),
    );
  }
}