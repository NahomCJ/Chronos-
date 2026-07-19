import 'package:flutter/material.dart';

import '../constants/tickpay_colors.dart';

/// Translucent "glass" surface used for cards layered over the dark
/// TickPay background.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: TickpayColors.glassFill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: TickpayColors.glassBorder, width: 1),
      ),
      child: child,
    );
  }
}
