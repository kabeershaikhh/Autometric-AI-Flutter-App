import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Permanent sidebar navigation for the web dashboard layout.
/// Shows logo, nav items, profile avatar (tappable), and logout.
/// Profile avatar opens the endDrawer for editing name/photo.
class WebSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final VoidCallback onLogout;
  final VoidCallback onProfileTap;
  final String? photoBase64;

  const WebSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required this.onLogout,
    required this.onProfileTap,
    this.photoBase64,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        width: 260,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A3DE8),
              AppColors.primary,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -60,
              right: -50,
              child: _SidebarCircle(180),
            ),
            Positioned(
              bottom: -70,
              left: -40,
              child: _SidebarCircle(200),
            ),
            Positioned(
              top: 200,
              right: -30,
              child: _SidebarCircle(90),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [

                  // ── TOP: Logo (fixed) ──
                  const SizedBox(height: 24),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset("assets/AutoMetricAI.png"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "AutoMetric AI",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "AI Powered Valuation",
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── MIDDLE: Nav items (scrollable if height is small) ──
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _SidebarItem(
                            icon: Icons.home_outlined,
                            selectedIcon: Icons.home,
                            label: "Home",
                            isSelected: selectedIndex == 0,
                            onTap: () => onItemTap(0),
                          ),
                          _SidebarItem(
                            icon: Icons.analytics_outlined,
                            selectedIcon: Icons.analytics,
                            label: "Predict Price",
                            isSelected: selectedIndex == 1,
                            onTap: () => onItemTap(1),
                          ),
                          _SidebarItem(
                            icon: Icons.car_crash_outlined,
                            selectedIcon: Icons.car_crash,
                            label: "Damage Detection",
                            isSelected: selectedIndex == 2,
                            onTap: () => onItemTap(2),
                          ),
                          _SidebarItem(
                            icon: Icons.history_outlined,
                            selectedIcon: Icons.history,
                            label: "History",
                            isSelected: selectedIndex == 3,
                            onTap: () => onItemTap(3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Logout button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onLogout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: AppColors.white,
                                size: 19,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Decorative circle for drawer header.
class _SidebarCircle extends StatelessWidget {
  final double size;
  const _SidebarCircle(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}

/// A single navigation item in the sidebar.
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.white.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: AppColors.white,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
