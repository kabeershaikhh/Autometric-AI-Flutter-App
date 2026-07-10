import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A reusable tile for displaying a recent evaluation entry.
/// Used by both Android and Web home layouts.
class RecentTile extends StatelessWidget {
  final String title;
  final String price;
  final IconData icon;
  final VoidCallback? onTap;

  const RecentTile({
    super.key,
    required this.title,
    required this.price,
    this.icon = Icons.directions_car,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: AppColors.primaryBorder.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          price,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.primary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Displayed when the user has no evaluation history yet.
/// Used by both Android and Web home layouts.
class EmptyEvaluationsCard extends StatelessWidget {
  const EmptyEvaluationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBorder.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.history_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No evaluations yet",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start by predicting a car's value\nor running a damage detection!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
