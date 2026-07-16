import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/credit_account.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';
import 'glass_card.dart';

/// Dashboard "Available Credit" card with the usage progress bar.
class CreditSummaryCard extends StatelessWidget {
  final CreditAccount account;
  final VoidCallback? onTap;

  const CreditSummaryCard({super.key, required this.account, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Credit',
              style: TextStyles.bodyMedium
                  .copyWith(color: TickpayColors.textMutedDark),
            ),
            const SizedBox(height: 4),
            Text(
              TickpayFormatters.money(account.availableCredit),
              style: TextStyles.displayMedium.copyWith(
                color: TickpayColors.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'of ${TickpayFormatters.money(account.creditLimit)} limit',
              style: TextStyles.bodySmall
                  .copyWith(color: TickpayColors.textMutedDark),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credit Used',
                  style: TextStyles.bodySmall
                      .copyWith(color: TickpayColors.textMutedDark),
                ),
                Text(
                  TickpayFormatters.money(account.creditUsed),
                  style: TextStyles.bodyMedium.copyWith(
                    color: TickpayColors.textOnDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: account.utilization,
                minHeight: 8,
                backgroundColor: TickpayColors.glassStrong,
                valueColor: const AlwaysStoppedAnimation(TickpayColors.brandRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
