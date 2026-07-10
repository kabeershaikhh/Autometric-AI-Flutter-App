import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/feature_card.dart';
import '../../components/home_app_bar.dart';
import '../../components/home_bottom_nav.dart';
import '../../components/home_drawer.dart';
import '../../components/market_card.dart';
import '../../components/recent_tile.dart';
import '../../constants/app_colors.dart';
import '../../servers/user_service.dart';

/// Android / mobile home layout.
///
/// Structure:
///   ┌─ Purple curved header (AppBar + Welcome) ─┐
///   │                                            │
///   ├─ Scrollable body (light bg)               │
///   │   • Market Card                            │
///   │   • Quick Actions (FeatureCards)            │
///   │   • Recent Evaluations (from Firestore)    │
///   ├─ Bottom Navigation Bar                     │
///   └─ End Drawer                                │
class AndroidHomeLayout extends StatefulWidget {
  final VoidCallback onLogout;
  final String userName;
  final String userEmail;
  final String? photoBase64;
  final UserService userService;

  const AndroidHomeLayout({
    super.key,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
    this.photoBase64,
    required this.userService,
  });

  @override
  State<AndroidHomeLayout> createState() => _AndroidHomeLayoutState();
}

class _AndroidHomeLayoutState extends State<AndroidHomeLayout> {
  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,

      ///////////////////////////////////////////////////////
      /// DRAWER
      ///////////////////////////////////////////////////////

      endDrawer: HomeDrawer(
        onLogout: () {
          Navigator.pop(context);
          widget.onLogout();
        },
        userName: widget.userName,
        userEmail: widget.userEmail,
        photoBase64: widget.photoBase64,
        userService: widget.userService,
      ),

      ///////////////////////////////////////////////////////
      /// BODY
      ///////////////////////////////////////////////////////

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /////////////////////////////////////////////////////
            /// PURPLE HEADER (AppBar + Welcome)
            /////////////////////////////////////////////////////

            _buildHeader(),

            /////////////////////////////////////////////////////
            /// CONTENT BODY
            /////////////////////////////////////////////////////

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /////////////////////////////////////////////////////
                  /// SECTION TITLE — Quick Actions
                  /////////////////////////////////////////////////////

                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /////////////////////////////////////////////////////
                  /// FEATURE CARDS (reusable component)
                  /////////////////////////////////////////////////////

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 180,
                          child: FeatureCard(
                            icon: Icons.analytics_outlined,
                            title: "Predict\nPrice",
                            onTap: () {},
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 180,
                          child: FeatureCard(
                            icon: Icons.car_crash_outlined,
                            title: "Damage\nDetection",
                            onTap: () {},
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /////////////////////////////////////////////////////
                  /// MARKET CARD
                  /////////////////////////////////////////////////////

                  const MarketCard(),

                  const SizedBox(height: 28),

                  /////////////////////////////////////////////////////
                  /// SECTION TITLE — Recent Evaluations
                  /////////////////////////////////////////////////////

                  const Text(
                    "Recent Evaluations",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /////////////////////////////////////////////////////
                  /// EVALUATIONS LIST (from Firestore)
                  /////////////////////////////////////////////////////

                  _buildEvaluationsList(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),

      ///////////////////////////////////////////////////////
      /// BOTTOM NAVIGATION
      ///////////////////////////////////////////////////////

      bottomNavigationBar: HomeBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          switch (index) {
            case 0:
              break;
            case 1:
              // TODO Predict Page
              break;
            case 2:
              // TODO Damage Page
              break;
            case 3:
              // TODO History Page
              break;
          }
        },
      ),
    );
  }

  ///////////////////////////////////////////////////////
  /// PURPLE CURVED HEADER
  ///////////////////////////////////////////////////////

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        child: Stack(
          children: [
            // Subtle decorative circles
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: 75,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),

            // Content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// AppBar Row
                    HomeAppBar(
                      onProfileTap: () {
                        scaffoldKey.currentState!.openEndDrawer();
                      },
                      photoBase64: widget.photoBase64,
                    ),

                    const SizedBox(height: 24),

                    /// Welcome Greeting
                    Text(
                      "Welcome back,",
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.8),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${widget.userName}! 👋",
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Let's evaluate your car today",
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////
  /// EVALUATIONS LIST — REAL-TIME FROM FIRESTORE
  ///////////////////////////////////////////////////////

  Widget _buildEvaluationsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.userService.evaluationsStream(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        // Empty state
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const EmptyEvaluationsCard();
        }

        // Data state
        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final title = data['carName'] as String? ?? 'Unknown Car';
            final price = data['predictedPrice'] as String? ?? '';
            return RecentTile(
              title: title,
              price: price,
            );
          }).toList(),
        );
      },
    );
  }
}