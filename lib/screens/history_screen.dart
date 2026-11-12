
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_colors.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import 'add_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransactionModel> transactions = [];
  String selectedFilter = 'All';
  String searchQuery = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await StorageService.getTransactions();

    if (!mounted) return;

    setState(() {
      transactions = data;
      loading = false;
    });
  }

  List<TransactionModel> get filteredTransactions {
    return transactions.where((item) {
      final matchesFilter = selectedFilter == 'All' ||
          (selectedFilter == 'Income' && item.isIncome) ||
          (selectedFilter == 'Expense' && !item.isIncome);

      final query = searchQuery.toLowerCase();

      final matchesSearch = item.title.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.note.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  String money(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';

  IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'business':
        return Icons.business_center_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Color categoryColor(TransactionModel item) {
    if (item.isIncome) return AppColors.income;

    switch (item.category.toLowerCase()) {
      case 'food':
        return AppColors.warning;
      case 'shopping':
        return AppColors.purple;
      case 'transport':
        return AppColors.sky;
      case 'entertainment':
        return AppColors.pink;
      default:
        return AppColors.expense;
    }
  }

  Future<void> showTransactionDetails(TransactionModel item) async {
    final color = categoryColor(item);

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 45,
                decoration: BoxDecoration(
                  color: AppColors.textGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              CircleAvatar(
                radius: 32,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(
                  categoryIcon(item.category),
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${item.isIncome ? '+' : '-'} ${money(item.amount)}',
                style: TextStyle(
                  color: color,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              detailRow('Category', item.category),
              detailRow(
                'Date',
                '${item.date.day}/${item.date.month}/${item.date.year}',
              ),
              detailRow(
                'Transaction Type',
                item.isIncome ? 'Income' : 'Expense',
              ),

              if (item.note.isNotEmpty)
                detailRow('Description', item.note),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(
                              transaction: item,
                            ),
                          ),
                        );

                        if (result == true && mounted) {
                          await loadTransactions();
                        }
                      },
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text(
                                'Delete Transaction?',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to delete this transaction?',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          await StorageService.deleteTransaction(item.id);

                          if (!mounted) return;

                          Navigator.pop(sheetContext);
                          await loadTransactions();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Transaction deleted successfully!',
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withValues(alpha: 0.15),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textGrey),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget filterButton(String title) {
    final selected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradient : null,
          color: selected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget transactionCard(TransactionModel item, int index) {
    final color = categoryColor(item);

    return InkWell(
      onTap: () => showTransactionDetails(item),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                categoryIcon(item.category),
                color: color,
                size: 22,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.category} • ${item.date.day}/${item.date.month}/${item.date.year}',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.isIncome ? '+' : '-'} ${money(item.amount)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.isIncome ? 'Income' : 'Expense',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textGrey,
              size: 19,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.04);
  }

  Widget summaryBox(
      String title,
      double amount,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              money(amount),
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleTransactions = filteredTransactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: loading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        )
            : RefreshIndicator(
          onRefresh: loadTransactions,
          color: AppColors.sky,
          backgroundColor: AppColors.surface,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 35),
            children: [
              const Text(
                'Transaction History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideX(),

              const SizedBox(height: 6),

              const Text(
                'Track where your money goes',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 23),

              Row(
                children: [
                  Expanded(
                    child: summaryBox(
                      'Total Income',
                      totalIncome,
                      AppColors.income,
                      Icons.south_west_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: summaryBox(
                      'Total Expense',
                      totalExpense,
                      AppColors.expense,
                      Icons.north_east_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: AppColors.sky,
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.sky,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      setState(() => searchQuery = '');
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textGrey,
                    ),
                  )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    filterButton('All'),
                    const SizedBox(width: 9),
                    filterButton('Income'),
                    const SizedBox(width: 9),
                    filterButton('Expense'),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  const Text(
                    'All Transactions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${visibleTransactions.length} records',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (visibleTransactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 45,
                        color: AppColors.purple,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No transactions found',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Try another search or filter.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                      if (searchQuery.isNotEmpty ||
                          selectedFilter != 'All')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                              selectedFilter = 'All';
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                )
              else
                ...visibleTransactions.asMap().entries.map(
                      (entry) => transactionCard(
                    entry.value,
                    entry.key,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
