import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/onboarding_entities.dart';
import '../constants/tickpay_colors.dart';
import 'tickpay_glyph.dart';

/// Selectable payment-method row on the Link Your Wallets screen.
class WalletOptionTile extends StatelessWidget {
  final WalletOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const WalletOptionTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? TickpayColors.brandRed.withValues(alpha: 0.1)
              : TickpayColors.glassFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? TickpayColors.brandRed
                : TickpayColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: TickpayGlyph(
                asset: option.iconAsset,
                color: TickpayColors.textOnDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      option.title,
                      style: TextStyles.titleMedium.copyWith(
                        color: TickpayColors.textOnDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (option.isRecommended) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Recommended',
                        style: TextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _SelectionIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: TickpayColors.brandRedDark,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
    );
  }
}

/// A timeline step on the Verification Status card.
class VerificationStepTile extends StatelessWidget {
  final VerificationStep step;
  final IconData icon;
  final bool isLast;

  const VerificationStepTile({
    super.key,
    required this.step,
    required this.icon,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(color: TickpayColors.glassStrong),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: TickpayColors.glassStrong,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    step.title,
                    style: TextStyles.titleMedium.copyWith(
                      color: TickpayColors.textOnDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.subtitle,
                    style: TextStyles.bodySmall
                        .copyWith(color: TickpayColors.textMutedDark),
                  ),
                ],
              ),
            ),
          ),
          if (step.isCompleted)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.check_circle,
                  color: TickpayColors.brandRed, size: 22),
            ),
        ],
      ),
    );
  }
}

/// A "What's next" highlight on the completion screen.
class OnboardingHighlightTile extends StatelessWidget {
  final OnboardingHighlight highlight;
  final VoidCallback? onTap;

  const OnboardingHighlightTile({
    super.key,
    required this.highlight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TickpayColors.glassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TickpayColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: TickpayGlyph(
                asset: highlight.iconAsset,
                color: TickpayColors.textOnDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight.title,
                    style: TextStyles.titleMedium.copyWith(
                      color: TickpayColors.textOnDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    highlight.subtitle,
                    style: TextStyles.bodySmall
                        .copyWith(color: TickpayColors.textMutedDark),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward,
                color: TickpayColors.textMutedDark, size: 20),
          ],
        ),
      ),
    );
  }
}
