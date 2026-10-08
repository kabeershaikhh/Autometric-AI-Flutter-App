import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../servers/user_service.dart';

/// Slim web top bar; the sidebar remains owned by the navigation shell.
class WebPageHeader extends StatelessWidget {
  final String section;
  final String userName;
  final String photoBase64;
  final VoidCallback onHome;
  final VoidCallback onProfile;

  const WebPageHeader({
    super.key,
    required this.section,
    required this.userName,
    required this.photoBase64,
    required this.onHome,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final home = section == 'Home';
    final photo = UserService.decodePhoto(photoBase64);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: home
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $userName! 👋',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Let's evaluate your car today",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      TextButton(
                        onPressed: onHome,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textGrey,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Home',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          section,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: home
                  ? AppColors.primarySurface
                  : Colors.transparent,
            ),
            icon: Icon(
              Icons.notifications_none_rounded,
              color: home ? AppColors.primary : AppColors.textDark,
            ),
          ),
          const SizedBox(width: 14),
          TextButton(
            onPressed: onProfile,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.all(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: photo == null ? null : MemoryImage(photo),
                  child: photo != null
                      ? null
                      : home
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : Text(
                          userName.trim().isEmpty
                              ? 'G'
                              : userName.trim().characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (!home) ...[
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
