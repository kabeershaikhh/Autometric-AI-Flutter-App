import 'package:flutter/material.dart';

import '../components/decorated_header.dart';
import '../components/settings_drawer.dart';

/// Account settings intentionally opens outside the sidebar/tab shell.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
          child: DecoratedHeader(
            title: 'Settings',
            subtitle: 'Manage your account security',
            icon: Icons.settings_outlined,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
        const Expanded(child: SettingsDrawer()),
      ],
    ),
  );
}
