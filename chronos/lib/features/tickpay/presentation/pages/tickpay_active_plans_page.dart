import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_assets.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';
import '../widgets/widgets.dart';

/// Full list of the user's active BNPL installment plans.
class TickpayActivePlansPage extends StatelessWidget {
  const TickpayActivePlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = sl<TickpayRepository>().getActivePlans();
    final double totalRemaining =
        plans.fold(0, (sum, p) => sum + p.remainingAmount);

    return Scaffold(
      backgroundColor: TickpayColors.scaffoldDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TickpayHeader(
              title: 'Active Plans',
              subtitle: '${plans.length} active installments',
              onBack: () => context.pop(),
              onNotifications: () =>
                  context.push(RouteConstants.tickpayNotifications.toPath),
              onChat: () => context.push(RouteConstants.tickpayShortcuts.toPath),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Remaining',
                          style: TextStyles.bodyMedium
                              .copyWith(color: TickpayColors.textMutedDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          TickpayFormatters.moneyPrecise(totalRemaining),
                          style: TextStyles.headlineMedium.copyWith(
                            color: TickpayColors.textOnDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const TickpayGlyph(
                        asset: TickpayAssets.dollarIcon,
                        color: TickpayColors.textOnDark,
                        size: 22,
                      ),
                    ),
                  ],
                ),
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
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => InstallmentPlanCard(
                    plan: plans[i],
                    onViewDetails: () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
