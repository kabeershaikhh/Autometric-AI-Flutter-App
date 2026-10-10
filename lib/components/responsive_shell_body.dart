import 'package:flutter/material.dart';

/// Keeps the tab subtree mounted when the desktop sidebar appears/disappears.
class ResponsiveShellBody extends StatelessWidget {
  final Widget? sidebar;
  final Widget content;

  const ResponsiveShellBody({super.key, this.sidebar, required this.content});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (sidebar != null) sidebar!,
      // The keyed slot retains the content when its sibling index changes.
      Expanded(key: const ValueKey('shell-content'), child: content),
    ],
  );
}
