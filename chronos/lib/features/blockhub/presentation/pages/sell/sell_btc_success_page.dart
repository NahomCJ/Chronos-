import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

class SellBtcSuccessPage extends StatelessWidget {
  final double btcAmount;
  final double usdAmount;
  final double totalReceived;

  const SellBtcSuccessPage({
    super.key,
    required this.btcAmount,
    required this.usdAmount,
    required this.totalReceived,
  });

  String get transactionId => '#TXSI7DNC892';
  String get transactionDate => '1/29/2026';
  String get transactionTime => '11:05:15 PM';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
          // Background Image
          Positioned.fill(
            child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Success Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.red, size: 40),
                  ),

                  const SizedBox(height: 32),

                  // Success Title
                  Text(
                    'Sale Successful!',
                    style: TextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isSmallScreen ? 24 : 28,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Success Description
                  Text(
                    'Your Bitcoin has been sold\nsuccessfully',
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isSmallScreen ? 16 : 18,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Transaction Details Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildTransactionDetailRow(
                          'Transaction ID',
                          transactionId,
                        ),
                        const SizedBox(height: 16),
                        _buildTransactionDetailRow('Date', transactionDate),
                        const SizedBox(height: 16),
                        _buildTransactionDetailRow('Time', transactionTime),
                        const SizedBox(height: 16),
                        _buildTransactionDetailRow(
                          'BTC Sold',
                          '${btcAmount.toStringAsFixed(6)} BTC',
                        ),
                        const SizedBox(height: 16),
                        _buildTransactionDetailRow(
                          'Amount Received',
                          '\$${totalReceived.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 16),
                        // Status with red badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: TextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red, width: 1),
                              ),
                              child: Text(
                                'Completed',
                                style: TextStyles.bodySmall.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action Buttons
                  Column(
                    children: [
                      // Go to Dashboard Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate back to BlockHub page
                            Navigator.of(context).popUntil(
                              (route) =>
                                  route.settings.name == '/blockhub' ||
                                  route.isFirst,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Go to Dashboard',
                            style: TextStyles.titleMedium.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // View Market Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate back to BlockHub/Market
                            Navigator.of(context).popUntil(
                              (route) =>
                                  route.settings.name == '/blockhub' ||
                                  route.isFirst,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'View Market',
                            style: TextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Footer Note
                  Text(
                    'Your updated balance will be reflected in your portfolio',
                    textAlign: TextAlign.center,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
