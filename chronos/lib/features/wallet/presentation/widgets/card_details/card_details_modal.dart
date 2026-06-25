import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'authentication_modal.dart';
import '../card_settings/card_settings_modal.dart';

class CardDetailsModal extends StatelessWidget {
  const CardDetailsModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const CardDetailsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.35,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),

            /// âœ… Buttons centered vertically & horizontally
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: _buildModalOption(
                    context: context,
                    title: 'Card Details',
                    onTap: () {
                      Navigator.of(context).pop();
                      AuthenticationModal.show(context);
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    borderColor: Colors.white.withValues(alpha: 0.35),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: _buildModalOption(
                    context: context,
                    title: 'Card Settings',
                    onTap: () {
                      Navigator.of(context).pop();
                      CardSettingsModal.show(context);
                    },
                    backgroundColor: const Color(0xFFB0B0B0),
                    borderColor: const Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalOption({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.75, // ðŸ‘ˆ horizontal increase
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
