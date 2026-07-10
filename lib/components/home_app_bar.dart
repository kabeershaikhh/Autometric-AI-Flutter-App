import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../servers/user_service.dart';

/// Custom app bar row for the home page.
/// Sits inside a purple header container, so text/icons are white.
class HomeAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  final String? photoBase64;

  const HomeAppBar({
    super.key,
    required this.onProfileTap,
    this.photoBase64,
  });

  @override
  Widget build(BuildContext context) {
    final Uint8List? photoBytes = UserService.decodePhoto(photoBase64);

    return Row(
      children: [

        //////////////////////////////////////
        /// APP LOGO
        //////////////////////////////////////

        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              "assets/AutoMetricAI.png",
            ),
          ),
        ),

        const SizedBox(width: 14),

        //////////////////////////////////////
        /// TITLE
        //////////////////////////////////////

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "AutoMetric AI",
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              SizedBox(height: 2),

              Text(
                "AI Powered Valuation",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        //////////////////////////////////////
        /// NOTIFICATION
        //////////////////////////////////////

        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.white,
            ),
          ),
        ),

        const SizedBox(width: 10),

        //////////////////////////////////////
        /// PROFILE
        //////////////////////////////////////

        GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.white.withOpacity(0.25),
            backgroundImage:
                photoBytes != null ? MemoryImage(photoBytes) : null,
            child: photoBytes == null
                ? const Icon(
                    Icons.person,
                    color: AppColors.white,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}