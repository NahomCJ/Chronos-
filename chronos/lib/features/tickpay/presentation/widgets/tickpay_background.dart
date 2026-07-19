import 'package:flutter/material.dart';

import '../constants/tickpay_assets.dart';
import '../constants/tickpay_colors.dart';

/// Full-bleed branded background used across the TickPay onboarding flow.
/// Renders the design's purple/black artwork behind [child].
class TickpayBackground extends StatelessWidget {
  final Widget child;

  const TickpayBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            TickpayAssets.background,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: TickpayColors.scaffoldDark),
          ),
        ),
        child,
      ],
    );
  }
}
