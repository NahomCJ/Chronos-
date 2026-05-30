import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../constants/tickpay_colors.dart';
import 'tickpay_glyph.dart';

/// Circular dashboard quick-action (Shop / Pay / Purchases / Repayments).
class QuickActionButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.iconAsset,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: TickpayColors.glassStrong,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: TickpayGlyph(
              asset: iconAsset,
              color: TickpayColors.textOnDark,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(color: TickpayColors.textOnDark),
          ),
        ],
      ),
    );
  }
}
