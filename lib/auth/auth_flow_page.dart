import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_or_register.dart';
import 'auth_service.dart';

/// Hosts login/registration as a route and closes itself after authentication.
class AuthFlowPage extends StatefulWidget {
  final bool initialShowLogin;

  const AuthFlowPage({super.key, this.initialShowLogin = true});

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  StreamSubscription<User?>? _authSubscription;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    AuthService.googleSignInInProgress.addListener(_finishAuthentication);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _finishAuthentication();
    });
  }

  void _finishAuthentication() {
    if (!_finished &&
        !AuthService.googleSignInInProgress.value &&
        FirebaseAuth.instance.currentUser != null &&
        mounted) {
      _finished = true;
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    AuthService.googleSignInInProgress.removeListener(_finishAuthentication);
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginOrRegister(initialShowLogin: widget.initialShowLogin);
  }
}
