import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_colors.dart';
import '../widgets/widgets.dart';

/// Final onboarding screen confirming setup is complete ("You're All Set!").
class TickpayCompletionPage extends StatelessWidget {
  const TickpayCompletionPage({super.key});

  void _goToDashboard(BuildContext context) =>
      context.go(RouteConstants.tickpayDashboard.toPath);

  @override
  Widget build(BuildContext context) {
    final highlights = sl<TickpayRepository>().getOnboardingHighlights();

    return Scaffold(
      backgroundColor: TickpayColors.pureBlack,
      body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
            TickpayBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  children: [
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 44),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Text(
                        "You're All Set!",
                        style: TextStyles.displaySmall.copyWith(
                          color: TickpayColors.textOnDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Welcome to TickPay. Start shopping smarter with '
                        'flexible payments.',
                        textAlign: TextAlign.center,
                        style: TextStyles.bodyLarge.copyWith(
                          color: TickpayColors.textMutedDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "WHAT'S NEXT",
                      style: TextStyles.labelMedium.copyWith(
                        color: TickpayColors.textMutedDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final highlight in highlights) ...[
                      OnboardingHighlightTile(
                        highlight: highlight,
                        onTap: () => _goToDashboard(context),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  children: [
                    TickpayPrimaryButton(
                      label: 'Go to Dashboard',
                      onPressed: () => _goToDashboard(context),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _goToDashboard(context),
                      child: Text(
                        'Explore features first',
                        style: TextStyles.bodyMedium
                            .copyWith(color: TickpayColors.textMutedDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
          ],
        ),
    );
  }
}
