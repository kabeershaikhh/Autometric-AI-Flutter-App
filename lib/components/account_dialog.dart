import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'decorated_header.dart';

/// Shared account dialog with the same header and actions as auth confirmations.
class AccountDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final List<Widget> actions;
  final bool busy;

  const AccountDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    required this.actions,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Dialog(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedHeader(title: title, icon: icon),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle(
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                      child: content,
                    ),
                    const SizedBox(height: 24),
                    Theme(
                      data: Theme.of(context).copyWith(
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            foregroundColor: AppColors.primary,
                            backgroundColor: AppColors.primarySurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(
                                color: AppColors.primaryBorder,
                              ),
                            ),
                          ),
                        ),
                        filledButtonTheme: FilledButtonThemeData(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 54),
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Existing callbacks stay unchanged; primary action comes first.
                          for (final action in actions.reversed) ...[
                            Center(
                              child: FractionallySizedBox(
                                widthFactor: 0.82,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: action,
                                ),
                              ),
                            ),
                            if (action != actions.first)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
