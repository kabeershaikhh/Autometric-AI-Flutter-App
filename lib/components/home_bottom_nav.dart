import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Bottom navigation bar for the Android/mobile home layout.
/// Uses the app's purple accent for selection indicators.
class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        height: 72,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.textGrey),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.analytics_outlined, color: AppColors.textGrey),
            selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
            label: "Predict",
          ),

          NavigationDestination(
            icon: Icon(Icons.car_crash_outlined, color: AppColors.textGrey),
            selectedIcon: Icon(Icons.car_crash, color: AppColors.primary),
            label: "Damage",
          ),

          NavigationDestination(
            icon: Icon(Icons.history_outlined, color: AppColors.textGrey),
            selectedIcon: Icon(Icons.history, color: AppColors.primary),
            label: "History",
          ),
        ],
      ),
    );
  }
}