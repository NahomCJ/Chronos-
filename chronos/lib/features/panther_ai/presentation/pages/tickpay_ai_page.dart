import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/spending_summary.dart';
import '../bloc/spending_bloc.dart';
import '../bloc/spending_event.dart';
import '../bloc/spending_state.dart';

class TickPayAiPage extends StatefulWidget {
  const TickPayAiPage({super.key});

  @override
  State<TickPayAiPage> createState() => _TickPayAiPageState();
}

class _TickPayAiPageState extends State<TickPayAiPage> {
  late final SpendingBloc _spendingBloc;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _spendingBloc = GetIt.I<SpendingBloc>()
      ..add(SpendingSummaryLoadRequested(month: now.month, year: now.year));
  }

  @override
  void dispose() {
    _spendingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _spendingBloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/background.png', fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: BlocBuilder<SpendingBloc, SpendingState>(
                      builder: (context, state) {
                        final summary =
                            state is SpendingLoaded ? state.summary : null;
                        return SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              _buildQuickActions(context),
                              const SizedBox(height: 24),
                              _buildAIInsights(context, summary),
                              const SizedBox(height: 24),
                              _buildActiveBNPLPlans(),
                              const SizedBox(height: 24),
                              _buildRewardsCard(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        );
                      },
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TickPay AI',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Smart shopping assistant',
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFFA1A1A1),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.shopping_bag_outlined, 'Shop', onTap: () {
          context.push(RouteConstants.productDiscovery.toPath);
        }),
        _buildActionButton(Icons.payment_outlined, 'Pay'),
        _buildActionButton(Icons.receipt_long_outlined, 'Orders'),
        _buildActionButton(Icons.replay_outlined, 'Repay'),
        _buildActionButton(Icons.card_giftcard_outlined, 'Rewards'),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(53),
              border: Border.all(
                color: const Color(0xFFE7DFDF).withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights(BuildContext context, SpendingSummary? summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Insights',
          style:
              TextStyles.titleMedium.copyWith(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 12),
        _buildSpendingPowerCard(summary),
        const SizedBox(height: 12),
        _buildBNPLRiskCard(context),
      ],
    );
  }

  Widget _buildSpendingPowerCard(SpendingSummary? summary) {
    final totalSpent =
        summary != null ? '\$${summary.totalSpent.toStringAsFixed(0)}' : '\$—';
    final dailyAvg = summary != null
        ? '\$${summary.dailyAverage.toStringAsFixed(0)}'
        : '\$—';
    final txCount =
        summary != null ? '${summary.transactionCount} txns' : '—';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x3300C950),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.check_circle,
                color: Color(0xFF05DF72), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Spending Summary',
                  style: TextStyles.bodyMedium
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your spending data for this month from Panther AI.',
                  style: TextStyles.bodySmall
                      .copyWith(color: const Color(0xFFA1A1A1), fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCol('Total spent', totalSpent,
                          const Color(0xFF05DF72)),
                    ),
                    Expanded(
                      child: _statCol(
                          'Daily avg', dailyAvg, const Color(0xFF00D4FF)),
                    ),
                    Expanded(
                      child: _statCol('Transactions', txCount, Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyles.bodySmall
                .copyWith(color: const Color(0xFFA1A1A1), fontSize: 12)),
        Text(value,
            style: TextStyles.bodySmall
                .copyWith(color: valueColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildBNPLRiskCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x33F0B100),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFF0B100), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BNPL risk increasing',
                        style: TextStyles.bodyMedium
                            .copyWith(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                        'You have 3 active Buy Now Pay Later plans. Consider reducing before adding more.',
                        style: TextStyles.bodySmall.copyWith(
                            color: const Color(0xFFA1A1A1), fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total owed',
                            style: TextStyles.bodySmall.copyWith(
                                color: const Color(0xFFA1A1A1), fontSize: 12)),
                        Text('\$890',
                            style: TextStyles.bodyMedium
                                .copyWith(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 8,
                        color: Colors.white.withValues(alpha: 0.1),
                        child: const FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.6,
                          child: ColoredBox(color: Color(0xFF20C55D)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push(RouteConstants.paymentPlan.toPath),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.5), width: 0.74),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: Text('View payment plans',
                  style: TextStyles.labelLarge
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBNPLPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active BNPL Plans',
            style: TextStyles.titleMedium
                .copyWith(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        _buildBNPLPlanItem(
            'Afterpay - Nike Sneakers', '3 of 4 payments left', '\$262.50'),
        const SizedBox(height: 8),
        _buildBNPLPlanItem(
            'Klarna - AirPods Pro', '2 of 4 payments left', '\$124.50'),
      ],
    );
  }

  Widget _buildBNPLPlanItem(String title, String subtitle, String amount) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x3320C55D),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: Color(0xFF20C55D), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyles.bodyMedium
                        .copyWith(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyles.bodySmall.copyWith(
                        color: const Color(0xFFA1A1A1), fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              Text(amount,
                  style: TextStyles.bodyMedium
                      .copyWith(color: Colors.white, fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard,
              color: Color(0xFFDC8F4A), size: 32),
          const SizedBox(height: 12),
          Text('Available Rewards',
              style: TextStyles.bodySmall
                  .copyWith(color: const Color(0xFFA1A1A1), fontSize: 12)),
          const SizedBox(height: 8),
          Text('1,240 points',
              style: TextStyles.titleLarge
                  .copyWith(color: Colors.white, fontSize: 24)),
          const SizedBox(height: 4),
          Text('≈ \$12.40 cashback',
              style: TextStyles.bodySmall
                  .copyWith(color: const Color(0xFF20C55D), fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB0B0B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
              ),
              child: Text('Redeem rewards',
                  style: TextStyles.labelMedium.copyWith(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
