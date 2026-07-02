import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/text_theme.dart';

final NumberFormat _moneyFormat = NumberFormat('#,##0.00');
String _money(double value) => '\$${_moneyFormat.format(value)}';

class CashOutConfirmationModal extends StatelessWidget {
  final String method;
  final double amount;

  const CashOutConfirmationModal({
    super.key,
    required this.method,
    required this.amount,
  });

  static void show(BuildContext context, String method, double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder:
          (context) => CashOutConfirmationModal(method: method, amount: amount),
    );
  }

  String get methodDisplay {
    switch (method) {
      case 'Bank Money':
        return 'Bank Transfer';
      case 'Mobile Money':
        return 'Mobile Money';
      case 'Agent Withdrawal':
        return 'Agent Withdrawal';
      case 'Crypto Off-ramp':
        return 'Crypto Transfer';
      case 'Chronos Account':
        return 'Chronos Account';
      default:
        return method;
    }
  }

  String get expectedTime {
    switch (method) {
      case 'Bank Money':
        return '1-2 business days';
      case 'Mobile Money':
        return 'Instant';
      case 'Agent Withdrawal':
        return 'Find nearby agent';
      case 'Crypto Off-ramp':
        return '5-10 minutes';
      case 'Chronos Account':
        return 'Instant';
      default:
        return 'Instant';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fee = method == 'Chronos Account' ? 0.0 : 0.0; // All free for demo
    final total = amount + fee;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
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
                const SizedBox(width: 24),
                Text(
                  'Cash Out',
                  style: TextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
                _buildProgressLine(true),
                _buildProgressStep(true),
              ],
            ),

            const SizedBox(height: 40),

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
                  children: [
                    // Amount
                    _buildDetailRow('Amount', _money(amount)),

                    const SizedBox(height: 20),

                    // Fee
                    _buildDetailRow('Fee', '\$${fee.toStringAsFixed(2)}'),

                    const SizedBox(height: 20),

                    // Method
                    _buildDetailRow('Method', methodDisplay),

                    const SizedBox(height: 20),

                    // Expected Time
                    _buildDetailRow('Expected Time', expectedTime),

                    const SizedBox(height: 32),

                    // Divider
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),

                    const SizedBox(height: 32),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _money(total),
                          style: TextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Confirm button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cash out of ${_money(amount)} initiated successfully',
                    ),
                    backgroundColor: const Color(0xFF10B981),
                  ),
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
                  'Confirm with Biometrics',
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
