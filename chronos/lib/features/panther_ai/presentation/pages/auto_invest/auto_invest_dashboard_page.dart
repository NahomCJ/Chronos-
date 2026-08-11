import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/panther_colors.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../domain/entities/auto_invest.dart';
import '../../../domain/entities/auto_invest_enums.dart';
import '../../cubit/auto_invest_cubit.dart';
import '../../cubit/auto_invest_state.dart';
import '../../widgets/panther_ring_chart.dart';

class AutoInvestDashboardPage extends StatefulWidget {
  const AutoInvestDashboardPage({super.key});

  @override
  State<AutoInvestDashboardPage> createState() => _AutoInvestDashboardPageState();
}

class _AutoInvestDashboardPageState extends State<AutoInvestDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AutoInvestCubit>().loadDashboard();
  }

  Color _colorFor(AutoInvestAssetClass assetClass) {
    switch (assetClass) {
      case AutoInvestAssetClass.crypto:
        return PantherColors.brand;
      case AutoInvestAssetClass.stock:
        return PantherColors.info;
      case AutoInvestAssetClass.etf:
        return PantherColors.positive;
    }
  }

  Color _statusColor(AutoInvestPlanStatus status) {
    switch (status) {
      case AutoInvestPlanStatus.active:
        return PantherColors.positive;
      case AutoInvestPlanStatus.paused:
        return PantherColors.warning;
      case AutoInvestPlanStatus.completed:
        return PantherColors.info;
      case AutoInvestPlanStatus.cancelled:
        return PantherColors.negative;
      case AutoInvestPlanStatus.pendingConfirmation:
        return PantherColors.textSecondary;
    }
  }

  Future<void> _confirmCancel(BuildContext context, String planId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Cancel this plan?',
          style: TextStyles.titleMedium.copyWith(color: PantherColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Future rounds will stop. Anything already executed is not reversed.',
          style: TextStyles.bodyMedium.copyWith(color: PantherColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Keep Plan', style: TextStyles.bodyMedium.copyWith(color: PantherColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Cancel Plan',
              style: TextStyles.bodyMedium.copyWith(color: PantherColors.negative, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AutoInvestCubit>().cancelPlan(planId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantherColors.bg,
      body: SafeArea(
        child: BlocConsumer<AutoInvestCubit, AutoInvestState>(
          listener: (context, state) {
            if (state is AutoInvestDashboardLoaded && state.actionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionError!), backgroundColor: PantherColors.negative),
              );
            }
          },
          builder: (context, state) {
            if (state is AutoInvestLoading || state is AutoInvestInitial) {
              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator(color: PantherColors.brand)),
                  ),
                ],
              );
            }

            if (state is AutoInvestNoPlan) {
              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No Auto-Invest plan yet.',
                          style: TextStyle(color: PantherColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is AutoInvestError) {
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: PantherColors.negative),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<AutoInvestCubit>().loadDashboard(),
                              style: ElevatedButton.styleFrom(backgroundColor: PantherColors.brand),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is! AutoInvestDashboardLoaded) {
              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(child: SizedBox.shrink()),
                ],
              );
            }

            final plan = state.plan;
            final slices = <PantherRingSlice>[];
            for (final a in plan.allocations) {
              slices.add(PantherRingSlice(
                label: a.symbol,
                value: a.percentage,
                color: _colorFor(a.assetClass),
              ));
            }

            return RefreshIndicator(
              color: PantherColors.brand,
              onRefresh: () => context.read<AutoInvestCubit>().refreshPlan(plan.id),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildStatusCard(plan),
                          const SizedBox(height: 18),
                          if (slices.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: PantherColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: PantherRingChart(
                                slices: slices,
                                centerLabel: '\$${plan.amountUsd.toStringAsFixed(0)}',
                                centerSubLabel: 'Target mix',
                              ),
                            ),
                          const SizedBox(height: 18),
                          _buildActions(context, plan, state.actionLoading),
                          const SizedBox(height: 24),
                          Text(
                            'Execution History',
                            style: TextStyles.titleMedium.copyWith(
                              color: PantherColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (plan.executions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No rounds executed yet.',
                                style: TextStyles.bodySmall.copyWith(color: PantherColors.textSecondary),
                              ),
                            )
                          else
                            ...plan.executions.reversed.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ExecutionHistoryRow(execution: e),
                              ),
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(AutoInvestPlanEntity plan) {
    final statusColor = _statusColor(plan.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PantherColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${plan.amountUsd.toStringAsFixed(0)} · ${plan.cadence.label}',
                style: TextStyles.titleMedium.copyWith(
                  color: PantherColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  plan.status.label,
                  style: TextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Round ${plan.roundsCompleted} completed'
            '${plan.nextRoundAt != null ? ' · Next round ${DateFormat.yMMMd().format(plan.nextRoundAt!)}' : ''}',
            style: TextStyles.bodySmall.copyWith(color: PantherColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AutoInvestPlanEntity plan, bool actionLoading) {
    final isPaused = plan.status == AutoInvestPlanStatus.paused;
    final isActive = plan.status == AutoInvestPlanStatus.active;
    final canToggle = isActive || isPaused;
    final canCancel = isActive || isPaused;

    return Column(
      children: [
        if (isActive)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: actionLoading ? null : () => context.read<AutoInvestCubit>().investNextRound(plan.id),
              icon: actionLoading
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
              label: Text(
                'Invest Next Round Now',
                style: TextStyles.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PantherColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                minimumSize: const Size(double.infinity, 44),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ),
        if (isActive) const SizedBox(height: 10),
        if (canToggle)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: actionLoading
                      ? null
                      : () => context.read<AutoInvestCubit>().togglePause(plan.id, isPaused: isPaused),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PantherColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    minimumSize: const Size(double.infinity, 44),
                    side: const BorderSide(color: PantherColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text(
                    isPaused ? 'Resume' : 'Pause',
                    style: TextStyles.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (canCancel) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: actionLoading ? null : () => _confirmCancel(context, plan.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PantherColors.negative,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      minimumSize: const Size(double.infinity, 44),
                      side: BorderSide(color: PantherColors.negative.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyles.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
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
            'Auto-Invest',
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

class _ExecutionHistoryRow extends StatelessWidget {
  final AutoInvestExecutionEntity execution;
  const _ExecutionHistoryRow({required this.execution});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (execution.status) {
      AutoInvestExecutionStatus.executed => (Icons.check_circle_rounded, PantherColors.positive, 'Executed'),
      AutoInvestExecutionStatus.planned => (Icons.schedule_rounded, PantherColors.warning, 'Planned'),
      AutoInvestExecutionStatus.failed => (Icons.error_rounded, PantherColors.negative, 'Failed'),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PantherColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${execution.symbol} · Round ${execution.roundNumber}',
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (execution.status == AutoInvestExecutionStatus.failed &&
                    (execution.failureReason?.isNotEmpty ?? false))
                  Text(
                    execution.failureReason!,
                    style: TextStyles.bodySmall.copyWith(color: PantherColors.negative, fontSize: 11),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${execution.amountUsd.toStringAsFixed(2)}',
                style: TextStyles.bodyMedium.copyWith(
                  color: PantherColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                label,
                style: TextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
