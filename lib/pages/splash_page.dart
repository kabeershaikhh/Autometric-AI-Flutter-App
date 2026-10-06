import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Branded startup screen using the same responsive backdrop as login.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 950;
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: wide
                        ? AppColors.authWebGradient
                        : AppColors.authMobileGradient,
                  ),
                ),
              ),
              Positioned(
                top: wide ? -120 : -80,
                right: wide ? -80 : -50,
                child: _SplashCircle(size: wide ? 320 : 220),
              ),
              Positioned(
                bottom: wide ? -140 : -100,
                left: wide ? -100 : -60,
                child: _SplashCircle(size: wide ? 380 : 260),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: wide ? 144 : 120,
                            height: wide ? 144 : 120,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF482199,
                                  ).withValues(alpha: 0.20),
                                  blurRadius: 35,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/AutoMetricAI.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'AutoMetric AI',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: wide ? 42 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Smart Car Estimation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 34),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashCircle extends StatelessWidget {
  final double size;

  const _SplashCircle({required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: 0.08),
    ),
  );
}
