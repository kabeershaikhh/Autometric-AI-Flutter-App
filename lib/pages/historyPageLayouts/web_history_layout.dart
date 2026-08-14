import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/home_drawer.dart';
import '../../components/recent_tile.dart';
import '../../components/web_sidebar.dart';
import '../../constants/app_colors.dart';
import '../../servers/user_service.dart';
import '../predict_page.dart';

/// Web Dashboard History Layout.
class WebHistoryLayout extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? photoBase64;
  final UserService userService;
  final VoidCallback onLogout;

  const WebHistoryLayout({
    super.key,
    required this.userName,
    required this.userEmail,
    this.photoBase64,
    required this.userService,
    required this.onLogout,
  });

  @override
  State<WebHistoryLayout> createState() => _WebHistoryLayoutState();
}

class _WebHistoryLayoutState extends State<WebHistoryLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openProfileDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _confirmDelete(String docId, String carTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete History Entry",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '$carTitle'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (result == true) {
      await widget.userService.deleteEvaluation(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("History entry deleted."),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showFeatureNotAvailableSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Feature is currently not available"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
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
      body: Row(
        children: [
          // ── LEFT SIDEBAR ──
          WebSidebar(
            selectedIndex: 3, // Highlight History
            onItemTap: (index) {
              if (index == 0) {
                Navigator.pop(context); // Return to Home
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PredictPage(
                      userName: widget.userName,
                      userEmail: widget.userEmail,
                      photoBase64: widget.photoBase64,
                      userService: widget.userService,
                      onLogout: widget.onLogout,
                    ),
                  ),
                );
              } else if (index == 2) {
                _showFeatureNotAvailableSnackBar(context);
              }
            },
            onLogout: widget.onLogout,
            onProfileTap: _openProfileDrawer,
            photoBase64: widget.photoBase64,
          ),

          // ── MAIN CONTENT AREA ──
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 32),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── HERO BANNER ──
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                gradient: AppColors.headerGradient,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -40,
                                    right: -30,
                                    child: const _WebHistoryCircle(150),
                                  ),
                                  Positioned(
                                    bottom: -35,
                                    left: -30,
                                    child: const _WebHistoryCircle(120),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.white
                                                          .withValues(alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: const [
                                                        Icon(Icons.history_edu,
                                                            size: 14,
                                                            color: Colors.amber),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          "Saved Predictions",
                                                          style: TextStyle(
                                                            color: AppColors.white,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              const Text(
                                                "Evaluation History",
                                                style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "View and manage your saved car market valuation predictions.",
                                                style: TextStyle(
                                                  color: AppColors.white
                                                      .withValues(alpha: 0.85),
                                                  fontSize: 14,
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
                                            color: AppColors.white
                                                .withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.history_rounded,
                                            color: AppColors.white,
                                            size: 36,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── HISTORY ITEMS LIST ──
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: widget.userService.allEvaluationsStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: CircularProgressIndicator(
                                          color: AppColors.primary),
                                    ),
                                  );
                                }

                                final docs = snapshot.data?.docs ?? [];
                                if (docs.isEmpty) {
                                  return const EmptyEvaluationsCard();
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final doc = docs[index];
                                    final data = doc.data();
                                    final docId = doc.id;

                                    final carName =
                                        data['carName'] as String? ??
                                            'Unknown Car';
                                    final price =
                                        data['predictedPrice'] as String? ?? '';
                                    final year = data['modelYear'];
                                    final engineCc = data['engineCc'];
                                    final transmission =
                                        data['transmission'] as String?;
                                    final bodyType =
                                        data['bodyType'] as String?;
                                    final city = data['city'] as String?;
                                    final mileage = data['mileageKm'] as String?;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppColors.primaryBorder
                                                .withValues(alpha: 0.5)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.02),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: AppColors.primarySurface,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.directions_car_rounded,
                                              color: AppColors.primary,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  carName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 6,
                                                  children: [
                                                    if (year != null)
                                                      _WebChip(label: "$year"),
                                                    if (engineCc != null)
                                                      _WebChip(label: "$engineCc cc"),
                                                    if (transmission != null)
                                                      _WebChip(label: transmission),
                                                    if (bodyType != null)
                                                      _WebChip(label: bodyType),
                                                    if (mileage != null && mileage.isNotEmpty)
                                                      _WebChip(label: "$mileage km"),
                                                    if (city != null)
                                                      _WebChip(label: city),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                price,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 18,
                                                  color: AppColors.primaryDark,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AppColors.error,
                                                  side: BorderSide(
                                                      color: AppColors.error
                                                          .withValues(alpha: 0.4)),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(10)),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                ),
                                                onPressed: () =>
                                                    _confirmDelete(docId, carName),
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 16),
                                                label: const Text("Delete",
                                                    style: TextStyle(fontSize: 12)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Row(
            children: const [
              Text(
                "Home",
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textGrey),
              ),
              Text(
                "History",
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.textDark),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _openProfileDrawer,
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        widget.userName.isNotEmpty
                            ? widget.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down,
                        color: AppColors.textGrey),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebChip extends StatelessWidget {
  final String label;
  const _WebChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

class _WebHistoryCircle extends StatelessWidget {
  final double size;
  const _WebHistoryCircle(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: 0.06),
      ),
    );
  }
}
