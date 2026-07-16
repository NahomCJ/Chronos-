import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/rewards_entities.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';

/// One of the two balance tiles at the top of the Rewards screen.
class RewardBalanceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color labelColor;
  final Color captionColor;

  const RewardBalanceCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.labelColor = TickpayColors.textMutedDark,
    this.captionColor = TickpayColors.textMutedDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TickpayColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TickpayColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TickpayColors.glassStrong,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TickpayColors.textOnDark, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(color: labelColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.headlineSmall.copyWith(
              color: TickpayColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: TextStyles.labelSmall.copyWith(color: captionColor),
          ),
        ],
      ),
    );
  }
}

/// A progress-tracked campaign card in the Rewards "Active Campaigns" list.
class RewardCampaignCard extends StatelessWidget {
  final RewardCampaign campaign;

  const RewardCampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TickpayColors.glassFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TickpayColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaign.title,
            style: TextStyles.titleMedium.copyWith(
              color: TickpayColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            campaign.description,
            style: TextStyles.bodySmall
                .copyWith(color: TickpayColors.textMutedDark, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyles.bodySmall
                    .copyWith(color: TickpayColors.textMutedDark),
              ),
              Text(
                '${campaign.progressCurrent} / ${campaign.progressTotal}',
                style: TextStyles.bodySmall.copyWith(
                  color: TickpayColors.textOnDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: TickpayColors.glassStrong,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: campaign.progress.clamp(0.0, 1.0),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB8531C), TickpayColors.accentGold],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: TickpayColors.accentGold, size: 14),
              const SizedBox(width: 6),
              Text(
                campaign.pointsToGo,
                style: TextStyles.bodySmall
                    .copyWith(color: TickpayColors.textMutedDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A row in the Rewards "Recent Activity" list (earned / redeemed points).
class RewardActivityRow extends StatelessWidget {
  final RewardActivity activity;

  const RewardActivityRow({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final bool earned = activity.points >= 0;
    final Color color =
        earned ? TickpayColors.positiveGreen : TickpayColors.accentGold;
    final String text =
        '${earned ? '+' : ''}${TickpayFormatters.points(activity.points)} pts';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TickpayColors.neutralSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: TickpayColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.date,
                  style: TextStyles.bodySmall
                      .copyWith(color: TickpayColors.textMutedLight),
                ),
              ],
            ),
          ),
          Text(
            text,
            style: TextStyles.bodyMedium
                .copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
