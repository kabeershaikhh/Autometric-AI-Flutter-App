import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;

  const HomeAppBar({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        //////////////////////////////////////
        /// APP LOGO
        //////////////////////////////////////

        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              SizedBox(height: 2),

              Text(
                "AI Powered Valuation",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        //////////////////////////////////////
        /// NOTIFICATION
        //////////////////////////////////////

        IconButton(
          onPressed: () {},

          icon: const Icon(
            Icons.notifications_none,
            color: Colors.white,
          ),
        ),

        //////////////////////////////////////
        /// PROFILE
        //////////////////////////////////////

        GestureDetector(
          onTap: onProfileTap,
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Color(0xFF7C4DFF),
            ),
          ),
        ),
      ],
    );
  }
}