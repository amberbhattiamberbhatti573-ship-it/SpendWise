
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_colors.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import '../widgets/balance_card.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  final homeKey = GlobalKey<HomeContentState>();
  int historyVersion = 0;

  void openTab(int index) {
    setState(() {
      selectedIndex = index;

      if (index == 1) {
        historyVersion++;
      }
    });

    if (index == 0) {
      homeKey.currentState?.loadData();
    }
  }

  Future<void> addTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );

    if (result == true && mounted) {
      await homeKey.currentState?.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          HomeContent(
            key: homeKey,
            onOpenTab: openTab,
            onAddTransaction: addTransaction,
          ),
          HistoryScreen(
            key: ValueKey(historyVersion),
          ),
          const AnalyticsScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
        onPressed: addTransaction,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ).animate().scale()
          : null,
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: selectedIndex,
        onDestinationSelected: openTab,
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFF263D70),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(
              Icons.grid_view_rounded,
              color: AppColors.sky,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            selectedIcon: Icon(
              Icons.receipt_long_rounded,
              color: AppColors.sky,
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(
              Icons.analytics_rounded,
              color: AppColors.sky,
            ),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppColors.sky,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Function(int) onOpenTab;
  final VoidCallback onAddTransaction;

  const HomeContent({
    super.key,
    required this.onOpenTab,
    required this.onAddTransaction,
  });

  @override
  State<HomeContent> createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  List<TransactionModel> transactions = [];
  Map<String, String> profile = {};
  bool loading = true;

  double get income => transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get expense => transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => income - expense;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final saved = await StorageService.getTransactions();
    final user = await StorageService.getProfile();

    if (!mounted) return;

    setState(() {
      transactions = saved;
      profile = user;
      loading = false;
    });
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get firstName {
    final name = profile['name'] ?? 'SpendWise User';
    return name.trim().isEmpty
        ? 'SpendWise User'
        : name.trim().split(' ').first;
  }

  String money(double value) => 'Rs. ${value.toStringAsFixed(0)}';

  IconData iconFor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'business':
        return Icons.business_center_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Color colorFor(String category, bool isIncome) {
    if (isIncome) return AppColors.income;

    switch (category.toLowerCase()) {
      case 'food':
        return AppColors.warning;
      case 'shopping':
        return AppColors.purple;
      case 'transport':
        return AppColors.sky;
      case 'bills':
        return AppColors.expense;
      case 'entertainment':
        return AppColors.pink;
      default:
        return AppColors.primary;
    }
  }

  void showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.sky,
              size: 42,
            ),
            const SizedBox(height: 15),
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You are all caught up!',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDetails(TransactionModel item) {
    final color = colorFor(item.category, item.isIncome);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(
                iconFor(item.category),
                color: color,
                size: 27,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
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
            const SizedBox(height: 20),
            detailLine('Category', item.category),
            detailLine(
              'Date',
              '${item.date.day}/${item.date.month}/${item.date.year}',
            ),
            detailLine(
              'Type',
              item.isIncome ? 'Income' : 'Expense',
            ),
            if (item.note.isNotEmpty)
              detailLine('Note', item.note),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
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

  Widget sectionTitle(String title, {VoidCallback? onTap}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text(
              'See all  →',
              style: TextStyle(color: AppColors.sky),
            ),
          ),
      ],
    );
  }

  Widget summaryCard(
      String title,
      double amount,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: color.withValues(alpha: 0.13),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
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
        ),
      ),
    );
  }

  Widget quickAction(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget transactionTile(TransactionModel item, int index) {
    final color = colorFor(item.category, item.isIncome);

    return InkWell(
      onTap: () => showDetails(item),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Icon(
                iconFor(item.category),
                color: color,
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.category} • ${item.date.day}/${item.date.month}/${item.date.year}',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${item.isIncome ? '+' : '-'} ${money(item.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textGrey,
              size: 19,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.04);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: loadData,
        color: AppColors.sky,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Text(
                        'SpendWise',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: showNotifications,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                        ),
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.onOpenTab(3),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                        ),
                        icon: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 27),
                  Text(
                    '$greeting, $firstName 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 5),
                  const Text(
                    'Here is your financial overview',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 23),
                  GestureDetector(
                    onTap: () => widget.onOpenTab(2),
                    child: BalanceCard(
                      balance: balance,
                      income: income,
                      expense: expense,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tap balance card to view reports  →',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      summaryCard(
                        'Total Income',
                        income,
                        Icons.south_west_rounded,
                        AppColors.income,
                            () => widget.onOpenTab(1),
                      ),
                      const SizedBox(width: 13),
                      summaryCard(
                        'Total Expense',
                        expense,
                        Icons.north_east_rounded,
                        AppColors.expense,
                            () => widget.onOpenTab(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 27),
                  sectionTitle('Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      quickAction(
                        'Add Expense',
                        Icons.add_circle_outline_rounded,
                        AppColors.expense,
                        widget.onAddTransaction,
                      ),
                      const SizedBox(width: 10),
                      quickAction(
                        'Add Income',
                        Icons.account_balance_wallet_outlined,
                        AppColors.income,
                        widget.onAddTransaction,
                      ),
                      const SizedBox(width: 10),
                      quickAction(
                        'Analytics',
                        Icons.bar_chart_rounded,
                        AppColors.purple,
                            () => widget.onOpenTab(2),
                      ),
                      const SizedBox(width: 10),
                      quickAction(
                        'History',
                        Icons.receipt_long_rounded,
                        AppColors.sky,
                            () => widget.onOpenTab(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 27),
                  sectionTitle(
                    'Recent Transactions',
                    onTap: () => widget.onOpenTab(1),
                  ),
                  const SizedBox(height: 8),
                  if (transactions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.purple,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No transactions yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Start tracking your money today.',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: widget.onAddTransaction,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Transaction'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...transactions
                        .toList()
                        .asMap()
                        .entries
                        .take(5)
                        .map(
                          (entry) => transactionTile(
                        entry.value,
                        entry.key,
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
