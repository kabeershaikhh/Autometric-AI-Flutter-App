import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import 'account_dialog.dart';
import 'my_social_button.dart';

/// One Google action shared by login and registration on both platforms.
class GoogleSignInButton extends StatefulWidget {
  final bool enabled;
  final ValueChanged<bool> onBusyChanged;
  final Future<void> Function()? authenticate;

  const GoogleSignInButton({
    super.key,
    required this.enabled,
    required this.onBusyChanged,
    this.authenticate,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _busy = false;

  Future<void> _signIn() async {
    if (_busy || !widget.enabled) return;
    setState(() => _busy = true);
    widget.onBusyChanged(true);
    Object? failure;
    try {
      if (widget.authenticate != null) {
        await widget.authenticate!();
      } else {
        await AuthService().signInWithGoogle();
      }
    } catch (error) {
      failure = error;
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged(false);
      }
    }
    if (mounted &&
        failure != null &&
        !AuthService.isGoogleSignInCancelled(failure)) {
      await showDialog<void>(
        context: context,
        builder: (context) => AccountDialog(
          title: 'Google sign-in',
          icon: Icons.login_rounded,
          content: Text(AuthService.googleSignInErrorMessage(failure!)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => MySocialButton(
    imagePath: 'assets/google.png',
    label: _busy ? 'Signing in…' : 'Continue with Google',
    isLoading: _busy,
    onPressed: widget.enabled && !_busy ? _signIn : null,
  );
}
