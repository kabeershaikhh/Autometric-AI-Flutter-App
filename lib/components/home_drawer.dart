import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../servers/user_service.dart';
import 'settings_drawer.dart';

/// Side drawer for profile management.
/// Used by BOTH Android and Web layouts (opened via endDrawer).
/// Shows user profile, change name, upload/delete photo, settings, and logout.
class HomeDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final String userName;
  final String userEmail;
  final String? photoBase64;
  final UserService userService;

  const HomeDrawer({
    super.key,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
    this.photoBase64,
    required this.userService,
  });

  /// Whether the user currently has a profile photo.
  bool get _hasPhoto =>
      photoBase64 != null && photoBase64!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final Uint8List? photoBytes = UserService.decodePhoto(photoBase64);

    return Drawer(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [

            //////////////////////////////////////
            /// PURPLE HEADER with decorative circles
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
                      right: -20,
                      child: _DrawerCircle(100),
                    ),
                    Positioned(
                      bottom: -50,
                      left: -40,
                      child: _DrawerCircle(120),
                    ),
                    Positioned(
                      top: 0,
                      left: -40,
                      child: _DrawerCircle(90),
                    ),

                    // Content with inner padding
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 56, 24, 26),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Profile Image — tappable to upload
                            GestureDetector(
                              onTap: () => _pickAndUploadPhoto(context),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 42,
                                    backgroundColor:
                                        AppColors.white.withValues(alpha: 0.20),
                                    backgroundImage: photoBytes != null
                                        ? MemoryImage(photoBytes)
                                        : null,
                                    child: photoBytes == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 44,
                                            color: AppColors.white,
                                          )
                                        : null,
                                  ),
                                  // Camera badge
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              userName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.white,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              userEmail,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //////////////////////////////////////
            /// SCROLLABLE MENU ITEMS
            //////////////////////////////////////

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    _DrawerItem(
                      icon: Icons.photo_camera_outlined,
                      title: "Upload Profile Picture",
                      onTap: () => _pickAndUploadPhoto(context),
                    ),

                    // Show delete photo only when a photo exists
                    if (_hasPhoto)
                      _DrawerItem(
                        icon: Icons.delete_outline,
                        title: "Remove Profile Picture",
                        iconColor: AppColors.error,
                        onTap: () => _confirmDeletePhoto(context),
                      ),

                    _DrawerItem(
                      icon: Icons.edit_outlined,
                      title: "Change Name",
                      onTap: () => _showChangeNameDialog(context),
                    ),

                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      onTap: () => _openSettings(context),
                    ),
                  ],
                ),
              ),
            ),

            //////////////////////////////////////
            /// LOGOUT (pinned at bottom)
            //////////////////////////////////////

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider),
            ),

            _DrawerItem(
              icon: Icons.logout,
              title: "Logout",
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: onLogout,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Opens the Settings drawer (pushes on top of the current drawer).
  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsDrawer(),
      ),
    );
  }

  /// Picks an image from gallery and uploads as base64 to Firestore.
  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image == null) return; // user cancelled

      final Uint8List bytes = await image.readAsBytes();

      // Check size — base64 roughly 1.33x the byte size, keep under ~700KB
      if (bytes.lengthInBytes > 500000) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Image is too large. Please choose a smaller photo.",
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      await userService.updateProfilePhoto(bytes);

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile photo updated! ✓"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update photo: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Confirmation dialog before deleting profile photo.
  void _confirmDeletePhoto(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          "Remove Photo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: const Text(
          "Are you sure you want to remove your profile picture?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await userService.deleteProfilePhoto();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile photo removed."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog allowing the user to change their display name.
  void _showChangeNameDialog(BuildContext context) {
    final controller = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          "Change Name",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "Enter your name",
            prefixIcon: const Icon(Icons.person_outline),
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
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != userName) {
                await userService.updateUserName(newName);
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Name updated successfully! ✓"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } else {
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative circle for drawer header.
class _DrawerCircle extends StatelessWidget {
  final double size;
  const _DrawerCircle(this.size);

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

/// Individual drawer menu item.
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
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
          borderRadius: BorderRadius.circular(14),
        ),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor ?? AppColors.textDark,
            fontWeight: FontWeight.w500,
            fontSize: 14,
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