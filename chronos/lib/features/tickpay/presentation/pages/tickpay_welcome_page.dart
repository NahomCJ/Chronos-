import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../constants/tickpay_colors.dart';
import '../widgets/widgets.dart';

/// Entry screen of the TickPay onboarding flow ("Shop Smart. Pay Later.").
class TickpayWelcomePage extends StatelessWidget {
  const TickpayWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TickpayColors.pureBlack,
      body: TickpayBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                const Center(child: _BrandPill()),
                const Spacer(flex: 2),
                RichText(
                  text: TextSpan(
                    style: TextStyles.displayMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Shop Smart.\n',
                        style: TextStyle(color: TickpayColors.textOnDark),
                      ),
                      TextSpan(
                        text: 'Pay Later.',
                        style: TextStyle(color: Color(0xFFC9B6F0)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Experience the future of shopping with AI-powered '
                  'recommendations and flexible payment options tailored '
                  'just for you.',
                  style: TextStyles.bodyLarge.copyWith(
                    color: TickpayColors.textMutedDark,
                    height: 1.5,
                  ),
                ),
                const Spacer(flex: 3),
                TickpayPrimaryButton(
                  label: 'Get Started',
                  onPressed: () => context.push(
                    RouteConstants.tickpayLinkWallets.toPath,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: TickpayColors.glassFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TickpayColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF2D7E), Color(0xFFFF5C8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.task_alt, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            'TickPay',
            style: TextStyles.headlineSmall.copyWith(
              color: TickpayColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
