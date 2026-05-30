import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/installment_plan.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';
import 'merchant_logo.dart';

/// Compact active-plan row shown in the dashboard "Active Plans" preview.
class DashboardPlanTile extends StatelessWidget {
  final InstallmentPlan plan;
  final VoidCallback? onTap;

  const DashboardPlanTile({super.key, required this.plan, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TickpayColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            MerchantLogo(asset: plan.logoAsset, size: 56, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plan.paymentsMade} of ${plan.paymentsTotal} payments left',
                    style: TextStyles.bodySmall
                        .copyWith(color: TickpayColors.textMutedLight),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${plan.merchant}${plan.reference}',
                    style: TextStyles.titleMedium.copyWith(
                      color: TickpayColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    TickpayFormatters.money(plan.totalAmount),
                    style: TextStyles.titleMedium.copyWith(
                      color: TickpayColors.positiveGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
