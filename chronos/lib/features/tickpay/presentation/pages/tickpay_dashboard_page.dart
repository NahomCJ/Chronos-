import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_assets.dart';
import '../constants/tickpay_colors.dart';
import '../widgets/widgets.dart';

/// Main TickPay dashboard: credit summary, quick actions, active plans
/// preview and AI product recommendations.
class TickpayDashboardPage extends StatelessWidget {
  const TickpayDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<TickpayRepository>();
    final account = repo.getCreditAccount();
    final plans = repo.getActivePlans();
    final picks = repo.getAiPicks();

    return Scaffold(
      backgroundColor: TickpayColors.scaffoldDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TickpayHeader(
              title: 'Good evening, Antonio',
              subtitle: 'Tuesday, February 3',
              avatar: const AssetImage('assets/panther.png'),
              onNotifications: () =>
                  context.push(RouteConstants.tickpayNotifications.toPath),
              onChat: () => context.push(RouteConstants.tickpayShortcuts.toPath),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CreditSummaryCard(
                account: account,
                onTap: () =>
                    context.push(RouteConstants.tickpayCreditOverview.toPath),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickActionButton(
                    iconAsset: TickpayAssets.shopIcon,
                    label: 'Shop',
                    onTap: () =>
                        context.push(RouteConstants.tickpayShortcuts.toPath),
                  ),
                  QuickActionButton(
                    iconAsset: TickpayAssets.payBillsIcon,
                    label: 'Pay',
                    onTap: () => context
                        .push(RouteConstants.tickpayCreditOverview.toPath),
                  ),
                  QuickActionButton(
                    iconAsset: TickpayAssets.plansIcon,
                    label: 'Purchases',
                    onTap: () =>
                        context.push(RouteConstants.tickpayActivePlans.toPath),
                  ),
                  QuickActionButton(
                    iconAsset: TickpayAssets.dollarIcon,
                    label: 'Repayments',
                    onTap: () => context
                        .push(RouteConstants.tickpayCreditOverview.toPath),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: TickpayColors.lightSheet,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    SectionTitle(
                      title: 'Active Plans',
                      actionLabel: 'View All',
                      onAction: () =>
                          context.push(RouteConstants.tickpayActivePlans.toPath),
                    ),
                    const SizedBox(height: 16),
                    for (final plan in plans.take(2)) ...[
                      DashboardPlanTile(
                        plan: plan,
                        onTap: () => context
                            .push(RouteConstants.tickpayActivePlans.toPath),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 20),
                    SectionTitle(
                      title: 'AI Picks for You',
                      actionLabel: 'View All',
                      actionColor: TickpayColors.accentOrange,
                      onAction: () =>
                          context.push(RouteConstants.productDiscovery.toPath),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: picks.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) => AiPickCard(
                          pick: picks[i],
                          onTap: () => context
                              .push(RouteConstants.productDiscovery.toPath),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
