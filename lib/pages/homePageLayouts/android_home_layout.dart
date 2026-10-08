import '../../components/app_navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/feature_card.dart';
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
      key: scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,

      ///////////////////////////////////////////////////////
      /// DRAWER
      ///////////////////////////////////////////////////////

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

                  const SizedBox(height: 28),

                  /////////////////////////////////////////////////////
                  /// MARKET CARD
                  /////////////////////////////////////////////////////
                  const MarketCard(),

                  const SizedBox(height: 28),

                  /////////////////////////////////////////////////////
                  /// SECTION TITLE — Recent Evaluations
                  /////////////////////////////////////////////////////
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "Recent Evaluations",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _openHistory,
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          "See All",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /////////////////////////////////////////////////////
                  /// EVALUATIONS LIST (from Firestore)
                  /////////////////////////////////////////////////////
                  _isGuest
                      ? _buildGuestEvaluationsCard()
                      : _buildEvaluationsList(),

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
    );
  }

  ///////////////////////////////////////////////////////
  /// PURPLE CURVED HEADER
  ///////////////////////////////////////////////////////

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

        // Data state — limit to 3 recent items for concise preview
        final recentDocs = docs.take(3).toList();
        return Column(
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
        );
      },
    );
  }

  Widget _buildGuestEvaluationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_rounded, color: AppColors.primary, size: 34),
          const SizedBox(height: 10),
          const Text(
            'Log in to save and view evaluations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _openHistory,
            child: const Text('Log in or create account'),
          ),
        ],
      ),
    );
  }
}
