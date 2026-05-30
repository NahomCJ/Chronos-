import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_colors.dart';
import '../widgets/widgets.dart';

/// Shows the (already-approved) KYC verification timeline.
class TickpayVerificationPage extends StatelessWidget {
  const TickpayVerificationPage({super.key});

  static const _stepIcons = [Icons.search, Icons.verified_outlined];

  @override
  Widget build(BuildContext context) {
    final steps = sl<TickpayRepository>().getVerificationSteps();

    return Scaffold(
      backgroundColor: TickpayColors.pureBlack,
      body: TickpayBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TickpayCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    Center(
                      child: Text(
                        'Verification Status',
                        style: TextStyles.displaySmall.copyWith(
                          color: TickpayColors.textOnDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        "We're reviewing your information",
                        style: TextStyles.bodyLarge
                            .copyWith(color: TickpayColors.textMutedDark),
                      ),
                    ),
                    const SizedBox(height: 36),
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: TickpayColors.glassFill,
                              borderRadius: BorderRadius.circular(24),
                              border:
                                  Border.all(color: TickpayColors.glassBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.task_alt,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Verified',
                                  style: TextStyles.labelLarge.copyWith(
                                    color: TickpayColors.textOnDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          for (int i = 0; i < steps.length; i++)
                            VerificationStepTile(
                              step: steps[i],
                              icon: _stepIcons[i % _stepIcons.length],
                              isLast: i == steps.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        '🎉 Your account is ready to use!',
                        style: TextStyles.titleMedium.copyWith(
                          color: TickpayColors.textOnDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: TickpayPrimaryButton(
                  label: 'Continue',
                  onPressed: () =>
                      context.push(RouteConstants.tickpayCompletion.toPath),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
