import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';
import '../widgets/widgets.dart';

/// Detailed view of the user's credit line: limit, utilization gauge and
/// recent activity.
class TickpayCreditOverviewPage extends StatelessWidget {
  const TickpayCreditOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<TickpayRepository>();
    final account = repo.getCreditAccount();
    final activity = repo.getRecentActivity();

    return Scaffold(
      backgroundColor: TickpayColors.scaffoldDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TickpayHeader(
              title: 'Credit Overview',
              subtitle: 'Manage your credit line',
              onBack: () => context.pop(),
              onNotifications: () =>
                  context.push(RouteConstants.tickpayNotifications.toPath),
              onChat: () => context.push(RouteConstants.tickpayShortcuts.toPath),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: Column(
                        children: [
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Credit',
                                  style: TextStyles.bodyMedium.copyWith(
                                      color: TickpayColors.textMutedDark),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  TickpayFormatters.money(
                                      account.availableCredit),
                                  style: TextStyles.displayMedium.copyWith(
                                    color: TickpayColors.textOnDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'of ${TickpayFormatters.money(account.creditLimit)} limit',
                                  style: TextStyles.bodySmall.copyWith(
                                      color: TickpayColors.textMutedDark),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _PillStat(
                                        label: 'Credit Limit',
                                        value: TickpayFormatters.money(
                                            account.creditLimit),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _PillStat(
                                        label: 'Used',
                                        value: TickpayFormatters.money(
                                            account.creditUsed),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          CreditUtilizationCard(account: account),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: TickpayColors.lightSheet,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(
                              title: 'Recent Activity',
                              actionLabel: 'View All',
                              onAction: () => context.push(
                                  RouteConstants.tickpayActivePlans.toPath),
                            ),
                            const SizedBox(height: 16),
                            for (final item in activity)
                              CreditActivityTile(activity: item),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  'Request Credit Increase',
                                  style: TextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFFE0E0E0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  'Payment History',
                                  style: TextStyles.titleMedium.copyWith(
                                    color: TickpayColors.textPrimaryLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _PillStat extends StatelessWidget {
  final String label;
  final String value;

  const _PillStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TickpayColors.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TickpayColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall
                .copyWith(color: TickpayColors.textMutedDark),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.titleMedium.copyWith(
              color: TickpayColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
