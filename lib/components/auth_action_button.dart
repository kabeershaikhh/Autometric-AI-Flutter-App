import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Compact authentication action with the app's rounded, decorated styling.
class AuthActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool outlined;
  final bool compact;

  const AuthActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = outlined ? AppColors.primary : Colors.white;
    return Center(
      child: FractionallySizedBox(
        widthFactor: compact ? 0.82 : 0.86,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: compact ? 300 : 320,
            minHeight: compact ? 54 : 62,
          ),
          child: Material(
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            color: outlined ? AppColors.primarySurface : AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: outlined
                      ? Border.all(color: AppColors.primaryBorder)
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: compact ? 16 : 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 22, color: foreground),
                          const SizedBox(width: 10),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }
}

class _ButtonCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _ButtonCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.10),
    ),
  );
}
