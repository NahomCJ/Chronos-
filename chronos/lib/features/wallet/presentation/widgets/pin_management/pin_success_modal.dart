import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

class PinSuccessModal extends StatelessWidget {
  const PinSuccessModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const PinSuccessModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF302B48), Color(0xFF6D64A5)],
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
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'PIN Updated',
              style: TextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              'PIN Updated Successfully',
              style: TextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'Your new PIN now active for Chronos Platinum',
              textAlign: TextAlign.center,
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),

            
            const SizedBox(height: 20),
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
