import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The supplied SVG embeds PNG artwork in a pattern. Render that exact artwork
/// without a vector dependency; the bundled asset is read/decoded only once.
class CarLogo extends StatelessWidget {
  final double size;
  const CarLogo({super.key, this.size = 32});
  // Exact artwork from assets/Car.svg. Keeps the logo visible immediately, even
  // when a running web build has not yet picked up the newly added asset.
  static const _bundledArtwork =
      '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';
  static final Uint8List _fallback = base64Decode(_bundledArtwork);
  static final Future<Uint8List> _artwork = _load();
  static Future<Uint8List> _load() async {
    try {
      final svg = await rootBundle.loadString('assets/Car.svg');
      final image = RegExp(r'data:image/png;base64,([^"\s]+)').firstMatch(svg);
      if (image != null) return base64Decode(image.group(1)!);
    } catch (_) {
      // Asset manifests can be stale during hot reload; do not cache a failure.
    }
    return _fallback;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: FutureBuilder<Uint8List>(
      future: _artwork,
      builder: (_, snapshot) => Image.memory(
        snapshot.data ?? _fallback,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        errorBuilder: (_, error, stack) => Image.memory(
          _fallback,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    ),
  );
}
