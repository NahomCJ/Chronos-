import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'replace_card_address_modal.dart';

class ReplaceCardReasonModal extends StatefulWidget {
  const ReplaceCardReasonModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ReplaceCardReasonModal(),
    );
  }

  @override
  State<ReplaceCardReasonModal> createState() => _ReplaceCardReasonModalState();
}

class _ReplaceCardReasonModalState extends State<ReplaceCardReasonModal> {
  String? _selectedReason;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Text(
                      'Replace Card',
                      style: TextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chronos Platinum •••• 4829',
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Divider line
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.2),
            ),

            const SizedBox(height: 32),

            // Question
            Text(
              'Why do you need a replacement card?',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // Reason options
            _buildReasonOption(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title: 'Lost Card',
              subtitle: 'I cannot find my card',
              value: 'lost',
            ),

            const SizedBox(height: 16),

            _buildReasonOption(
              icon: Icons.warning,
              iconColor: Colors.orange,
              title: 'Stolen Card',
              subtitle: 'My card was stolen',
              value: 'stolen',
            ),

            const SizedBox(height: 16),

            _buildReasonOption(
              icon: Icons.credit_card,
              iconColor: const Color(0xFF10B981),
              title: 'Damaged Card',
              subtitle: 'Card is worn or damaged',
              value: 'damaged',
            ),

            const SizedBox(height: 16),

            _buildReasonOption(
              icon: Icons.credit_card,
              iconColor: const Color(0xFF10B981),
              title: 'Upgrade Card',
              subtitle: 'I was a new design',
              value: 'upgrade',
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedReason == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = value;
        });

        // Navigate to address modal after selection
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).pop();
          ReplaceCardAddressModal.show(context, value);
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF5DAA9A)
                    : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
