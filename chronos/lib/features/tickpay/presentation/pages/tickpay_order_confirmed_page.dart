import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_media.dart';

class TickPayOrderConfirmedPage extends StatelessWidget {
  const TickPayOrderConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TickpayColors.scaffoldLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildCheckmark(),
              const SizedBox(height: 24),
              const Text('Order Confirmed!',
                  style: TextStyle(
                      color: TickpayColors.textPrimaryLight,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Thank you for your purchase',
                  style: TextStyle(
                      color: TickpayColors.textMutedLight,
                      fontSize: 14)),
              const SizedBox(height: 4),
              const Text('Order #ORD-2029-1948',
                  style: TextStyle(
                      color: TickpayColors.textMutedLight,
                      fontSize: 12)),
              const SizedBox(height: 28),
              _buildBNPLCard(),
              const SizedBox(height: 20),
              _buildOrderDetails(),
              const SizedBox(height: 20),
              _buildWhatsNext(),
              const SizedBox(height: 28),
              _buildPrimaryButton(context),
              const SizedBox(height: 12),
              _buildSecondaryButton(context),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined,
                        color: TickpayColors.textMutedLight, size: 16),
                    label: const Text('Share',
                        style: TextStyle(
                            color: TickpayColors.textMutedLight, fontSize: 13)),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline,
                        color: TickpayColors.textMutedLight, size: 16),
                    label: const Text('Help',
                        style: TextStyle(
                            color: TickpayColors.textMutedLight, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckmark() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), TickpayColors.accentPurple],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: TickpayColors.accentPurple.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 44),
    );
  }

  Widget _buildBNPLCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TickpayColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TickpayColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: TickpayColors.accentPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_score,
                    color: TickpayColors.accentPurple, size: 16),
              ),
              const SizedBox(width: 8),
              const Text('BNPL Active',
                  style: TextStyle(
                      color: TickpayColors.textPrimaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              const Text('Pay over time, interest-free',
                  style: TextStyle(
                      color: TickpayColors.textMutedLight, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          _bnplRow('First Payment', '\$249.75 Today'),
          _bnplRow('Next Payment', 'May 21, 2026'),
          _bnplRow('Remaining', '3 payments'),
        ],
      ),
    );
  }

  Widget _bnplRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: TickpayColors.textMutedLight, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: TickpayColors.textPrimaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TickpayColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TickpayColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Details',
              style: TextStyle(
                  color: TickpayColors.textPrimaryLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              TickPayImage(
                TickPayMedia.iphone15Pro,
                width: 50,
                height: 50,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('iPhone 15 Pro',
                        style: TextStyle(
                            color: TickpayColors.textPrimaryLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Text('Qty: 1',
                        style: TextStyle(
                            color: TickpayColors.textMutedLight, fontSize: 12)),
                  ],
                ),
              ),
              const Text('\$999',
                  style: TextStyle(
                      color: TickpayColors.textPrimaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: TickpayColors.divider, height: 20),
          _detailRow('Shipping Method', 'Standard Shipping'),
          _detailRow('Estimated Delivery', 'May 12–15, 2026'),
          _detailRow(
              'Delivery Address', '123 Main St, San Francisco, CA 94102'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    color: TickpayColors.textMutedLight, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: TickpayColors.textPrimaryLight, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNext() {
    final steps = [
      ('Order Confirmation Email',
          'Check your email for order details and tracking info.'),
      ('Track Your Order',
          'You\'ll receive tracking updates as your order ships.'),
      ('Payment Reminders',
          'We\'ll remind you before each payment is due.'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TickpayColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TickpayColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's Next?",
              style: TextStyle(
                  color: TickpayColors.textPrimaryLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: TickpayColors.accentPurple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: const TextStyle(
                                color: TickpayColors.accentPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value.$1,
                              style: const TextStyle(
                                  color: TickpayColors.textPrimaryLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(e.value.$2,
                              style: const TextStyle(
                                  color: TickpayColors.textMutedLight,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            context.push(RouteConstants.tickpayOrderHistory.toPath),
        style: ElevatedButton.styleFrom(
          backgroundColor: TickpayColors.info,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text('View Order Details',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => context
            .pushReplacement(RouteConstants.tickpayDiscover.toPath),
        style: OutlinedButton.styleFrom(
          foregroundColor: TickpayColors.textPrimaryLight,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: TickpayColors.divider),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Continue Shopping',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
