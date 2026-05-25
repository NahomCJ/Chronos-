import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'replace_card_confirmation_modal.dart';

class ReplaceCardAddressModal extends StatefulWidget {
  final String reason;

  const ReplaceCardAddressModal({super.key, required this.reason});

  static void show(BuildContext context, String reason) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReplaceCardAddressModal(reason: reason),
    );
  }

  @override
  State<ReplaceCardAddressModal> createState() =>
      _ReplaceCardAddressModalState();
}

class _ReplaceCardAddressModalState extends State<ReplaceCardAddressModal> {
  final _streetController = TextEditingController(text: '123 Main Street');
  final _cityController = TextEditingController(text: 'New York');
  final _stateController = TextEditingController(text: 'NY');
  final _zipController = TextEditingController(text: '10001');
  final _countryController = TextEditingController(text: 'United States');

  bool _expressDelivery = false;

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

            const SizedBox(height: 24),

            // Address fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(_streetController),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_cityController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(_stateController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_zipController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(_countryController)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Delivery option
                    GestureDetector(
                      onTap:
                          () => setState(
                            () => _expressDelivery = !_expressDelivery,
                          ),
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Express Delivery',
                                    style: TextStyles.bodyLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '2-3 business days (+\$15)',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child:
                                  _expressDelivery
                                      ? const Icon(
                                        Icons.circle,
                                        color: Color(0xFFB0B0B0),
                                        size: 16,
                                      )
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Continue button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                ReplaceCardConfirmationModal.show(
                  context,
                  widget.reason,
                  _streetController.text,
                  _cityController.text,
                  _stateController.text,
                  _zipController.text,
                  _countryController.text,
                  _expressDelivery,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFB0B0B0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Continue',
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

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyles.bodyMedium.copyWith(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
