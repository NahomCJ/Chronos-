import 'package:flutter/material.dart';

/// Renders a monochrome TickPay icon asset, recoloring it to [color].
///
/// The design ships single-color glyphs with transparency, so `BlendMode.srcIn`
/// lets us paint the same artwork in white on dark surfaces or black on light
/// ones without maintaining duplicate assets.
class TickpayGlyph extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const TickpayGlyph({
    super.key,
    required this.asset,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.circle, size: size, color: color),
    );
  }
}
