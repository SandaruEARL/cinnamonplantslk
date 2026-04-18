import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/farmertype.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'add_expense_screen.dart';
import 'expense_history_screen.dart';

class ExpenseDashboardScreen extends StatefulWidget {
  final FarmerTypeConfig? initialFarmerType;
  const ExpenseDashboardScreen({super.key, this.initialFarmerType});

  @override
  State<ExpenseDashboardScreen> createState() => _ExpenseDashboardScreenState();
}

class _ExpenseDashboardScreenState extends State<ExpenseDashboardScreen> {
  DateTime _selectedMonth = DateTime.now();
  late FarmerTypeConfig _farmerType;

  @override
  void initState() {
    super.initState();
    _farmerType = widget.initialFarmerType ?? FarmerTypeConfig.landOwner;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(l10n.expenseTrackerTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          PopupMenuButton<FarmerType>(
            tooltip: l10n.switchFarmerType,
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (type) {
              setState(() {
                switch (type) {
                  case FarmerType.landOwner:
                    _farmerType = FarmerTypeConfig.landOwner;
                  case FarmerType.nurseryOwner:
                    _farmerType = FarmerTypeConfig.nurseryOwner;
                  case FarmerType.baleBuyer:
                    _farmerType = FarmerTypeConfig.baleBuyer;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: FarmerType.landOwner,
                child: Text(l10n.landOwnerLabel),
              ),
              PopupMenuItem(
                value: FarmerType.nurseryOwner,
                child: Text(l10n.nurseryOwnerLabel),
              ),
              PopupMenuItem(
                value: FarmerType.baleBuyer,
                child: Text(l10n.baleBuyerShopLabel),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ExpenseHistoryScreen(farmerType: _farmerType),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddExpenseScreen(farmerType: _farmerType),
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(child: Text(l10n.pleaseLogin));
          }

          final startDate =
          DateTime(_selectedMonth.year, _selectedMonth.month, 1);
          final endDate =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

          return StreamBuilder<List<Expense>>(
            stream: context.read<FirestoreService>().getExpensesByDateRange(
              state.user.id,
              startDate,
              endDate,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allExpenses = snapshot.data ?? [];
              final expenses = allExpenses
                  .where((e) => _farmerType.categoryKeys.contains(e.category))
                  .toList();
              final total =
              expenses.fold<double>(0, (sum, e) => sum + e.amount);

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FarmerTypeBanner(config: _farmerType),
                    _MonthSelector(
                      selectedMonth: _selectedMonth,
                      onPrevious: () => setState(() => _selectedMonth =
                          DateTime(_selectedMonth.year,
                              _selectedMonth.month - 1)),
                      onNext: _selectedMonth.month != DateTime.now().month
                          ? () => setState(() => _selectedMonth =
                          DateTime(_selectedMonth.year,
                              _selectedMonth.month + 1))
                          : null,
                    ),
                    _TotalCard(
                      total: total,
                      count: expenses.length,
                      farmerType: _farmerType,
                    ),
                    if (_farmerType.hasProfitTracking) ...[
                      const SizedBox(height: 12),
                      _ProfitSummaryCard(
                        totalExpenses: total,
                        farmerType: _farmerType,
                        userId: state.user.id,
                        month: _selectedMonth,
                      ),
                    ],
                    if (expenses.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _SectionTitle(l10n.expenseBreakdown),
                      const SizedBox(height: 12),
                      _PieChartCard(expenses: expenses, config: _farmerType),
                    ],
                    const SizedBox(height: 24),
                    _SectionTitle(l10n.recentTransactions),
                    const SizedBox(height: 4),
                    if (expenses.isEmpty)
                      _EmptyState(farmerType: _farmerType)
                    else
                      ...expenses.take(5).map(
                            (e) => Column(
                          children: [
                            _ExpenseTile(expense: e, config: _farmerType),
                            const Divider(
                                height: 1, indent: 70, endIndent: 16, color: Colors.grey,),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Farmer Type Banner ────────────────────────────────────────────────────────
class _FarmerTypeBanner extends StatelessWidget {
  final FarmerTypeConfig config;
  const _FarmerTypeBanner({required this.config});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final label = switch (config.type) {
      FarmerType.landOwner => l10n.landOwnerLabel,
      FarmerType.nurseryOwner => l10n.nurseryOwnerLabel,
      FarmerType.baleBuyer => l10n.baleBuyerShopLabel,
    };

    final term = switch (config.type) {
      FarmerType.landOwner => l10n.farmerTypeTermLandOwner,
      FarmerType.nurseryOwner => l10n.farmerTypeTermNurseryOwner,
      FarmerType.baleBuyer => l10n.farmerTypeTermBaleBuyer,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: config.color.withOpacity(0.08),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: config.color,
                ),
              ),
              Text(
                l10n.trackingLabel(term),
                style:
                const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Month Selector ────────────────────────────────────────────────────────────
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
            onPressed: onPrevious,
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: onNext != null ? Colors.black87 : Colors.grey.shade300,
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ── Total Card ────────────────────────────────────────────────────────────────
class _TotalCard extends StatelessWidget {
  final double total;
  final int count;
  final FarmerTypeConfig farmerType;

  const _TotalCard({
    required this.total,
    required this.count,
    required this.farmerType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
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
              l10n.totalExpensesLabel(farmerType.localizedLabel(l10n)).toUpperCase(),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Rs. ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: Colors.white60, size: 13),
                const SizedBox(width: 4),
                Text(
                  l10n.transactionsThisMonth(count),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profit Summary Card ───────────────────────────────────────────────────────
class _ProfitSummaryCard extends StatefulWidget {
  final double totalExpenses;
  final FarmerTypeConfig farmerType;
  final String userId;
  final DateTime month;

  const _ProfitSummaryCard({
    required this.totalExpenses,
    required this.farmerType,
    required this.userId,
    required this.month,
  });

  @override
  State<_ProfitSummaryCard> createState() => _ProfitSummaryCardState();
}

class _ProfitSummaryCardState extends State<_ProfitSummaryCard> {
  final _revenueController = TextEditingController();
  double _revenue = 0;
  bool _editing = false;

  double get _profit => _revenue - widget.totalExpenses;
  bool get _isProfitable => _profit >= 0;
  double get _progressValue =>
      _revenue > 0 ? (widget.totalExpenses / _revenue).clamp(0.0, 1.0) : 0.0;

  @override
  void dispose() {
    _revenueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL REVENUE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_editing) {
                        _revenue =
                            double.tryParse(_revenueController.text) ?? 0;
                      } else {
                        _revenueController.text =
                        _revenue > 0 ? _revenue.toStringAsFixed(2) : '';
                      }
                      _editing = !_editing;
                    });
                  },
                  child: Icon(
                    _editing
                        ? Icons.check_circle_outline
                        : Icons.edit_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_editing)
              TextField(
                controller: _revenueController,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                decoration: const InputDecoration(
                  prefixText: 'Rs. ',
                  border: InputBorder.none,
                  hintText: '0.00',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
            else ...[
              Text(
                'Rs. ${_revenue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _progressValue > 0.85
                        ? AppColors.accentRed
                        : AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_revenue > 0)
                    Text(
                      '${(_progressValue * 100).toStringAsFixed(0)}% spent',
                      style:
                      const TextStyle(fontSize: 11, color: Colors.grey),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => setState(() => _editing = true),
                      icon: const Icon(Icons.add, size: 14),
                      label: Text(l10n.tapToEnterRevenue,
                          style: const TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  if (_revenue > 0)
                    Text(
                      '${(100 - _progressValue * 100).toStringAsFixed(0)}% Target',
                      style:
                      const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
              if (_revenue > 0) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.netProfitLoss,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      '${_isProfitable ? '+' : ''}Rs. ${_profit.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isProfitable
                            ? AppColors.primaryGreen
                            : AppColors.accentRed,
                      ),
                    ),
                  ],
                ),
                if (widget.farmerType.type == FarmerType.landOwner) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: Colors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.peelerShareReminder,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── Pie Chart Card ────────────────────────────────────────────────────────────
class _PieChartCard extends StatelessWidget {
  final List<Expense> expenses;
  final FarmerTypeConfig config;

  const _PieChartCard({required this.expenses, required this.config});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final categoryTotals = <String, double>{};
    for (var e in expenses) {
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final grandTotal = expenses.fold<double>(0, (s, e) => s + e.amount);

    final sections = categoryTotals.entries.map((entry) {
      final pct = (entry.value / grandTotal) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '',        // no title on slices
        color: _colorFor(entry.key),
        radius: 36,       // thin ring
        titleStyle: const TextStyle(fontSize: 0),
      );
    }).toList();

    // dominant category percentage for center label
    final topPct = categoryTotals.isNotEmpty
        ? ((categoryTotals.values.reduce((a, b) => a > b ? a : b) /
        grandTotal) *
        100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Chart + Legend
          Row(
            children: [
              // Donut chart with center text
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        startDegreeOffset: -90,
                      ),
                    ),
                    // Center label
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoryTotals.length == 1
                              ? '100%'
                              : '${topPct.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 50),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categoryTotals.entries.map((entry) {
                    final cat = _categoryFor(entry.key);
                    final pct = (entry.value / grandTotal) * 100;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _colorFor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat?.label ?? entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: pct > 10
                                    ? Colors.black87
                                    : Colors.grey.shade400,
                                fontWeight: pct > 10
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
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
          ),
        ],
      ),
    );
  }

  ExpenseCategory? _categoryFor(String key) =>
      config.expenseCategories.where((c) => c.key == key).firstOrNull;

  Color _colorFor(String key) =>
      _categoryFor(key)?.color ?? AppColors.primaryGreen;
}

// ── Expense Tile ──────────────────────────────────────────────────────────────
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expense.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM dd, yyyy').format(expense.date),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final FarmerTypeConfig farmerType;
  const _EmptyState({required this.farmerType});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final label = switch (farmerType.type) {
      FarmerType.landOwner => l10n.landOwnerLabel,
      FarmerType.nurseryOwner => l10n.nurseryOwnerLabel,
      FarmerType.baleBuyer => l10n.baleBuyerShopLabel,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              l10n.noExpensesThisMonth,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.startTrackingCosts(label.toLowerCase()),
              style:
              TextStyle(fontSize: 12, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}