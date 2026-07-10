import 'package:flutter/material.dart';

/// Centralized color constants for the entire app.
/// Use these instead of hardcoding Color(0xFF...) everywhere.
class AppColors {
  AppColors._(); // prevent instantiation

  // ── Primary Purple Palette ──
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFF9E7BFF);
  static const Color primaryDark = Color(0xFF5C2FE0);
  static const Color primarySurface = Color(0xFFF3EEFF);
  static const Color primaryBorder = Color(0xFFD8C9FF);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6A3DE8), primary, primaryLight],
  );

  // ── Text Colors ──
  static const Color textDark = Color(0xFF2A2342);
  static const Color textGrey = Color(0xFF7B7198);
  static const Color textLight = Color(0xFF5F5874);

  // ── Background ──
  static const Color scaffoldBg = Color(0xFFF8F5FF);
  static const Color cardBg = Colors.white;
  static const Color surfaceLight = Color(0xFFFDF7FF);

  // ── Status ──
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);

  // ── Misc ──
  static const Color white = Colors.white;
  static const Color divider = Color(0xFFE8E0F0);
  static const Color iconGrey = Color(0xFF9E9E9E);
}
