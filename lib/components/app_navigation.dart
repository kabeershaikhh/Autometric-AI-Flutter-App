import 'package:flutter/material.dart';

/// Shared section navigation. Main tabs never push routes onto the stack.
class AppNavigation extends InheritedWidget {
  final Future<void> Function(int index) onSelect;
  final VoidCallback onProfile;

  const AppNavigation({
    super.key,
    required this.onSelect,
    required this.onProfile,
    required super.child,
  });

  static AppNavigation of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppNavigation>()!;

  static Future<void> select(BuildContext context, int index) =>
      of(context).onSelect(index);

  @override
  bool updateShouldNotify(AppNavigation oldWidget) =>
      onSelect != oldWidget.onSelect || onProfile != oldWidget.onProfile;
}
