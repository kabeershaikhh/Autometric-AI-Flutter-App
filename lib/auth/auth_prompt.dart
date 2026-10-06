import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../components/auth_action_button.dart';
import 'auth_flow_page.dart';

/// Prompts a guest to log in and returns true after successful authentication.
/// Registration remains available from the login page itself.
Future<bool> requireAuthentication(
  BuildContext context, {
  required String feature,
}) async {
  if (FirebaseAuth.instance.currentUser != null) return true;

  final goToLogin = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.48),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 440),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -48,
                    right: -42,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.09),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -44,
                    left: -36,
                    child: Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.09),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.24),
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 31,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Log in to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
              child: Column(
                children: [
                  Text(
                    'You need an account to $feature.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can create an account from the login page if you do not have one yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthActionButton(
                    label: 'Go to login',
                    icon: Icons.login_rounded,
                    compact: true,
                    onPressed: () => Navigator.pop(dialogContext, true),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.82,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        foregroundColor: AppColors.textLight,
                        backgroundColor: AppColors.primarySurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text(
                        'Not now',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

  if (goToLogin != true || !context.mounted) return false;

  final authenticated = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => const AuthFlowPage(initialShowLogin: true),
    ),
  );

  return authenticated == true && FirebaseAuth.instance.currentUser != null;
}
