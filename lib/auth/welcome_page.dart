import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../components/auth_action_button.dart';
import 'auth_flow_page.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onContinueAsGuest;

  const WelcomePage({super.key, required this.onContinueAsGuest});

  Future<void> _openAuth(BuildContext context, bool showLogin) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AuthFlowPage(initialShowLogin: showLogin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 950;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: isWide
                        ? AppColors.authWebGradient
                        : AppColors.authMobileGradient,
                  ),
                ),
              ),
              const Positioned(
                top: -110,
                right: -75,
                child: _WelcomeCircle(size: 300),
              ),
              const Positioned(
                bottom: -130,
                left: -90,
                child: _WelcomeCircle(size: 350),
              ),
              const Positioned(
                top: 180,
                left: -45,
                child: _WelcomeCircle(size: 130),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 64 : 24,
                    vertical: isWide ? 44 : 30,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                          MediaQuery.paddingOf(context).vertical -
                          (isWide ? 88 : 60),
                    ),
                    child: Center(
                      child: isWide
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Flexible(
                                  child: _WelcomeBranding(isWide: true),
                                ),
                                SizedBox(
                                  width: (constraints.maxWidth * 0.08).clamp(
                                    50.0,
                                    130.0,
                                  ),
                                ),
                                Flexible(
                                  child: _WelcomeActionCard(
                                    onLogin: () => _openAuth(context, true),
                                    onRegister: () => _openAuth(context, false),
                                    onContinueAsGuest: onContinueAsGuest,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const _WelcomeBranding(isWide: false),
                                const SizedBox(height: 34),
                                _WelcomeActionCard(
                                  onLogin: () => _openAuth(context, true),
                                  onRegister: () => _openAuth(context, false),
                                  onContinueAsGuest: onContinueAsGuest,
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

class _WelcomeBranding extends StatelessWidget {
  final bool isWide;

  const _WelcomeBranding({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Column(
        crossAxisAlignment: isWide
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: isWide ? 100 : 88,
            height: isWide ? 100 : 88,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset('assets/AutoMetricAI.png'),
          ),
          SizedBox(height: isWide ? 30 : 20),
          Text(
            'AutoMetric AI',
            textAlign: isWide ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: isWide ? 46 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Smart Car Estimation',
            textAlign: isWide ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: isWide ? 21 : 16,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          if (isWide) ...[
            const SizedBox(height: 42),
            const _BenefitRow(
              icon: Icons.auto_awesome_rounded,
              text: 'AI-powered vehicle estimates',
            ),
            const SizedBox(height: 18),
            const _BenefitRow(
              icon: Icons.person_outline_rounded,
              text: 'Try price prediction as a guest',
            ),
            const SizedBox(height: 18),
            const _BenefitRow(
              icon: Icons.bookmark_outline_rounded,
              text: 'Sign in to save your evaluations',
            ),
          ],
        ],
      ),
    );
  }
}

class _WelcomeActionCard extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onContinueAsGuest;

  const _WelcomeActionCard({
    required this.onLogin,
    required this.onRegister,
    required this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 470),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 18),
          const Text(
            'How would you like to continue?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Use price prediction freely, or sign in to save results and access account features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 28),
          AuthActionButton(
            label: 'Log in',
            icon: Icons.login_rounded,
            onPressed: onLogin,
            compact: true,
          ),
          const SizedBox(height: 12),
          AuthActionButton(
            label: 'Create account',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: onRegister,
            compact: true,
            outlined: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppColors.divider)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.divider)),
              ],
            ),
          ),
          AuthActionButton(
            label: 'Continue without an account',
            icon: Icons.arrow_forward_rounded,
            onPressed: onContinueAsGuest,
            compact: true,
            outlined: true,
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ],
    );
  }
}

class _WelcomeCircle extends StatelessWidget {
  final double size;

  const _WelcomeCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}
