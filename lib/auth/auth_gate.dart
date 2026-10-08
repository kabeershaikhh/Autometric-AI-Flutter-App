import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../pages/splash_page.dart';
import 'welcome_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _guestMode = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashPage();
        }

        if (snapshot.hasData) _guestMode = false;

        if (snapshot.hasData || _guestMode) {
          return HomePage(
            onLoggedOut: () {
              if (mounted) setState(() => _guestMode = false);
            },
          );
        }

        return WelcomePage(
          onContinueAsGuest: () => setState(() => _guestMode = true),
        );
      },
    );
  }
}
