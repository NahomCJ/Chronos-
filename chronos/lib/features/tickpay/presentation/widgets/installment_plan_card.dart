import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/installment_plan.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';
import 'merchant_logo.dart';

/// Full installment plan card used on the Active Plans screen.
class InstallmentPlanCard extends StatelessWidget {
  final InstallmentPlan plan;
  final VoidCallback? onViewDetails;

  const InstallmentPlanCard({
    super.key,
    required this.plan,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TickpayColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MerchantLogo(asset: plan.logoAsset, size: 44, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            plan.merchant,
                            style: TextStyles.titleMedium.copyWith(
                              color: TickpayColors.textPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(category: plan.category),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.paymentsMade} of ${plan.paymentsTotal} payments made',
                      style: TextStyles.bodySmall
                          .copyWith(color: TickpayColors.textMutedLight),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    TickpayFormatters.money(plan.totalAmount),
                    style: TextStyles.titleMedium.copyWith(
                      color: TickpayColors.positiveGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'total',
                    style: TextStyles.bodySmall
                        .copyWith(color: TickpayColors.textMutedLight),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyles.bodySmall
                    .copyWith(color: TickpayColors.textMutedLight),
              ),
              Text(
                '${plan.progressPercent}%',
                style: TextStyles.bodySmall.copyWith(
                  color: TickpayColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 6,
              backgroundColor: TickpayColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation(TickpayColors.chipFashionText),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Paid',
                  value: TickpayFormatters.moneyPrecise(plan.paidAmount),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Remaining',
                  value: TickpayFormatters.moneyPrecise(plan.remainingAmount),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: plan.isDueSoon
                  ? const Color(0xFFFFF7E0)
                  : TickpayColors.neutralSurface,
              borderRadius: BorderRadius.circular(12),
              border: plan.isDueSoon
                  ? Border.all(color: TickpayColors.warningAmber)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Next Payment',
                          style: TextStyles.bodySmall
                              .copyWith(color: TickpayColors.textMutedLight),
                        ),
                        if (plan.isDueSoon) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: TickpayColors.warningAmber
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Due soon',
                              style: TextStyles.labelSmall.copyWith(
                                color: TickpayColors.warningAmberText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.nextPaymentDate,
                      style: TextStyles.bodyMedium.copyWith(
                        color: TickpayColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  TickpayFormatters.moneyPrecise(plan.nextPaymentAmount),
                  style: TextStyles.titleMedium.copyWith(
                    color: TickpayColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'View Details',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TickpayColors.neutralSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall
                .copyWith(color: TickpayColors.textMutedLight),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: TickpayColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (category.toLowerCase()) {
      'fashion' => (
          TickpayColors.chipFashionBg,
          TickpayColors.chipFashionText
        ),
      'home' => (TickpayColors.chipHomeBg, TickpayColors.chipHomeText),
      _ => (TickpayColors.chipElectronicsBg, TickpayColors.chipElectronicsText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyles.labelSmall.copyWith(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
