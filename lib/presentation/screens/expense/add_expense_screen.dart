import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/farmertype.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';


class AddExpenseScreen extends StatefulWidget {
  final FarmerTypeConfig farmerType;
  const AddExpenseScreen({super.key, required this.farmerType});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _selectedCategoryKey;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryKey =
        widget.farmerType.expenseCategories.first.key;
  }

  ExpenseCategory get _selectedCategory =>
      widget.farmerType.expenseCategories
          .firstWhere((c) => c.key == _selectedCategoryKey);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addExpenseTitle(widget.farmerType.localizedLabel(l10n))),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Farmer type badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.farmerType.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    widget.farmerType.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.farmerType.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category — tappable chip cards
            Text(l10n.categoryLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.farmerType.expenseCategories.map((cat) {
                final isSelected = cat.key == _selectedCategoryKey;
                final chipColor = isSelected
                    ? AppColors.primaryGreen
                    : Colors.grey.shade400;
                final bgColor = isSelected
                    ? AppColors.primaryGreen.withOpacity(0.12)
                    : Colors.grey.shade100;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryKey = cat.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGreen.withOpacity(0.15) : bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: chipColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Hint for selected category
            if (_selectedCategory.hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 16, color: Colors.blue),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _selectedCategory.hint,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Amount
            TextFormField(
              controller: _amountController,
              validator: (val) => Validators.validatePrice(
                val,
                requiredMessage: l10n.validationPriceRequired,
                invalidMessage: l10n.validationPriceInvalid,
              ),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (Rs.)',
              ),
            ),

            const SizedBox(height: 16),

            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate)),
              leading: const Icon(Icons.calendar_today),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.divider),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              validator: (val) => Validators.validateRequired(
                val,
                requiredMessage: l10n.validationFieldRequired(l10n.descriptionHint),
              ),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                'e.g., 2 bags of Eppawala Rock Phosphate',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _saveExpense,
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: widget.farmerType.color,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white),
                ),
              )
                  : const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);
    try {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authState.user.id,
        category: _selectedCategoryKey,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
      );

      await context.read<FirestoreService>().createExpense(expense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}