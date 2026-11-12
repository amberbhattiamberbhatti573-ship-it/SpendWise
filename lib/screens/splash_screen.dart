
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
          const OnboardingScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 700),
        ),
      );
    });
  }

  Widget decorativeCircle(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        color: Colors.white.withValues(alpha: 0.025),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -100,
              right: -90,
              child: decorativeCircle(320),
            ),

            Positioned(
              top: -45,
              right: -35,
              child: decorativeCircle(210),
            ),

            Positioned(
              bottom: -120,
              left: -100,
              child: decorativeCircle(350),
            ),

            Positioned(
              bottom: -60,
              left: -50,
              child: decorativeCircle(230),
            ),

            Positioned(
              top: 65,
              left: 30,
              child: Icon(
                Icons.auto_graph_rounded,
                size: 30,
                color: Colors.white.withValues(alpha: 0.18),
              ).animate().fadeIn(delay: 700.ms).scale(),
            ),

            Positioned(
              top: 140,
              right: 35,
              child: Icon(
                Icons.savings_rounded,
                size: 34,
                color: Colors.white.withValues(alpha: 0.20),
              ).animate().fadeIn(delay: 900.ms).rotate(),
            ),

            Positioned(
              bottom: 150,
              left: 40,
              child: Icon(
                Icons.currency_exchange_rounded,
                size: 30,
                color: Colors.white.withValues(alpha: 0.18),
              ).animate().fadeIn(delay: 1100.ms).scale(),
            ),

            Positioned(
              bottom: 190,
              right: 35,
              child: Icon(
                Icons.trending_up_rounded,
                size: 35,
                color: Colors.white.withValues(alpha: 0.20),
              ).animate().fadeIn(delay: 1200.ms).slideY(),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                Container(
                  height: 125,
                  width: 125,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 35,
                        spreadRadius: 2,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 105,
                        width: 105,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient,
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),

                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 58,
                        color: Colors.white,
                      ),

                      const Positioned(
                        bottom: 25,
                        right: 25,
                        child: Icon(
                          Icons.trending_up_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(
                  begin: const Offset(0.3, 0.3),
                  curve: Curves.elasticOut,
                  duration: 1200.ms,
                ),

                const SizedBox(height: 30),

                const Text(
                  'SpendWise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.4),

                const SizedBox(height: 10),

                Text(
                  'SMART MONEY. BETTER FUTURE.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const Spacer(flex: 2),

                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Color(0x557FFFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 16),

                Text(
                  'Your personal finance companion',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 1100.ms),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'VERSION 1.0.0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 9,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
