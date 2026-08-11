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

/// Entry point for "Auto-Invest with Chris". Pitches the feature to a user
/// with no plan; routes straight to the dashboard if one already exists —
/// nobody should see this pitch twice.
class AutoInvestIntroPage extends StatefulWidget {
  const AutoInvestIntroPage({super.key});

  @override
  State<AutoInvestIntroPage> createState() => _AutoInvestIntroPageState();
}

class _AutoInvestIntroPageState extends State<AutoInvestIntroPage> {
  @override
  void initState() {
    super.initState();
    context.read<AutoInvestCubit>().checkActivePlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantherColors.bg,
      body: SafeArea(
        child: BlocBuilder<AutoInvestCubit, AutoInvestState>(
          builder: (context, state) {
            if (state is AutoInvestLoading || state is AutoInvestInitial) {
              return const Center(
                child: CircularProgressIndicator(color: PantherColors.brand),
              );
            }
            if (state is AutoInvestDashboardLoaded) {
              return _ExistingPlanView(plan: state.plan);
            }
            return const _PitchView();
          },
        ),
      ),
    );
  }
}

class _ExistingPlanView extends StatelessWidget {
  final AutoInvestPlanEntity plan;
  const _ExistingPlanView({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: PantherColors.brand.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_graph_rounded, color: PantherColors.brand, size: 28),
          ),
          const SizedBox(height: 18),
          Text(
            'Your Auto-Invest plan is already running',
            textAlign: TextAlign.center,
            style: TextStyles.titleLarge.copyWith(
              color: PantherColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${plan.amountUsd.toStringAsFixed(0)} · ${plan.cadence.label} · ${plan.status.label}',
            textAlign: TextAlign.center,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.brand,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Head to your dashboard to see what\'s executed, what\'s planned, and manage the plan.',
            textAlign: TextAlign.center,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(RouteConstants.autoInvestDashboard.toPath),
              style: ElevatedButton.styleFrom(
                backgroundColor: PantherColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 46),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(
                'View Dashboard',
                style: TextStyles.labelLarge.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchView extends StatelessWidget {
  const _PitchView();

  static const _bullets = [
    (
      Icons.pie_chart_rounded,
      'Automatic diversification',
      'Chris spreads your money across crypto, stocks and ETFs based on your risk profile and goal.',
    ),
    (
      Icons.verified_user_rounded,
      'You confirm every investment',
      'Nothing happens without you. Chris proposes a mix — you tap "Confirm & Invest" before anything executes.',
    ),
    (
      Icons.tune_rounded,
      'Pause, adjust or cancel anytime',
      'Full control from the Auto-Invest dashboard — this isn\'t a black box.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded, color: PantherColors.textSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: PantherColors.brand.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_graph_rounded, color: PantherColors.brand, size: 24),
                ),
                const SizedBox(height: 18),
                Text(
                  'Let Chris invest for you',
                  style: TextStyles.headlineSmall.copyWith(
                    color: PantherColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tell Chris a dollar amount, a risk tolerance and a goal. Chris proposes a diversified mix — you decide if it happens.',
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textSecondary,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                ..._bullets.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _BulletCard(icon: b.$1, title: b.$2, body: b.$3),
                    )),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PantherColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PantherColors.info.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: PantherColors.info, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Today, only the crypto portion of your plan actually executes. Stock and ETF picks are shown as a planned target — brokerage trading is coming soon.',
                          style: TextStyles.bodySmall.copyWith(
                            color: PantherColors.textPrimary,
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AutoInvestCubit>().startWizard();
                    context.push(RouteConstants.autoInvestGoals.toPath);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PantherColors.brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyles.labelLarge.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Not now',
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BulletCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _BulletCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PantherColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: PantherColors.brand.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: PantherColors.brand, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyles.bodySmall.copyWith(
                    color: PantherColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
