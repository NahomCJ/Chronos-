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
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => const CardDetailsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.62,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Card Options',
                  style: TextStyles.titleMedium.copyWith(
                    color: const Color(0xFF12122A),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                _buildModalOption(
                  context: context,
                  title: 'Card Details',
                  onTap: () {
                    Navigator.of(context).pop();
                    AuthenticationModal.show(context);
                  },
                  isDark: true,
                ),
                const SizedBox(height: 10),
                _buildModalOption(
                  context: context,
                  title: 'Card Settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    CardSettingsModal.show(context);
                  },
                  isDark: false,
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
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0F0F2A), Color(0xFF2D2D5A)],
                )
              : null,
          color: isDark ? null : const Color(0xFFF0F0F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.transparent
                : const Color(0xFF12122A).withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white : const Color(0xFF12122A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward,
              color: isDark
                  ? Colors.white
                  : const Color(0xFF12122A).withValues(alpha: 0.55),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
