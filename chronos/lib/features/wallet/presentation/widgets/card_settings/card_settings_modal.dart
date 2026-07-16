import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

import '../pin_management/change_pin_auth_modal.dart';
import '../replace_card/replace_card_reason_modal.dart';
import 'spending_limits_modal.dart';

class CardSettingsModal extends StatefulWidget {
  const CardSettingsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CardSettingsModal(),
    );
  }

  @override
  State<CardSettingsModal> createState() => _CardSettingsModalState();
}

class _CardSettingsModalState extends State<CardSettingsModal> {
  bool _contactlessPayments = true;
  bool _internationalTransactions = true;
  bool _onlinePayments = true;
  bool _transactionAlerts = false;
  bool _magneticStripe = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
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
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Card Settings',
                      style: TextStyles.titleLarge.copyWith(
                        color: const Color(0xFF12122A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chronos Platinum •••• 4829',
                      style: TextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF12122A).withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Color(0xFF12122A), size: 24),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            height: 1,
            width: double.infinity,
            color: const Color(0xFF12122A).withValues(alpha: 0.1),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Controls Section
                  Text(
                    'Card Controls',
                    style: TextStyles.titleMedium.copyWith(
                      color: const Color(0xFF12122A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildToggleItem(
                    icon: Icons.contactless,
                    title: 'Contactless Payments',
                    subtitle: 'Enable NFC tap-to-pay',
                    value: _contactlessPayments,
                    onChanged:
                        (value) => setState(() => _contactlessPayments = value),
                  ),

                  _buildToggleItem(
                    icon: Icons.public,
                    title: 'International Transactions',
                    subtitle: 'Allow payments abroad',
                    value: _internationalTransactions,
                    onChanged:
                        (value) =>
                            setState(() => _internationalTransactions = value),
                  ),

                  _buildToggleItem(
                    icon: Icons.shopping_cart,
                    title: 'Online Payments',
                    subtitle: 'Enable e-commerce transactions',
                    value: _onlinePayments,
                    onChanged:
                        (value) => setState(() => _onlinePayments = value),
                  ),

                  _buildToggleItem(
                    icon: Icons.notifications,
                    title: 'Transaction Alerts',
                    subtitle: 'Get notified for every transaction',
                    value: _transactionAlerts,
                    onChanged:
                        (value) => setState(() => _transactionAlerts = value),
                  ),

                  _buildToggleItem(
                    icon: Icons.credit_card,
                    title: 'Magnetic Stripe',
                    subtitle: 'Allow swipe transactions',
                    value: _magneticStripe,
                    onChanged:
                        (value) => setState(() => _magneticStripe = value),
                  ),

                  const SizedBox(height: 32),

                  // Manage Card Section
                  Text(
                    'Manage Card',
                    style: TextStyles.titleMedium.copyWith(
                      color: const Color(0xFF12122A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildActionItem(
                    icon: Icons.attach_money,
                    title: 'Spending Limits',
                    subtitle: 'Set daily & monthly limits',
                    onTap: () {
                      Navigator.of(context).pop();
                      SpendingLimitsModal.show(context);
                    },
                  ),

                  _buildActionItem(
                    icon: Icons.lock,
                    title: 'Change PIN',
                    subtitle: 'Update your card PIN',
                    onTap: () {
                      Navigator.of(context).pop();
                      ChangePinAuthModal.show(context);
                    },
                  ),

                  _buildActionItem(
                    icon: Icons.credit_card,
                    title: 'Replace Card',
                    subtitle: 'Order a new card',
                    onTap: () {
                      Navigator.of(context).pop();
                      ReplaceCardReasonModal.show(context);
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF12122A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF12122A), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF12122A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFF12122A).withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF12122A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF12122A), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF12122A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyles.bodySmall.copyWith(
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
