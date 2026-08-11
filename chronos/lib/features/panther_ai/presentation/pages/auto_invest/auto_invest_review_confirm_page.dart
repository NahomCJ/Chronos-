import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/panther_colors.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/router/route_constants.dart';
import '../../../domain/entities/auto_invest_enums.dart';
import '../../cubit/auto_invest_cubit.dart';
import '../../cubit/auto_invest_state.dart';

class AutoInvestReviewConfirmPage extends StatelessWidget {
  const AutoInvestReviewConfirmPage({super.key});

  String _riskLabel(AutoInvestRiskProfile r) {
    switch (r) {
      case AutoInvestRiskProfile.conservative:
        return 'Conservative';
      case AutoInvestRiskProfile.balanced:
        return 'Balanced';
      case AutoInvestRiskProfile.aggressive:
        return 'Aggressive';
    }
  }

  String _goalLabel(AutoInvestGoal g) {
    switch (g) {
      case AutoInvestGoal.growth:
        return 'Growth';
      case AutoInvestGoal.income:
        return 'Income';
      case AutoInvestGoal.retirement:
        return 'Retirement';
      case AutoInvestGoal.shortTerm:
        return 'Short-Term';
    }
  }

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<AutoInvestCubit>();
    await cubit.confirmPlan();
    if (!context.mounted) return;
    if (cubit.state is AutoInvestPlanConfirmed) {
      context.push(RouteConstants.autoInvestSuccess.toPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantherColors.bg,
      body: SafeArea(
        child: BlocBuilder<AutoInvestCubit, AutoInvestState>(
          builder: (context, state) {
            final wizard = state is AutoInvestWizardInProgress
                ? state
                : (state is AutoInvestError ? state.wizard : null);

            if (wizard == null ||
                !wizard.hasRiskAndGoal ||
                wizard.amountUsd == null ||
                wizard.allocationPreview == null) {
              return Column(
                children: [
                  _buildHeader(context),
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Something\'s missing from your plan — go back and start over.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: PantherColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final isLoading = wizard.previewLoading;
            final errorMessage = state is AutoInvestError ? state.message : null;

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
                        _buildSummaryCard(wizard),
                        const SizedBox(height: 18),
                        _buildDisclosure(),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _buildErrorBanner(errorMessage),
                        ],
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
                      onPressed: isLoading ? null : () => _confirm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PantherColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 46),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              errorMessage != null ? 'Try Again' : 'Confirm & Invest',
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

  Widget _buildSummaryCard(AutoInvestWizardInProgress wizard) {
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
          Text(
            'Plan Summary',
            style: TextStyles.titleMedium.copyWith(
              color: PantherColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow('Amount', '\$${wizard.amountUsd!.toStringAsFixed(2)}'),
          _divider(),
          _summaryRow('Cadence', wizard.cadence.label),
          _divider(),
          _summaryRow('Risk profile', _riskLabel(wizard.riskProfile!)),
          _divider(),
          _summaryRow('Goal', _goalLabel(wizard.goal!)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyles.bodyMedium.copyWith(color: PantherColors.textSecondary, fontSize: 14)),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: PantherColors.border, height: 1, thickness: 0.5);

  Widget _buildDisclosure() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: PantherColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PantherColors.warning.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: PantherColors.warning, size: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before you confirm',
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Crypto orders execute immediately at the current market price through your BlockHub wallet. '
                  'Stock and ETF portions are saved as your target plan and will execute once brokerage trading '
                  'is available — they are NOT purchased today. You can pause or cancel this plan anytime from '
                  'the Auto-Invest dashboard.',
                  style: TextStyles.bodySmall.copyWith(
                    color: PantherColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PantherColors.negative.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PantherColors.negative.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: PantherColors.negative, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyles.bodySmall.copyWith(color: PantherColors.negative, fontSize: 12.5),
            ),
          ),
        ],
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
            'Review & Confirm',
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
