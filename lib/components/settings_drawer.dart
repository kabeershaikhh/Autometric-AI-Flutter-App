import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../constants/app_colors.dart';

/// Settings drawer that slides in when "Settings" is tapped from HomeDrawer.
/// Provides:
///   • Change Password (in-app with re-authentication)
///   • Send Password Reset Link (fallback)
class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            //////////////////////////////////////
            /// HEADER
            //////////////////////////////////////

            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Stack(
                  children: [
                    // Smooth, large decorative circles like rest of the app
                    Positioned(
                      top: -20,
                      right: -10,
                      child: _SettingsCircle(80),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -10,
                      child: _SettingsCircle(80),
                    ),

                    // Content with inner padding
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Column(
                        children: [
                          // Back button row
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Settings",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            //////////////////////////////////////
            /// SETTINGS ITEMS
            //////////////////////////////////////

            // ── Security Section ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Security",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            _SettingsItem(
              icon: Icons.lock_outline,
              title: "Change Password",
              subtitle: "Update your password in-app",
              onTap: () => _showChangePasswordDialog(context),
            ),

            _SettingsItem(
              icon: Icons.email_outlined,
              title: "Send Reset Link",
              subtitle: "Receive a password reset email",
              onTap: () => _sendResetLink(context),
            ),

            const Spacer(),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "AutoMetric AI v1.0.0",
                style: TextStyle(
                  color: AppColors.textGrey.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// In-app password change dialog.
  /// Asks for current password + new password, then uses Firebase re-auth.
  void _showChangePasswordDialog(BuildContext context) {
    final currentPwdController = TextEditingController();
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary, size: 24),
              SizedBox(width: 10),
              Text(
                "Change Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontSize: 19,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 360,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  _PasswordField(
                    controller: currentPwdController,
                    hint: "Current Password",
                    icon: Icons.lock_outline,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Required" : null,
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: newPwdController,
                    hint: "New Password",
                    icon: Icons.lock_reset,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required";
                      if (v.length < 6) return "At least 6 characters";
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: confirmPwdController,
                    hint: "Confirm New Password",
                    icon: Icons.lock_reset,
                    validator: (v) {
                      if (v != newPwdController.text) {
                        return "Passwords don't match";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setDialogState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        final authService = AuthService();
                        await authService.changePassword(
                          currentPwdController.text,
                          newPwdController.text,
                        );

                        if (context.mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password changed successfully! ✓"),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      } catch (e) {
                        String msg = e.toString();
                        // Make Firebase errors more user-friendly
                        if (msg.contains('wrong-password') ||
                            msg.contains('invalid-credential')) {
                          msg = "Current password is incorrect.";
                        } else if (msg.contains('weak-password')) {
                          msg = "New password is too weak.";
                        } else if (msg.contains('requires-recent-login')) {
                          msg =
                              "Session expired. Please log out and log in again.";
                        } else {
                          msg = "Failed to change password. Please try again.";
                        }
                        setDialogState(() {
                          isLoading = false;
                          errorMessage = msg;
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }

  /// Sends a password reset link to the user's email.
  void _sendResetLink(BuildContext context) async {
    final authService = AuthService();
    final email = authService.currentUserEmail;

    if (email == null || email.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to get your email address."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Confirm before sending
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          "Send Reset Link",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          "A password reset link will be sent to:\n\n$email\n\nYou'll be signed out after the link is sent.",
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Send Link"),
          ),
        ],
      ),
    );

    if (shouldSend != true) return;

    try {
      await authService.sendPasswordResetEmail(email);
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reset link sent to $email. Signing you out..."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
        await authService.signOut();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send reset link. Please try again."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// A settings list item with icon, title, subtitle, and chevron.
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        horizontalTitleGap: 12,
        minLeadingWidth: 38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            fontSize: 14.5,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textGrey.withValues(alpha: 0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Styled password text field with visibility toggle for the dialog.
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: AppColors.primarySurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Decorative circle for settings header.
class _SettingsCircle extends StatelessWidget {
  final double size;
  const _SettingsCircle(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}

