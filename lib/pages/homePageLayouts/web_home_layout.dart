import 'package:flutter/material.dart';

class WebHomeLayout extends StatelessWidget {

  final VoidCallback onLogout;

  const WebHomeLayout({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {

    return const Center(
      child: Text(
        "Web Home Layout",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}