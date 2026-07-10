import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../constants/app_colors.dart';
import '../servers/user_service.dart';
import 'homePageLayouts/android_home_layout.dart';
import 'homePageLayouts/web_home_layout.dart';

/// The main home page shell.
///
/// Responsibilities:
/// - Listens to the current user's Firestore document in real-time.
/// - Switches between [AndroidHomeLayout] and [WebHomeLayout] based on
///   `kIsWeb && width >= 950`.
/// - Passes user data (name, email, photo) down to both layouts.
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  void logout() {
    _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userService.userStream(),
      builder: (context, snapshot) {
        // Extract user data (with safe defaults)
        final userData = snapshot.data?.data();
        final userName = userData?['name'] as String? ?? 'User';
        final userEmail = userData?['email'] as String? ?? '';
        final photoBase64 = userData?['photoBase64'] as String? ?? '';

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (kIsWeb && constraints.maxWidth >= 950) {
                return WebHomeLayout(
                  onLogout: logout,
                  userName: userName,
                  userEmail: userEmail,
                  photoBase64: photoBase64,
                  userService: _userService,
                );
              }

              return AndroidHomeLayout(
                onLogout: logout,
                userName: userName,
                userEmail: userEmail,
                photoBase64: photoBase64,
                userService: _userService,
              );
            },
          ),
        );
      },
    );
  }
}