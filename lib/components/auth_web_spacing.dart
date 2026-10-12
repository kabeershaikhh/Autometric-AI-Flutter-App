import 'dart:math' as math;

/// Shared desktop geometry for welcome, login, and registration.
class AuthWebSpacing {
  AuthWebSpacing._();

  static const horizontalPadding = 64.0;
  static const verticalPadding = 44.0;
  static const brandingMaxWidth = 430.0;
  static const cardMaxWidth = 470.0;

  static double gap(double viewportWidth) =>
      (viewportWidth * 0.08).clamp(50.0, 130.0);

  // Mirrors the welcome row's two equally allocated, loose Flexible children.
  static double panelWidth(double viewportWidth, double maxWidth) => math.min(
    maxWidth,
    math.max(
      0.0,
      (viewportWidth - horizontalPadding * 2 - gap(viewportWidth)) / 2,
    ),
  );
}
