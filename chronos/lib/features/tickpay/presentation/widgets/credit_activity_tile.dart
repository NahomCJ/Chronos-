import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/credit_account.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';

/// A single row in the Credit Overview "Recent Activity" list.
class CreditActivityTile extends StatelessWidget {
  final CreditActivity activity;

  const CreditActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final bool isCredit = activity.isCredit;
    final Color amountColor =
        isCredit ? TickpayColors.positiveGreen : TickpayColors.textPrimaryLight;
    final String amountText =
        '+${TickpayFormatters.moneyPrecise(activity.amount)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TickpayColors.neutralSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCredit
                  ? TickpayColors.positiveGreen.withValues(alpha: 0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color:
                  isCredit ? TickpayColors.positiveGreen : Colors.grey.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.merchant,
                  style: TextStyles.bodyMedium.copyWith(
                    color: TickpayColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${activity.date} • ${activity.category}',
                  style: TextStyles.bodySmall
                      .copyWith(color: TickpayColors.textMutedLight),
                ),
              ],
            ),
          ),
          Text(
            amountText,
            style: TextStyles.bodyMedium.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
