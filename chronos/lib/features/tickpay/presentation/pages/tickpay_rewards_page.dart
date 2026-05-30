import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/rewards_entities.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';
import '../widgets/widgets.dart';

/// Loyalty hub: points & cashback balances, active campaigns and recent
/// rewards activity.
class TickpayRewardsPage extends StatelessWidget {
  const TickpayRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<TickpayRepository>();
    final summary = repo.getRewardSummary();
    final campaigns = repo.getRewardCampaigns();
    final activity = repo.getRewardActivity();

    return Scaffold(
      backgroundColor: TickpayColors.scaffoldDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TickpayHeader(
              title: 'Rewards',
              subtitle: summary.tier,
              onBack: () => context.pop(),
              onNotifications: () =>
                  context.push(RouteConstants.tickpayNotifications.toPath),
              onChat: () => context.push(RouteConstants.tickpayShortcuts.toPath),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: RewardBalanceCard(
                          icon: Icons.star,
                          label: 'Points',
                          value: TickpayFormatters.points(summary.points),
                          caption:
                              '≈ ${TickpayFormatters.moneyPrecise(summary.pointsValue)} value',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: RewardBalanceCard(
                          icon: Icons.attach_money,
                          label: 'Cashback',
                          value:
                              TickpayFormatters.moneyPrecise(summary.cashback),
                          caption: 'Apply to balance',
                          labelColor: TickpayColors.accentGold,
                          captionColor: TickpayColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Active Campaigns',
                    style: TextStyles.titleLarge.copyWith(
                      color: TickpayColors.textOnDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final campaign in campaigns) ...[
                    RewardCampaignCard(campaign: campaign),
                    const SizedBox(height: 14),
                  ],
                  const SizedBox(height: 10),
                  _RecentActivitySheet(activity: activity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitySheet extends StatelessWidget {
  final List<RewardActivity> activity;

  const _RecentActivitySheet({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: TickpayColors.lightSheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Recent Activity',
            actionLabel: 'View All',
            onAction: () {},
          ),
          const SizedBox(height: 16),
          for (final item in activity) RewardActivityRow(activity: item),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TickpayColors.infoCyan.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.card_giftcard,
                      color: Color(0xFF0288A8), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to redeem?',
                        style: TextStyles.titleMedium.copyWith(
                          color: TickpayColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Browse rewards catalog',
                        style: TextStyles.bodySmall
                            .copyWith(color: TickpayColors.textMutedLight),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Color(0xFF0288A8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
