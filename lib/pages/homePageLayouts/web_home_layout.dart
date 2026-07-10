import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/feature_card.dart';
import '../../components/home_drawer.dart';
import '../../components/market_card.dart';
import '../../components/recent_tile.dart';
import '../../components/web_sidebar.dart';
import '../../constants/app_colors.dart';
import '../../servers/user_service.dart';

/// Web dashboard home layout (displayed when kIsWeb && width >= 950).
///
/// Structure:
///   ┌────────────┬───────────────────────────────────────┐
///   │            │  Top Bar (welcome + notification)     │
///   │  Sidebar   ├───────────────────────────────────────┤
///   │  (purple)  │  Main content area (scrollable)       │
///   │            │  • Market Card + Quick Actions (row)  │
///   │            │  • Recent Evaluations                 │
///   └────────────┴───────────────────────────────────────┘
///
/// Clicking profile avatar (sidebar or top bar) opens an endDrawer
/// with the same [HomeDrawer] used on Android for editing name/photo.
class WebHomeLayout extends StatefulWidget {
  final VoidCallback onLogout;
  final String userName;
  final String userEmail;
  final String? photoBase64;
  final UserService userService;

  const WebHomeLayout({
    super.key,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
    this.photoBase64,
    required this.userService,
  });

  @override
  State<WebHomeLayout> createState() => _WebHomeLayoutState();
}

class _WebHomeLayoutState extends State<WebHomeLayout> {
  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openProfileDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,

      ///////////////////////////////////////////////////////
      /// END DRAWER — same HomeDrawer as Android
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
      /// BODY — Sidebar + Main Content
      ///////////////////////////////////////////////////////

      body: Row(
        children: [

          ///////////////////////////////////////////////////////
          /// LEFT SIDEBAR
          ///////////////////////////////////////////////////////

          WebSidebar(
            selectedIndex: selectedIndex,
            onItemTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            onLogout: widget.onLogout,
            onProfileTap: _openProfileDrawer,
            photoBase64: widget.photoBase64,
          ),

          ///////////////////////////////////////////////////////
          /// MAIN CONTENT AREA
          ///////////////////////////////////////////////////////

          Expanded(
            child: Column(
              children: [

                /// Top Bar
                _buildTopBar(),

                /// Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /////////////////////////////////////////////////////
                        /// TOP ROW — Market Card + Quick Actions
                        /////////////////////////////////////////////////////

                        LayoutBuilder(
                          builder: (context, constraints) {
                            // If wide enough, show side-by-side
                            if (constraints.maxWidth >= 800) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Quick Actions — left
                                  Expanded(
                                    flex: 2,
                                    child: _buildQuickActions(),
                                  ),
                                  const SizedBox(width: 24),
                                  // Market Card — right
                                  const Expanded(
                                    flex: 3,
                                    child: MarketCard(),
                                  ),
                                ],
                              );
                            }

                            // Otherwise stack vertically
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildQuickActions(),
                                const SizedBox(height: 24),
                                const MarketCard(),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        /////////////////////////////////////////////////////
                        /// RECENT EVALUATIONS
                        /////////////////////////////////////////////////////

                        const Text(
                          "Recent Evaluations",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildEvaluationsList(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////
  /// TOP BAR
  ///////////////////////////////////////////////////////

  Widget _buildTopBar() {
    final Uint8List? photoBytes =
        UserService.decodePhoto(widget.photoBase64);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Welcome text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, ${widget.userName}! 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Let's evaluate your car today",
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Notification
          Container(
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Profile avatar — opens drawer
          GestureDetector(
            onTap: _openProfileDrawer,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primarySurface,
              backgroundImage:
                  photoBytes != null ? MemoryImage(photoBytes) : null,
              child: photoBytes == null
                  ? const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////
  /// QUICK ACTIONS (reuses FeatureCard)
  ///////////////////////////////////////////////////////

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
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
      ],
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
              padding: EdgeInsets.all(32),
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

        // Data state — show in a constrained width for readability
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: docs.map((doc) {
              final data = doc.data();
              final title = data['carName'] as String? ?? 'Unknown Car';
              final price = data['predictedPrice'] as String? ?? '';
              return RecentTile(
                title: title,
                price: price,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}