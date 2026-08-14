import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../servers/user_service.dart';
import 'historyPageLayouts/android_history_layout.dart';
import 'historyPageLayouts/web_history_layout.dart';

/// The History Page shell that routes between Android and Web layouts.
class HistoryPage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? photoBase64;
  final UserService userService;
  final VoidCallback onLogout;

  const HistoryPage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.photoBase64,
    required this.userService,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (kIsWeb && constraints.maxWidth >= 950) {
            return WebHistoryLayout(
              userName: userName,
              userEmail: userEmail,
              photoBase64: photoBase64,
              userService: userService,
              onLogout: onLogout,
            );
          }

          return AndroidHistoryLayout(
            userName: userName,
            userEmail: userEmail,
            photoBase64: photoBase64,
            userService: userService,
            onLogout: onLogout,
          );
        },
      ),
    );
  }
}
