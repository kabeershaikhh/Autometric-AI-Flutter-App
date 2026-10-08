import '../../components/app_navigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/feature_card.dart';
import '../../components/market_card.dart';
import '../../components/recent_tile.dart';
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

  bool get _isGuest => FirebaseAuth.instance.currentUser == null;

  String? _evaluationUid;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _evaluations;

  Stream<QuerySnapshot<Map<String, dynamic>>> _evaluationStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_evaluations == null || uid != _evaluationUid) {
      _evaluationUid = uid;
      _evaluations = widget.userService.evaluationsStream();
    }
    return _evaluations!;
  }

  Future<void> _openHistory() => AppNavigation.select(context, 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,

      ///////////////////////////////////////////////////////
      /// END DRAWER — same HomeDrawer as Android
      ///////////////////////////////////////////////////////

      ///////////////////////////////////////////////////////
      /// BODY — Sidebar + Main Content
      ///////////////////////////////////////////////////////
      body: Row(
        children: [
          ///////////////////////////////////////////////////////
          /// LEFT SIDEBAR
          ///////////////////////////////////////////////////////

          ///////////////////////////////////////////////////////
          /// MAIN CONTENT AREA
          ///////////////////////////////////////////////////////
          Expanded(
            child: Column(
              children: [
                /// Top Bar

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
                                  const Expanded(flex: 3, child: MarketCard()),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Recent Evaluations",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _openHistory,
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                "See All",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        _isGuest
                            ? _buildGuestEvaluationsCard()
                            : _buildEvaluationsList(),

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
                  onTap: () {
                    AppNavigation.select(context, 1);
                  },
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 180,
                child: FeatureCard(
                  icon: Icons.build_outlined,
                  title: "Maintenance",
                  onTap: () => AppNavigation.select(context, 2),
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
      stream: _evaluationStream(),
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

        // Data state — limit to 3 recent items for concise preview
        final recentDocs = docs.take(3).toList();
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: recentDocs.map((doc) {
              final data = doc.data();
              final title = data['carName'] as String? ?? 'Unknown Car';
              final price = data['predictedPrice'] as String? ?? '';
              return RecentTile(
                title: title,
                price: price,
                onTap: () {
                  AppNavigation.select(context, 3);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildGuestEvaluationsCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
              size: 38,
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log in to save and view evaluations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your saved vehicle valuations will appear here.',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: _openHistory, child: const Text('Log in')),
          ],
        ),
      ),
    );
  }
}
