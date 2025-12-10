import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/expense.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  String?  _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedCategory = value == 'All' ? null : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Categories')),
              const PopupMenuDivider(),
              ... ['Fertilizer', 'Labor', 'Transport', 'Equipment', 'Seeds/Plants', 'Pesticides', 'Other']
                  .map((cat) => PopupMenuItem(value: cat, child: Text(cat)))
                  .toList(),
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
            stream: context.read<FirestoreService>().getUserExpenses(state.user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (! snapshot.hasData || snapshot.data! .isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No expenses yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              var expenses = snapshot.data! ;

              // Filter by category
              if (_selectedCategory != null) {
                expenses = expenses.where((e) => e.category == _selectedCategory).toList();
              }

              // Group by month
              final groupedExpenses = <String, List<Expense>>{};
              for (var expense in expenses) {
                final monthKey = DateFormat('MMMM yyyy'). format(expense.date);
                groupedExpenses. putIfAbsent(monthKey, () => []).add(expense);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedExpenses.length,
                itemBuilder: (context, index) {
                  final monthKey = groupedExpenses.keys.elementAt(index);
                  final monthExpenses = groupedExpenses[monthKey]!;
                  final monthTotal = monthExpenses.fold<double>(
                    0,
                        (sum, expense) => sum + expense.amount,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              monthKey,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rs. ${monthTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBrown,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expenses List
                      ... monthExpenses.map((expense) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(expense.category)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(expense. category),
                                color: _getCategoryColor(expense.category),
                              ),
                            ),
                            title: Text(
                              expense.category,
                              style: const TextStyle(fontWeight: FontWeight. bold),
                            ),
                            subtitle: Text(
                              '${expense.description}\n${DateFormat('MMM dd, yyyy').format(expense.date)}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentRed,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }).toList(),

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

  Color _getCategoryColor(String category) {
    final colors = {
      'Fertilizer': const Color(0xFF10b981),
      'Labor': const Color(0xFF3b82f6),
      'Transport': const Color(0xFFf59e0b),
      'Equipment': const Color(0xFFef4444),
      'Seeds/Plants': const Color(0xFF8b5cf6),
      'Pesticides': const Color(0xFFec4899),
      'Other': const Color(0xFF6b7280),
    };
    return colors[category] ?? AppColors.primaryBrown;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Fertilizer': Icons.eco,
      'Labor': Icons.people,
      'Transport': Icons.local_shipping,
      'Equipment': Icons.construction,
      'Seeds/Plants': Icons.grass,
      'Pesticides': Icons.science,
      'Other': Icons.more_horiz,
    };
    return icons[category] ?? Icons. receipt;
  }
}