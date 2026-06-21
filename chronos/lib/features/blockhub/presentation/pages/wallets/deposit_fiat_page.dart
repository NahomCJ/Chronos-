import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

class DepositFiatPage extends StatefulWidget {
  const DepositFiatPage({super.key});
  @override
  State<DepositFiatPage> createState() => _DepositFiatPageState();
}

class _DepositFiatPageState extends State<DepositFiatPage> {
  String _method = 'bank';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
          Positioned.fill(
            child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
          ),
          SafeArea(
            child: Column(
              children: [
                _header(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _selectMethod(),
                        const SizedBox(height: 16),
                        if (_method == 'bank') _bankDetails(),
                        const SizedBox(height: 16),
                        _depositLimits(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Column(
            children: [
              Text(
                'Deposit Fiat',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                'Add fiat currency to your wallet',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectMethod() {
    return _card(
      'Select Deposit Method',
      Column(
        children: [
          _methodOption(
            'bank',
            Icons.account_balance_outlined,
            'Bank Transfer',
            'Fee: Free • 1-3 business days',
          ),
          const SizedBox(height: 8),
          _methodOption(
            'card',
            Icons.credit_card_outlined,
            'Debit/Credit Card',
            'Fee: 2.9% • Instant',
          ),
        ],
      ),
    );
  }

  Widget _methodOption(
    String value,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final sel = _method == value;
    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              sel
                  ? const Color(0xFF7C3AED).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                sel
                    ? const Color(0xFF7C3AED).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  sel
                      ? const Color(0xFFAB7FF8)
                      : Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
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

  Widget _bankDetails() {
    return _card(
      'Bank Transfer Details',
      Column(
        children: [
          _infoField('Account Name', 'BlockHub Inc.'),
          const SizedBox(height: 10),
          _infoField('Account Number', '1234567890'),
          const SizedBox(height: 10),
          _infoField('Routing Number', '021000021'),
          const SizedBox(height: 10),
          _infoField('Reference Code (Important!)', 'BHUB-987654'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please include the reference code in your transfer to ensure funds are credited to your account.',
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF3B82F6),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _depositLimits() {
    return _card(
      'Deposit Limits',
      Column(
        children: [
          _limitRow('Daily Limit', '\$50,000', Colors.white),
          Divider(
            color: Colors.white.withValues(alpha: 0.07),
            height: 16,
            thickness: 0.5,
          ),
          _limitRow('Monthly Limit', '\$500,000', Colors.white),
          Divider(
            color: Colors.white.withValues(alpha: 0.07),
            height: 16,
            thickness: 0.5,
          ),
          _limitRow('Used Today', '\$12,500', const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _limitRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
