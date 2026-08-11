import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/panther_colors.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/router/route_constants.dart';
import '../../../domain/entities/auto_invest.dart';
import '../../../domain/entities/auto_invest_enums.dart';
import '../../cubit/auto_invest_cubit.dart';
import '../../cubit/auto_invest_state.dart';
import '../../widgets/auto_invest_asset_icon.dart';
import '../../widgets/panther_ring_chart.dart';

class AutoInvestAllocationPreviewPage extends StatelessWidget {
  const AutoInvestAllocationPreviewPage({super.key});

  static const _cryptoColor = PantherColors.brand;
  static const _stockColor = PantherColors.info;
  static const _etfColor = PantherColors.positive;

  Color _colorFor(AutoInvestAssetClass assetClass) {
    switch (assetClass) {
      case AutoInvestAssetClass.crypto:
        return _cryptoColor;
      case AutoInvestAssetClass.stock:
        return _stockColor;
      case AutoInvestAssetClass.etf:
        return _etfColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantherColors.bg,
      body: SafeArea(
        child: BlocBuilder<AutoInvestCubit, AutoInvestState>(
          builder: (context, state) {
            final wizard = state is AutoInvestWizardInProgress ? state : null;
            final preview = wizard?.allocationPreview;

            if (preview == null) {
              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No allocation to show — go back and enter an amount.',
                        style: TextStyle(color: PantherColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              );
            }

            final summary = preview.summary;
            final slices = <PantherRingSlice>[
              if (summary.cryptoPct > 0)
                PantherRingSlice(
                  label: 'Crypto',
                  value: summary.cryptoPct,
                  color: _cryptoColor,
                  icon: autoInvestClassIcon(AutoInvestAssetClass.crypto),
                ),
              if (summary.stockPct > 0)
                PantherRingSlice(
                  label: 'Stocks',
                  value: summary.stockPct,
                  color: _stockColor,
                  icon: autoInvestClassIcon(AutoInvestAssetClass.stock),
                ),
              if (summary.etfPct > 0)
                PantherRingSlice(
                  label: 'ETFs',
                  value: summary.etfPct,
                  color: _etfColor,
                  icon: autoInvestClassIcon(AutoInvestAssetClass.etf),
                ),
            ];

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: PantherColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Soft brand-tinted glow behind the ring —
                              // purely decorative, clipped to the card.
                              Positioned(
                                top: -40,
                                right: -30,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: PantherColors.brandLight.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Portfolio Mix',
                                          style: TextStyles.titleMedium.copyWith(
                                            color: PantherColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: PantherColors.brandLight,
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          child: Text(
                                            '${preview.allocations.length} assets',
                                            style: TextStyles.bodySmall.copyWith(
                                              color: PantherColors.brandDark,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    PantherRingChart(
                                      slices: slices,
                                      centerLabel: '\$${wizard?.amountUsd?.toStringAsFixed(0) ?? '0'}',
                                      centerSubLabel: 'Total',
                                      size: 164,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Your mix',
                          style: TextStyles.titleMedium.copyWith(
                            color: PantherColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...preview.allocations.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AllocationRow(
                              allocation: a,
                              color: _colorFor(a.assetClass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: PantherColors.cardAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.psychology_outlined,
                                  color: PantherColors.brand, size: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Chris built this mix from your risk profile and goal.',
                                  style: TextStyles.bodySmall.copyWith(
                                    color: PantherColors.textSecondary,
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push(RouteConstants.autoInvestReview.toPath),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PantherColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 46),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyles.labelLarge.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: PantherColors.textPrimary, size: 22),
            ),
          ),
          Text(
            'Your Mix',
            style: TextStyles.titleMedium.copyWith(
              color: PantherColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationRow extends StatelessWidget {
  final AutoInvestAllocationEntity allocation;
  final Color color;

  const _AllocationRow({
    required this.allocation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final executesLive = allocation.assetClass.executesLive;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PantherColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AutoInvestAssetIcon(
                symbol: allocation.symbol,
                assetClass: allocation.assetClass,
                accent: color,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          allocation.symbol,
                          style: TextStyles.bodyMedium.copyWith(
                            color: PantherColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            allocation.name,
                            style: TextStyles.bodySmall.copyWith(
                              color: PantherColors.textSecondary,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${allocation.percentage.toStringAsFixed(0)}%',
                    style: TextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    '\$${allocation.amountUsd.toStringAsFixed(2)}',
                    style: TextStyles.bodySmall.copyWith(
                      color: PantherColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (allocation.rationale.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              allocation.rationale,
              style: TextStyles.bodySmall.copyWith(
                color: PantherColors.textSecondary,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: (executesLive ? PantherColors.positive : PantherColors.warning)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              executesLive ? 'Executes now' : 'Planned — brokerage coming soon',
              style: TextStyles.bodySmall.copyWith(
                color: executesLive ? PantherColors.positive : PantherColors.warning,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
