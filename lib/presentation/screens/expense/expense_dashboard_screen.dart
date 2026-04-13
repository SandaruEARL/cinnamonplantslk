import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/expense.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'add_expense_screen.dart';
import 'expense_history_screen.dart';


class ExpenseDashboardScreen extends StatefulWidget {
  const ExpenseDashboardScreen({super.key});

  @override
  State<ExpenseDashboardScreen> createState() => _ExpenseDashboardScreenState();
}

class _ExpenseDashboardScreenState extends State<ExpenseDashboardScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons. history),
            onPressed: () {
              Navigator.of(context). push(
                MaterialPageRoute(
                  builder: (context) => const ExpenseHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is!  AuthAuthenticated) {
            return const Center(child: Text('Please login'));
          }

          final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
          final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

          return StreamBuilder<List<Expense>>(
            stream: context.read<FirestoreService>().getExpensesByDateRange(
              state.user.id,
              startDate,
              endDate,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState. waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final expenses = snapshot.data ??  [];
              final totalExpense = expenses.fold<double>(
                0,
                    (sum, expense) => sum + expense.amount,
              );

              return SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Month Selector
                Container(
                padding: const EdgeInsets. all(16),
                color: AppColors.background,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _selectedMonth.month != DateTime.now().month
                          ?  () {
                        setState(() {
                          _selectedMonth = DateTime(
                            _selectedMonth.year,
                            _selectedMonth.month + 1,
                          );
                        });
                      }
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Total Expense Card
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
              elevation: 4,
              child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text(
              'Total Expenses',
              style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              ),
              ),
              const SizedBox(height: 8),
              Text(
              'Rs. ${totalExpense.toStringAsFixed(2)}',
              style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              ),
              ),
              const SizedBox(height: 8),
              Text(
              '${expenses.length} transactions',
              style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              ),
              ),
              ],
              ),
              ),
              ),
              ),

              const SizedBox(height: 24),

              // Pie Chart
              if (expenses.isNotEmpty) ...[
              const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
              'Expense Breakdown',
              style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              ),
              ),
              ),
              const SizedBox(height: 16),
              Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
              height: 250,
              child: _buildPieChart(expenses),
              ),
              ),
              ),
              ],

              const SizedBox(height: 24),

              // Recent Transactions
              const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
              'Recent Transactions',
              style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              ),
              ),
              ),
              const SizedBox(height: 16),

              if (expenses.isEmpty)
              Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
              child: Column(
              children: [
              Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.textSecondary. withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
              'No expenses this month',
              style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              ),
              ),
              ],
              ),
              ),
              )
              else
              ... expenses.take(5).map((expense) {
              return Card(
              margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
              ),
              child: ListTile(
              leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
              color: _getCategoryColor(expense.category)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
              _getCategoryIcon(expense.category),
              color: _getCategoryColor(expense.category),
              ),
              ),
              title: Text(
              expense.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
              '${expense.description}\n${DateFormat('MMM dd, yyyy').format(expense.date)}',
              ),
              trailing: Text(
              'Rs. ${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.accentRed,
              ),
              ),
              isThreeLine: true,
              ),
              );
              }).toList(),

              const SizedBox(height: 80),
              ],
              ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton. extended(
        onPressed: () {
          Navigator.of(context). push(
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildPieChart(List<Expense> expenses) {
    final categoryTotals = <String, double>{};

    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense. amount;
    }

    final sections = categoryTotals.entries.map((entry) {
      final percentage = (entry.value / expenses.fold<double>(0, (sum, e) => sum + e.amount)) * 100;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getCategoryColor(entry.key),
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: categoryTotals.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape. circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
    return colors[category] ?? AppColors.primaryGreen;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Fertilizer': Icons.eco,
      'Labor': Icons.people,
      'Transport': Icons. local_shipping,
      'Equipment': Icons. construction,
      'Seeds/Plants': Icons.grass,
      'Pesticides': Icons.science,
      'Other': Icons. more_horiz,
    };
    return icons[category] ?? Icons.receipt;
  }
}