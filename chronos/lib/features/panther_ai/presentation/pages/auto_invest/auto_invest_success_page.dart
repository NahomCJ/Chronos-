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

class AutoInvestSuccessPage extends StatelessWidget {
  const AutoInvestSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantherColors.bg,
      body: SafeArea(
        child: BlocBuilder<AutoInvestCubit, AutoInvestState>(
          builder: (context, state) {
            if (state is! AutoInvestPlanConfirmed) {
              return const Center(
                child: Text(
                  'No confirmed plan to show.',
                  style: TextStyle(color: PantherColors.textSecondary),
                ),
              );
            }

            final plan = state.plan;
            final executions = plan.latestRoundExecutions;
            final hasFailure = executions.any((e) => e.status == AutoInvestExecutionStatus.failed);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: (hasFailure ? PantherColors.warning : PantherColors.positive)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasFailure ? PantherColors.warning : PantherColors.positive,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      hasFailure ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      color: hasFailure ? PantherColors.warning : PantherColors.positive,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hasFailure ? 'Plan created — some legs need attention' : 'Plan confirmed!',
                    textAlign: TextAlign.center,
                    style: TextStyles.titleLarge.copyWith(
                      color: PantherColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Here\'s exactly what happened with round 1 — what executed, and what\'s planned.',
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyMedium.copyWith(
                        color: PantherColors.textSecondary,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: PantherColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Round 1',
                          style: TextStyles.titleMedium.copyWith(
                            color: PantherColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (executions.isEmpty)
                          Text(
                            'No execution details were returned for this round.',
                            style: TextStyles.bodySmall.copyWith(color: PantherColors.textSecondary),
                          )
                        else
                          ...executions.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ExecutionRow(execution: e),
                              )),
                      ],
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Text(
                        'View Dashboard',
                        style: TextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(RouteConstants.pantherAi.toPath),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: PantherColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: PantherColors.border),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: TextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: PantherColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExecutionRow extends StatelessWidget {
  final AutoInvestExecutionEntity execution;
  const _ExecutionRow({required this.execution});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (execution.status) {
      AutoInvestExecutionStatus.executed => (Icons.check_circle_rounded, PantherColors.positive, 'Executed'),
      AutoInvestExecutionStatus.planned => (Icons.schedule_rounded, PantherColors.warning, 'Planned'),
      AutoInvestExecutionStatus.failed => (Icons.error_rounded, PantherColors.negative, 'Failed'),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PantherColors.cardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      execution.symbol,
                      style: TextStyles.bodyMedium.copyWith(
                        color: PantherColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyles.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${execution.amountUsd.toStringAsFixed(2)}',
                  style: TextStyles.bodySmall.copyWith(color: PantherColors.textSecondary, fontSize: 11.5),
                ),
                if (execution.status == AutoInvestExecutionStatus.failed &&
                    (execution.failureReason?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 4),
                  Text(
                    execution.failureReason!,
                    style: TextStyles.bodySmall.copyWith(color: PantherColors.negative, fontSize: 11.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
