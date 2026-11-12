
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_colors.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<TransactionModel> transactions = [];
  bool loading = true;
  String selectedPeriod = 'All Time';

  final List<Color> chartColors = const [
    AppColors.primary,
    AppColors.purple,
    AppColors.income,
    AppColors.warning,
    AppColors.pink,
    AppColors.sky,
    AppColors.expense,
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await StorageService.getTransactions();

    if (!mounted) return;

    setState(() {
      transactions = data;
      loading = false;
    });
  }

  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();

    return transactions.where((item) {
      switch (selectedPeriod) {
        case 'This Month':
          return item.date.year == now.year &&
              item.date.month == now.month;

        case 'This Year':
          return item.date.year == now.year;

        case 'Last 7 Days':
          final start = DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 6));

          return !item.date.isBefore(start) &&
              !item.date.isAfter(now);

        default:
          return true;
      }
    }).toList();
  }

  double get totalIncome => filteredTransactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => filteredTransactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get savings => totalIncome - totalExpense;

  String money(double value) => 'Rs. ${value.toStringAsFixed(0)}';

  Map<String, double> get categoryExpenses {
    final result = <String, double>{};

    for (final item in filteredTransactions.where((t) => !t.isIncome)) {
      result[item.category] =
          (result[item.category] ?? 0) + item.amount;
    }

    return result;
  }

  double dailyAmount(int day, bool isIncome) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 6 - day));

    return transactions
        .where((t) =>
    t.date.year == date.year &&
        t.date.month == date.month &&
        t.date.day == date.day &&
        t.isIncome == isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get weeklyMax {
    double highest = 0;

    for (int i = 0; i < 7; i++) {
      final income = dailyAmount(i, true);
      final expense = dailyAmount(i, false);

      if (income > highest) highest = income;
      if (expense > highest) highest = expense;
    }

    return highest == 0 ? 100 : highest * 1.25;
  }

  String dayLabel(int index) {
    final date = DateTime.now().subtract(
      Duration(days: 6 - index),
    );

    const days = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];

    return days[date.weekday - 1];
  }

  Widget summaryCard(
      String title,
      double amount,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Container(
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
            CircleAvatar(
              radius: 19,
              backgroundColor: color.withValues(alpha: 0.13),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
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
    );
  }

  Widget sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget chartContainer({
    required Widget child,
    double? height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }

  Widget legendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 9,
          width: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget weeklyChart() {
    return BarChart(
      BarChartData(
        maxY: weeklyMax,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: 15,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: weeklyMax / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.07),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                if (index < 0 || index > 6) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    dayLabel(index),
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barsSpace: 5,
            barRods: [
              BarChartRodData(
                toY: dailyAmount(index, true),
                width: 8,
                borderRadius: BorderRadius.circular(5),
                color: AppColors.income,
              ),
              BarChartRodData(
                toY: dailyAmount(index, false),
                width: 8,
                borderRadius: BorderRadius.circular(5),
                color: AppColors.expense,
              ),
            ],
          );
        }),
      ),
      duration: const Duration(milliseconds: 700),
    );
  }

  Widget categoryChart() {
    final entries = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return const SizedBox(
        height: 190,
        child: Center(
          child: Text(
            'No expense data available for this period',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey),
          ),
        ),
      );
    }

    final colors = List.generate(
      entries.length,
          (index) => chartColors[index % chartColors.length],
    );

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 48,
              sectionsSpace: 4,
              sections: List.generate(entries.length, (index) {
                return PieChartSectionData(
                  value: entries[index].value,
                  color: colors[index],
                  radius: 65,
                  showTitle: false,
                );
              }),
            ),
            duration: const Duration(milliseconds: 700),
          ),
        ),
        const SizedBox(height: 15),
        ...List.generate(entries.length, (index) {
          final entry = entries[index];
          final percentage = totalExpense == 0
              ? 0.0
              : (entry.value / totalExpense) * 100;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  height: 11,
                  width: 11,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: colors[index],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  money(entry.value),
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget savingsCard() {
    final positive = savings >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Icon(
              positive
                  ? Icons.savings_rounded
                  : Icons.trending_down_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Net Savings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  money(savings),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            positive
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: Colors.white,
            size: 25,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          color: AppColors.sky,
          backgroundColor: AppColors.surface,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 35),
            children: [
              const Text(
                'Financial Reports',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideX(),

              const SizedBox(height: 6),

              const Text(
                'Understand your money at a glance',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.sky,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Report Period',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPeriod,
                        dropdownColor: AppColors.surface,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.sky,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'All Time',
                            child: Text('All Time'),
                          ),
                          DropdownMenuItem(
                            value: 'This Month',
                            child: Text('This Month'),
                          ),
                          DropdownMenuItem(
                            value: 'This Year',
                            child: Text('This Year'),
                          ),
                          DropdownMenuItem(
                            value: 'Last 7 Days',
                            child: Text('Last 7 Days'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedPeriod = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  summaryCard(
                    'Total Income',
                    totalIncome,
                    AppColors.income,
                    Icons.south_west_rounded,
                  ),
                  const SizedBox(width: 12),
                  summaryCard(
                    'Total Expenses',
                    totalExpense,
                    AppColors.expense,
                    Icons.north_east_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              savingsCard().animate().fadeIn().slideY(),

              const SizedBox(height: 28),

              sectionTitle(
                'Weekly Activity',
                'Income and expenses over the last 7 days',
              ),

              const SizedBox(height: 15),

              chartContainer(
                height: 260,
                child: Column(
                  children: [
                    Row(
                      children: [
                        legendItem('Income', AppColors.income),
                        const SizedBox(width: 18),
                        legendItem('Expense', AppColors.expense),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: weeklyChart()),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 28),

              sectionTitle(
                'Expense Breakdown',
                'See which categories use your money',
              ),

              const SizedBox(height: 15),

              chartContainer(
                child: categoryChart(),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        transactions.isEmpty
                            ? 'Add your first transaction to see your financial insights.'
                            : totalExpense == 0
                            ? 'Great! No expenses recorded in this selected period.'
                            : savings >= 0
                            ? 'You have saved ${money(savings)} in the selected period. Keep managing your money wisely!'
                            : 'Your expenses are higher than your income in this selected period. Review your spending.',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
