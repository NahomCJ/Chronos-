import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'new_debit_card_form_modal.dart';

class AddNewCardModal extends StatelessWidget {
  const AddNewCardModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const AddNewCardModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            // Header with progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Bank Transfer',
                      style: TextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

            const SizedBox(height: 24),

            // Progress indicator
            Row(
              children: [
                _buildProgressStep(true),
                _buildProgressLine(true),
                _buildProgressStep(true),
                _buildProgressLine(false),
                _buildProgressStep(false),
                _buildProgressLine(false),
                _buildProgressStep(false),
              ],
            ),

            const SizedBox(height: 32),

            // Fee info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8C630).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFFF8C630).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8C630).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFFF8C630),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instant Transfer Fee',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Color(0xFFF8C630),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A 1.5% fee applies to debit card transfers for instant delivery.',
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Add new debit card button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                NewDebitCardFormModal.show(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFFF8C630),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Color(0xFFF8C630), size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Add new debit card',
                      style: TextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Saved debit cards section
            Text(
              'Saved debit cards',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Saved cards list
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSavedCard(
                      cardType: 'Visa',
                      cardNumber: '**** 4521',
                      cardHolder: 'John Doe',
                      expiryDate: 'Expires 12/26',
                      onTap: () {
                        // TODO: Handle saved card selection
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildSavedCard(
                      cardType: 'Mastercard',
                      cardNumber: '**** 4521',
                      cardHolder: 'John Doe',
                      expiryDate: 'Expires 12/26',
                      onTap: () {
                        // TODO: Handle saved card selection
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
      width: 80,
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

  Widget _buildSavedCard({
    required String cardType,
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8C630).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.credit_card,
                color: Color(0xFFF8C630),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$cardType $cardNumber',
                    style: TextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$cardHolder • $expiryDate',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
