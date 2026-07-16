import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'replace_card_success_modal.dart';

class ReplaceCardConfirmationModal extends StatelessWidget {
  final String reason;
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;
  final bool expressDelivery;

  const ReplaceCardConfirmationModal({
    super.key,
    required this.reason,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.expressDelivery,
  });

  static void show(
    BuildContext context,
    String reason,
    String street,
    String city,
    String state,
    String zip,
    String country,
    bool expressDelivery,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => ReplaceCardConfirmationModal(
            reason: reason,
            street: street,
            city: city,
            state: state,
            zip: zip,
            country: country,
            expressDelivery: expressDelivery,
          ),
    );
  }

  String get reasonText {
    switch (reason) {
      case 'lost':
        return 'Lost Card';
      case 'stolen':
        return 'Stolen Card';
      case 'damaged':
        return 'Damaged Card';
      case 'upgrade':
        return 'Upgrade Card';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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

            // Confirmation details
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Card
                    _buildDetailRow(
                      icon: Icons.credit_card,
                      iconColor: Colors.orange,
                      title: 'Current Card',
                      subtitle: 'Chronos Platinum •••• 4829',
                    ),

                    const SizedBox(height: 24),

                    // Reason
                    _buildDetailRow(
                      icon: Icons.warning,
                      iconColor: Colors.orange,
                      title: 'Reason',
                      subtitle: reasonText,
                    ),

                    const SizedBox(height: 24),

                    // Delivery Address
                    _buildDetailRow(
                      icon: Icons.location_on,
                      iconColor: Colors.orange,
                      title: 'Delivery Address',
                      subtitle: '$street, $city\n$state $zip, $country',
                    ),

                    const SizedBox(height: 24),

                    // Shipping
                    _buildDetailRow(
                      icon: Icons.local_shipping,
                      iconColor: Colors.orange,
                      title: 'Shipping',
                      subtitle:
                          expressDelivery
                              ? 'Express (2-3 days)'
                              : 'Standard (5-7 days)',
                    ),

                    // Note
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note:',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your current card will be deactivated once the replacement is shipped.',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                ReplaceCardSuccessModal.show(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFB0B0B0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Order Replacement Card',
                  textAlign: TextAlign.center,
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
