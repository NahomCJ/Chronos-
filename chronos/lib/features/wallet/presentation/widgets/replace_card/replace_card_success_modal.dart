import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

class ReplaceCardSuccessModal extends StatelessWidget {
  const ReplaceCardSuccessModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ReplaceCardSuccessModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF16161D), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Success checkmark
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E27),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 38),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Card Ordered!',
              style: TextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            // Description
            Text(
              'Your replacement card is on the way',
              textAlign: TextAlign.center,
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Delivery estimate
            Text(
              'Estimated delivery: 5-7 business days',
              textAlign: TextAlign.center,
              style: TextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),

            const Spacer(),

            // Done button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFB0B0B0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Done',
                  textAlign: TextAlign.center,
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
