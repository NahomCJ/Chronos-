import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/panther_colors.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/router/route_constants.dart';
import '../../../domain/entities/auto_invest_enums.dart';
import '../../cubit/auto_invest_cubit.dart';
import '../../cubit/auto_invest_state.dart';

class AutoInvestGoalsPage extends StatelessWidget {
  const AutoInvestGoalsPage({super.key});

  static const _risks = [
    (
      AutoInvestRiskProfile.conservative,
      'Conservative',
      'Favors stability — smaller crypto slice, larger ETF/bond-like weighting.',
      Icons.shield_outlined,
    ),
    (
      AutoInvestRiskProfile.balanced,
      'Balanced',
      'A middle ground between growth and stability across all three asset classes.',
      Icons.balance_rounded,
    ),
    (
      AutoInvestRiskProfile.aggressive,
      'Aggressive',
      'Favors growth — larger crypto and stock weighting, higher volatility.',
      Icons.rocket_launch_rounded,
    ),
  ];

  static const _goals = [
    (AutoInvestGoal.growth, 'Growth'),
    (AutoInvestGoal.income, 'Income'),
    (AutoInvestGoal.retirement, 'Retirement'),
    (AutoInvestGoal.shortTerm, 'Short-Term'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantherColors.bg,
      body: SafeArea(
        child: BlocBuilder<AutoInvestCubit, AutoInvestState>(
          builder: (context, state) {
            final wizard = state is AutoInvestWizardInProgress
                ? state
                : const AutoInvestWizardInProgress();
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
                        Text(
                          'Risk tolerance',
                          style: TextStyles.titleMedium.copyWith(
                            color: PantherColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How much ups and downs are you comfortable with?',
                          style: TextStyles.bodySmall.copyWith(
                            color: PantherColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ..._risks.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _RiskCard(
                                selected: wizard.riskProfile == r.$1,
                                icon: r.$4,
                                title: r.$2,
                                description: r.$3,
                                onTap: () =>
                                    context.read<AutoInvestCubit>().selectRiskProfile(r.$1),
                              ),
                            )),
                        const SizedBox(height: 24),
                        Text(
                          'Goal',
                          style: TextStyles.titleMedium.copyWith(
                            color: PantherColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What is this money for?',
                          style: TextStyles.bodySmall.copyWith(
                            color: PantherColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _goals
                              .map((g) => _GoalChip(
                                    selected: wizard.goal == g.$1,
                                    label: g.$2,
                                    onTap: () =>
                                        context.read<AutoInvestCubit>().selectGoal(g.$1),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<AutoInvestCubit, AutoInvestState>(
        builder: (context, state) {
          final wizard = state is AutoInvestWizardInProgress
              ? state
              : const AutoInvestWizardInProgress();
          final canContinue = wizard.hasRiskAndGoal;
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () => context.push(RouteConstants.autoInvestAmount.toPath)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PantherColors.brand,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: PantherColors.brand.withValues(alpha: 0.35),
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
          );
        },
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
            'Risk & Goal',
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

class _RiskCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RiskCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? PantherColors.brand.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? PantherColors.brand : PantherColors.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: PantherColors.brand.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: PantherColors.brand, size: 17),
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
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyles.bodySmall.copyWith(
                      color: PantherColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? PantherColors.brand : Colors.transparent,
                border: Border.all(
                  color: selected ? PantherColors.brand : PantherColors.textSubtle,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;
  const _GoalChip({required this.selected, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? PantherColors.brand : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: selected ? PantherColors.brand : PantherColors.border),
        ),
        child: Text(
          label,
          style: TextStyles.bodyMedium.copyWith(
            color: selected ? Colors.white : PantherColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
