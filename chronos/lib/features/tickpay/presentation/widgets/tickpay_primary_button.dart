import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../constants/tickpay_colors.dart';

/// The brand red gradient call-to-action used on every TickPay screen.
/// Falls back to a muted, disabled appearance when [onPressed] is null.
class TickpayPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const TickpayPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: enabled ? TickpayColors.primaryGradient : null,
        color: enabled ? null : TickpayColors.glassStrong,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
        child: Text(
          label,
          style: TextStyles.titleMedium.copyWith(
            color: enabled
                ? TickpayColors.textOnDark
                : TickpayColors.textMutedDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
