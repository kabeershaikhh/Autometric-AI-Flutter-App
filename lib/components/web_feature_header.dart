import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Shared hero for the web navigation pages; only page content varies.
class WebFeatureHeader extends StatelessWidget {
  final String badge;
  final IconData badgeIcon;
  final String title;
  final String subtitle;
  final IconData icon;

  const WebFeatureHeader({
    super.key,
    required this.badge,
    required this.badgeIcon,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      gradient: AppColors.headerGradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Stack(
      children: [
        const Positioned(top: -40, right: -30, child: _Circle(150)),
        const Positioned(bottom: -35, left: -30, child: _Circle(120)),
        const Positioned(bottom: -40, right: 110, child: _Circle(95)),
        Padding(
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 14, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(
                            badge,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Reserve the same two-line description space on each page.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            40 * MediaQuery.textScalerOf(context).scale(1),
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.white, size: 36),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Circle extends StatelessWidget {
  final double size;
  const _Circle(this.size);
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: 0.08),
      shape: BoxShape.circle,
    ),
  );
}
