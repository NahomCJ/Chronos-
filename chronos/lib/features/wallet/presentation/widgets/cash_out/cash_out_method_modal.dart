import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'cash_out_amount_modal.dart';

class CashOutMethodModal extends StatelessWidget {
  const CashOutMethodModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const CashOutMethodModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.68,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F8FC), Color(0xFFE8E8F5)],
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
            // Header with progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  'Cash Out',
                  style: TextStyles.titleLarge.copyWith(
                    color: const Color(0xFF12122A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Color(0xFF12122A), size: 24),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Progress indicator
            Row(
              children: [
                _buildProgressStep(true),
                _buildProgressLine(false),
                _buildProgressStep(false),
                _buildProgressLine(false),
                _buildProgressStep(false),
              ],
            ),

            const SizedBox(height: 40),

            // Title
            Text(
              'Select withdrawal method',
              style: TextStyles.titleMedium.copyWith(
                color: const Color(0xFF12122A),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // Method options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMethodOption(
                      icon: Icons.account_balance,
                      title: 'Bank Money',
                      subtitle: 'Instant',
                      onTap: () {
                        Navigator.of(context).pop();
                        CashOutAmountModal.show(context, 'Bank Money');
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildMethodOption(
                      icon: Icons.phone_android,
                      title: 'Mobile Money',
                      subtitle: 'Instant',
                      onTap: () {
                        Navigator.of(context).pop();
                        CashOutAmountModal.show(context, 'Mobile Money');
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildMethodOption(
                      icon: Icons.person,
                      title: 'Agent Withdrawal',
                      subtitle: 'Find nearby agents',
                      onTap: () {
                        Navigator.of(context).pop();
                        CashOutAmountModal.show(context, 'Agent Withdrawal');
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildMethodOption(
                      icon: Icons.currency_bitcoin,
                      title: 'Crypto Off-ramp',
                      subtitle: 'Convert to crypto',
                      onTap: () {
                        Navigator.of(context).pop();
                        CashOutAmountModal.show(context, 'Crypto Off-ramp');
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildMethodOption(
                      icon: Icons.account_circle,
                      title: 'Chronos Account',
                      subtitle: 'Instant & Free',
                      onTap: () {
                        Navigator.of(context).pop();
                        CashOutAmountModal.show(context, 'Chronos Account');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(bool isActive) {
    return Container(
      width: 110,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD184CC) : const Color(0xFFE6C5E4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        color: isActive ? const Color(0xFFD184CC) : const Color(0xFFE6C5E4),
      ),
    );
  }

  Widget _buildMethodOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF12122A).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF12122A).withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyLarge.copyWith(
                      color: const Color(0xFF12122A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF12122A).withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: const Color(0xFF12122A).withValues(alpha: 0.45),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
