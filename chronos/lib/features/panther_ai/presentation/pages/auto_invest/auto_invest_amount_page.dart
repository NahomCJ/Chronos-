import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/panther_colors.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/router/route_constants.dart';
import '../../../domain/entities/auto_invest_enums.dart';
import '../../cubit/auto_invest_cubit.dart';
import '../../cubit/auto_invest_state.dart';

class AutoInvestAmountPage extends StatefulWidget {
  const AutoInvestAmountPage({super.key});

  @override
  State<AutoInvestAmountPage> createState() => _AutoInvestAmountPageState();
}

class _AutoInvestAmountPageState extends State<AutoInvestAmountPage> {
  final _amountController = TextEditingController(text: '250');
  String? _localError;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text.trim());

  Future<void> _continue() async {
    final amount = _amount;
    if (amount == null || amount <= 0) {
      setState(() => _localError = 'Enter a valid dollar amount.');
      return;
    }
    setState(() => _localError = null);
    final cubit = context.read<AutoInvestCubit>();
    await cubit.loadAllocationPreview(amount);
    if (!mounted) return;
    final s = cubit.state;
    if (s is AutoInvestWizardInProgress && s.allocationPreview != null) {
      context.push(RouteConstants.autoInvestPreview.toPath);
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
                : (state is AutoInvestError ? state.wizard : null) ??
                    const AutoInvestWizardInProgress();
            final isLoading = wizard.previewLoading;
            final errorMessage =
                _localError ?? (state is AutoInvestError ? state.message : null);

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'How much would you like to invest?',
                          style: TextStyles.titleMedium.copyWith(
                            color: PantherColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          child: Center(
                            child: TextField(
                              controller: _amountController,
                              textAlign: TextAlign.center,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyles.displaySmall.copyWith(
                                color: PantherColors.textPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: InputDecoration(
                                prefixText: '\$',
                                prefixStyle: TextStyles.displaySmall.copyWith(
                                  color: PantherColors.textSecondary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (_) {
                                if (_localError != null) setState(() => _localError = null);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [1000.0, 2500.0, 5000.0, 10000.0].map((v) {
                            return _PresetChip(
                              label: '\$${v.toStringAsFixed(0)}',
                              onTap: () => setState(() {
                                _amountController.text = v.toStringAsFixed(0);
                                _localError = null;
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'How often?',
                          style: TextStyles.titleMedium.copyWith(
                            color: PantherColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CadenceSegmented(
                          value: wizard.cadence,
                          onChanged: (c) => context.read<AutoInvestCubit>().selectCadence(c),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: PantherColors.negative.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: PantherColors.negative.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: PantherColors.negative, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyles.bodySmall.copyWith(
                                      color: PantherColors.negative,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                      onPressed: isLoading ? null : _continue,
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
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
            'Amount',
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

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: PantherColors.cardAlt,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: PantherColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}

class _CadenceSegmented extends StatelessWidget {
  final AutoInvestCadence value;
  final ValueChanged<AutoInvestCadence> onChanged;
  const _CadenceSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PantherColors.cardAlt,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: AutoInvestCadence.values.map((c) {
          final selected = c == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  c.label,
                  textAlign: TextAlign.center,
                  style: TextStyles.bodySmall.copyWith(
                    color: selected ? PantherColors.brand : PantherColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
