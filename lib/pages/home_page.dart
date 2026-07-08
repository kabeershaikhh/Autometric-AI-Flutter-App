import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import 'homePageLayouts/android_home_layout.dart';
import 'homePageLayouts/web_home_layout.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthService _authService = AuthService();

  void logout() {
    _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: LayoutBuilder(
        builder: (context, constraints) {

          if (kIsWeb && constraints.maxWidth >= 950) {
            return WebHomeLayout(
              onLogout: logout,
            );
          }

          return AndroidHomeLayout(
            onLogout: logout,
          );
        },
      ),
    );
  }
}