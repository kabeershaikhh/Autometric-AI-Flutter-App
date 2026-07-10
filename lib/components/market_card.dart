import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Market outlook stats card for the home page.
/// Shared between Android and Web layouts.
class MarketCard extends StatelessWidget {
  const MarketCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEE6FF),
            Color(0xFFF8F5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primaryBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //////////////////////////////////////////////////////
          /// TOP
          //////////////////////////////////////////////////////

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Market Outlook",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Updated Today",
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "2.8%",
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          //////////////////////////////////////////////////////
          /// DESCRIPTION
          //////////////////////////////////////////////////////

          const Text(
            "Used car prices remain stable this week with increased demand for SUVs and hatchbacks across major Pakistani cities.",
            style: TextStyle(
              color: AppColors.textLight,
              height: 1.6,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          //////////////////////////////////////////////////////
          /// STATS
          //////////////////////////////////////////////////////

          const Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.location_on_outlined,
                  value: "15+",
                  title: "Cities",
                ),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.directions_car_outlined,
                  value: "10k+",
                  title: "Cars",
                ),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.analytics_outlined,
                  value: "98%",
                  title: "Predictions",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const _InfoTile({
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}