
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_colors.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final bool? initialIsIncome;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialIsIncome,
  });

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late bool isIncome;
  late String category;
  late DateTime selectedDate;

  bool isSaving = false;

  static const Color bg = Color(0xFF080D1B);
  static const Color surface = Color(0xFF141E33);
  static const Color muted = Color(0xFF9AA8C1);

  final List<String> categories = [
    'Food',
    'Shopping',
    'Transport',
    'Bills',
    'Salary',
    'Health',
    'Education',
    'Entertainment',
    'Business',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final t = widget.transaction;

    _titleController = TextEditingController(text: t?.title ?? '');
    _amountController = TextEditingController(
      text: t?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(text: t?.note ?? '');

    isIncome = t?.isIncome ?? widget.initialIsIncome ?? false;
    category = t?.category ?? (isIncome ? 'Salary' : 'Food');
    selectedDate = t?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> saveTransaction() async {
    if (isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final transaction = TransactionModel(
      id: widget.transaction?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: category,
      amount: double.parse(_amountController.text.trim()),
      isIncome: isIncome,
      date: selectedDate,
      note: _noteController.text.trim(),
    );

    try {
      if (widget.transaction == null) {
        await StorageService.addTransaction(transaction);
      } else {
        await StorageService.updateTransaction(transaction);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction == null
                ? 'Transaction saved successfully!'
                : 'Transaction updated successfully!',
          ),
          backgroundColor:
          isIncome ? AppColors.income : AppColors.primary,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save transaction: $e'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: muted, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.secondary),
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.all(17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget typeButton(String title, bool income) {
    final selected = isIncome == income;
    final color = income ? AppColors.income : AppColors.expense;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isIncome = income;

            if (income && category == 'Food') {
              category = 'Salary';
            }

            if (!income && category == 'Salary') {
              category = 'Food';
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.17)
                : surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? color
                  : Colors.white.withValues(alpha: 0.07),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                income
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: selected ? color : muted,
                size: 23,
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: TextStyle(
                  color: selected ? color : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.transaction == null
              ? 'Add Transaction'
              : 'Edit Transaction',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  gradient: AppColors.darkGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SMART MONEY MANAGEMENT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      isIncome ? 'Money Coming In' : 'Money Going Out',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Record every transaction and stay in control.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08),

              const SizedBox(height: 27),

              sectionLabel('Transaction Type'),
              Row(
                children: [
                  typeButton('Expense', false),
                  const SizedBox(width: 12),
                  typeButton('Income', true),
                ],
              ),

              const SizedBox(height: 23),

              sectionLabel('Transaction Title'),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                cursorColor: AppColors.secondary,
                textCapitalization: TextCapitalization.sentences,
                decoration: inputDecoration(
                  'e.g. Grocery Shopping',
                  Icons.edit_note_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter transaction title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              sectionLabel('Amount (PKR)'),
              TextFormField(
                controller: _amountController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                cursorColor: AppColors.secondary,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: inputDecoration(
                  'Enter amount',
                  Icons.currency_rupee_rounded,
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount greater than zero';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              sectionLabel('Category'),
              DropdownButtonFormField<String>(
                initialValue: categories.contains(category)
                    ? category
                    : 'Other',
                dropdownColor: surface,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration(
                  'Select category',
                  Icons.category_outlined,
                ),
                items: categories.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => category = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              sectionLabel('Transaction Date'),
              InkWell(
                onTap: pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 13),
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.edit_calendar_rounded,
                        color: muted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              sectionLabel('Note (Optional)'),
              TextFormField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white),
                cursorColor: AppColors.secondary,
                maxLines: 3,
                decoration: inputDecoration(
                  'Add transaction details...',
                  Icons.notes_rounded,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 57,
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : saveTransaction,
                  icon: isSaving
                      ? const SizedBox(
                    height: 19,
                    width: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    isSaving
                        ? 'Saving...'
                        : widget.transaction == null
                        ? 'Save Transaction'
                        : 'Update Transaction',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: accent.withValues(alpha: 0.5),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
