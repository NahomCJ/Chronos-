import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../constants/tickpay_colors.dart';

/// "Section heading + optional View All action" row used on the light
/// content sheets.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final Color actionColor;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionColor = TickpayColors.brandRedDark,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyles.titleLarge.copyWith(
            color: TickpayColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyles.bodyMedium.copyWith(
                color: actionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
