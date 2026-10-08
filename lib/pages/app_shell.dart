import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/auth_flow_page.dart';
import '../auth/auth_prompt.dart';
import '../components/app_navigation.dart';
import '../components/home_app_bar.dart';
import '../components/home_bottom_nav.dart';
import '../components/home_drawer.dart';
import '../components/web_page_header.dart';
import '../components/web_sidebar.dart';
import '../constants/app_colors.dart';
import '../servers/user_service.dart';
import 'history_page.dart';
import 'homePageLayouts/android_home_layout.dart';
import 'homePageLayouts/web_home_layout.dart';
import 'predict_page.dart';
import 'settings_page.dart';

/// Owns the persistent header, navigation, profile drawer and tab state.
class AppShell extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String photoBase64;
  final UserService userService;
  final VoidCallback onLogout;

  const AppShell({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.photoBase64,
    required this.userService,
    required this.onLogout,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = PageController();
  final _visited = <int>{0};
  int _selected = 0;
  bool _authPending = false;
  bool get _guest => FirebaseAuth.instance.currentUser == null;

  static const _titles = ['Home', 'Predict Price', 'Maintenance', 'History'];
  static const _subtitles = [
    'Smart vehicle insights, all in one place',
    'Estimate your vehicle’s market value',
    'Care for your vehicle',
    'Your saved price predictions',
  ];

  Future<void> _select(int index) async {
    if (index == _selected || _authPending) return;
    if (_guest && index >= 2) {
      _authPending = true;
      final allowed = await requireAuthentication(
        context,
        feature: index == 2
            ? 'use Maintenance'
            : index == 3
            ? 'view evaluation history'
            : 'manage account settings',
      );
      _authPending = false;
      if (!allowed || !mounted) return;
    }
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (index == 4) {
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute(builder: (_) => const SettingsPage()));
      return;
    }
    setState(() {
      _visited.add(index);
      _selected = index;
    });
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _profile() async {
    if (!await requireAuthentication(context, feature: 'manage your profile') ||
        !mounted) {
      return;
    }
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = kIsWeb && MediaQuery.sizeOf(context).width >= 950;
    final header = wide
        ? WebPageHeader(
            section: _titles[_selected],
            userName: widget.userName,
            photoBase64: widget.photoBase64,
            onHome: () => _select(0),
            onProfile: _profile,
          )
        : _ShellHeader(
            title: _selected == 0
                ? 'Welcome, ${widget.userName}!'
                : _titles[_selected],
            subtitle: _subtitles[_selected],
            photoBase64: widget.photoBase64,
            onProfile: _profile,
          );
    final content = Column(
      children: [
        header,
        Expanded(
          child: PageView(
            controller: _controller,
            // Authentication is checked before navigating to protected tabs.
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              4,
              (index) => _KeepTabAlive(
                key: ValueKey(index),
                child: _visited.contains(index)
                    ? _page(index, wide)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ],
    );
    return AppNavigation(
      onSelect: _select,
      onProfile: _profile,
      child: PopScope(
        canPop: _selected == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _select(0);
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.scaffoldBg,
          endDrawer: _guest
              ? null
              : HomeDrawer(
                  onLogout: widget.onLogout,
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  photoBase64: widget.photoBase64,
                  userService: widget.userService,
                ),
          body: wide
              ? Row(
                  children: [
                    WebSidebar(
                      selectedIndex: _selected,
                      onItemTap: _select,
                      onLogout: widget.onLogout,
                      onProfileTap: _profile,
                      isGuest: _guest,
                      onLogin: () => Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => const AuthFlowPage()),
                      ),
                      photoBase64: widget.photoBase64,
                    ),
                    Expanded(child: content),
                  ],
                )
              : content,
          bottomNavigationBar: wide
              ? null
              : HomeBottomNav(currentIndex: _selected, onTap: _select),
        ),
      ),
    );
  }

  Widget _page(int index, bool wide) {
    switch (index) {
      case 0:
        return wide
            ? WebHomeLayout(
                onLogout: widget.onLogout,
                userName: widget.userName,
                userEmail: widget.userEmail,
                photoBase64: widget.photoBase64,
                userService: widget.userService,
              )
            : AndroidHomeLayout(
                onLogout: widget.onLogout,
                userName: widget.userName,
                userEmail: widget.userEmail,
                photoBase64: widget.photoBase64,
                userService: widget.userService,
              );
      case 1:
        return PredictPage(
          userName: widget.userName,
          userEmail: widget.userEmail,
          photoBase64: widget.photoBase64,
          userService: widget.userService,
          onLogout: widget.onLogout,
        );
      case 2:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.build_outlined, size: 56, color: AppColors.primary),
                SizedBox(height: 20),
                Text(
                  'Maintenance is coming soon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Vehicle maintenance tools will be available here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        );
      case 3:
        return HistoryPage(
          userName: widget.userName,
          userEmail: widget.userEmail,
          photoBase64: widget.photoBase64,
          userService: widget.userService,
          onLogout: widget.onLogout,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _KeepTabAlive extends StatefulWidget {
  final Widget child;
  const _KeepTabAlive({super.key, required this.child});
  @override
  State<_KeepTabAlive> createState() => _KeepTabAliveState();
}

class _KeepTabAliveState extends State<_KeepTabAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _ShellHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String photoBase64;
  final VoidCallback onProfile;
  const _ShellHeader({
    required this.title,
    required this.subtitle,
    required this.photoBase64,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: const BoxDecoration(
      gradient: AppColors.headerGradient,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    child: Stack(
      children: [
        Positioned(top: -50, right: -35, child: _circle(150)),
        Positioned(bottom: -55, left: -30, child: _circle(130)),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeAppBar(onProfileTap: onProfile, photoBase64: photoBase64),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: 0.08),
    ),
  );
}
