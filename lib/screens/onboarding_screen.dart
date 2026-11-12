
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<_OnboardingData> pages = [
    _OnboardingData(
      tag: 'SMART FINANCE',
      title: 'Manage Your Money',
      description:
      'Keep all your income and expenses in one place. '
          'Understand your spending and take control of your finances.',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.primary,
      secondaryIcon: Icons.trending_up_rounded,
      amount: 'Rs. 45,850',
      subtitle: 'Total Balance',
    ),
    _OnboardingData(
      tag: 'TRACK EVERY EXPENSE',
      title: 'Track Every Expense',
      description:
      'Record your daily spending, organize transactions by category '
          'and know exactly where your money goes.',
      icon: Icons.receipt_long_rounded,
      color: AppColors.secondary,
      secondaryIcon: Icons.shopping_bag_rounded,
      amount: 'Rs. 2,450',
      subtitle: 'Monthly Expenses',
    ),
    _OnboardingData(
      tag: 'BUILD YOUR FUTURE',
      title: 'Save More, Stress Less',
      description:
      'View your financial reports, understand your habits '
          'and make smarter decisions to reach your saving goals.',
      icon: Icons.savings_rounded,
      color: AppColors.income,
      secondaryIcon: Icons.auto_graph_rounded,
      amount: '75%',
      subtitle: 'Saving Progress',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      openLogin();
    }
  }

  void openLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Widget buildIllustration(_OnboardingData data) {
    return Container(
      width: double.infinity,
      height: 350,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withValues(alpha: 0.07),
            ),
          ),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: data.color.withValues(alpha: 0.18),
                width: 1.5,
              ),
            ),
          ),
          Positioned(
            top: 35,
            right: 35,
            child: _floatingIcon(
              Icons.attach_money_rounded,
              data.color,
            ),
          ),
          Positioned(
            bottom: 48,
            left: 28,
            child: _floatingIcon(
              data.secondaryIcon,
              AppColors.sky,
            ),
          ),
          Positioned(
            top: 75,
            left: 38,
            child: _floatingIcon(
              Icons.stars_rounded,
              AppColors.warning,
            ),
          ),
          Container(
            width: 155,
            height: 155,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  data.color,
                  data.color.withValues(alpha: 0.65),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(42),
              boxShadow: [
                BoxShadow(
                  color: data.color.withValues(alpha: 0.35),
                  blurRadius: 35,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              color: Colors.white,
              size: 78,
            ),
          ),
          Positioned(
            bottom: 25,
            child: Container(
              width: 230,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.09),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      data.secondaryIcon,
                      color: data.color,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.subtitle,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.amount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle_rounded,
                    color: data.color,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingIcon(IconData icon, Color color) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 15,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 23,
      ),
    );
  }

  Widget buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pages.length,
            (index) {
          final selected = currentPage == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 7,
            width: selected ? 27 : 7,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : AppColors.textGrey.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 15, 22, 0),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SpendWise',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (currentPage != pages.length - 1)
                    TextButton(
                      onPressed: openLogin,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = pages[index];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 5),

                              buildIllustration(data),

                              const SizedBox(height: 15),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: data.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  data.tag,
                                  style: TextStyle(
                                    color: data.color,
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                ),
                                child: Text(
                                  data.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 29,
                                    height: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 13),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  data.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                    height: 1.8,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
              child: Column(
                children: [
                  buildIndicators(),

                  const SizedBox(height: 27),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor:
                        AppColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentPage == pages.length - 1
                                ? 'Get Started'
                                : 'Continue',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  Text(
                    'PAGE ${currentPage + 1} OF ${pages.length}',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String tag;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final IconData secondaryIcon;
  final String amount;
  final String subtitle;

  const _OnboardingData({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.secondaryIcon,
    required this.amount,
    required this.subtitle,
  });
}
