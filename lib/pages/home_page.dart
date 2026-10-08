import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../servers/user_service.dart';
import 'app_shell.dart';

/// Streams profile updates into the persistent responsive application shell.
class HomePage extends StatelessWidget {
  final VoidCallback onLoggedOut;

  HomePage({super.key, required this.onLoggedOut});

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  Future<void> logout(BuildContext context) async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    await _authService.signOut();
    onLoggedOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userService.userStream(),
      builder: (context, snapshot) {
        // Extract user data (with safe defaults)
        final userData = snapshot.data?.data();
        final userName =
            userData?['name'] as String? ??
            (FirebaseAuth.instance.currentUser == null ? 'Guest' : 'User');
        final userEmail = userData?['email'] as String? ?? '';
        final photoBase64 = userData?['photoBase64'] as String? ?? '';

        return _buildHome(
          context,
          userName: userName,
          userEmail: userEmail,
          photoBase64: photoBase64,
        );
      },
    );
  }

  Widget _buildHome(
    BuildContext context, {
    required String userName,
    required String userEmail,
    required String photoBase64,
  }) {
    return AppShell(
      onLogout: () => logout(context),
      userName: userName,
      userEmail: userEmail,
      photoBase64: photoBase64,
      userService: _userService,
    );
  }
}
