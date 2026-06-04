import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../utils/tickpay_media.dart';

class TickPayBnplCheckoutPage extends StatefulWidget {
  const TickPayBnplCheckoutPage({super.key});

  @override
  State<TickPayBnplCheckoutPage> createState() =>
      _TickPayBnplCheckoutPageState();
}

class _TickPayBnplCheckoutPageState extends State<TickPayBnplCheckoutPage> {
  int _selectedPlan = 1;
  int _selectedMethod = 0;
  bool _agreedToTerms = false;

  static const _plans = [
    _Plan(2, 'Monthly', 499.50),
    _Plan(4, 'Bi-weekly', 249.75, mostPopular: true),
    _Plan(6, 'Bi-weekly', 166.50),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withValues(alpha: 0.5)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductCard(),
                        const SizedBox(height: 24),
                        _buildPlanSelector(),
                        const SizedBox(height: 24),
                        _buildPaymentSchedule(),
                        const SizedBox(height: 20),
                        _buildTotalRow(),
                        const SizedBox(height: 24),
                        _buildPaymentMethod(),
                        const SizedBox(height: 20),
                        _buildTerms(),
                        const SizedBox(height: 24),
                        _buildAcceptButton(context),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Your first payment of \$249.75 will be charged today',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.35),
                                fontSize: 11),
                          ),
                        ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text('BNPL Checkout',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          TickPayImage(
            TickPayMedia.iphone15Pro,
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('iPhone 15 Pro',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Order Total',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12)),
              ],
            ),
          ),
          const Text('\$999',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Your Plan',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._plans.asMap().entries.map((e) {
          final i = e.key;
          final plan = e.value;
          final isSelected = _selectedPlan == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedPlan = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.1)),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white38,
                              width: 1.5),
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.black, size: 12)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${plan.count} Payments',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text(plan.frequency,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              '\$${plan.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text('per payment',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('0% APR',
                              style: const TextStyle(
                                  color: Color(0xFF00C853),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  if (plan.mostPopular)
                    Positioned(
                      top: -2,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Most Popular',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaymentSchedule() {
    final dates = ['Today', 'May 21, 2026', 'Jun 4, 2026', 'Jun 18, 2026'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Schedule',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: dates.asMap().entries.map((e) {
              final isFirst = e.key == 0;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: e.key < dates.length - 1
                      ? Border(
                          bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.06)))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isFirst
                            ? const Color(0xFF00A693).withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: isFirst
                          ? const Icon(Icons.check,
                              color: Color(0xFF00A693), size: 14)
                          : Center(
                              child: Text('${e.key + 1}',
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 11))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value,
                              style: TextStyle(
                                  color: isFirst
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          Text('Payment ${e.key + 1} of 4',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    const Text('\$249.75',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total Amount',
            style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const Text('\$999.00',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _methodOption(0, Icons.account_balance_outlined, 'Bank Account',
            'Checking ****4892'),
        const SizedBox(height: 10),
        _methodOption(
            1, Icons.credit_card, 'Debit Card', 'Visa ****7823'),
      ],
    );
  }

  Widget _methodOption(
      int index, IconData icon, String title, String subtitle) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                    color: Color(0xFF00A693), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: _agreedToTerms
                      ? const Color(0xFF00A693)
                      : Colors.white38),
              color: _agreedToTerms
                  ? const Color(0xFF00A693)
                  : Colors.transparent,
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              children: const [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                        color: Color(0xFF7C3AED),
                        decoration: TextDecoration.underline)),
                TextSpan(text: ' and '),
                TextSpan(
                    text: 'Payment Agreement',
                    style: TextStyle(
                        color: Color(0xFF7C3AED),
                        decoration: TextDecoration.underline)),
                TextSpan(
                    text:
                        '. I understand that missing payments may result in fees and impact my credit score.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _agreedToTerms
            ? () => context.pushReplacement(
                RouteConstants.tickpayOrderConfirmed.toPath)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _agreedToTerms ? Colors.white : Colors.white.withValues(alpha: 0.2),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32)),
          elevation: 0,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.15),
          disabledForegroundColor: Colors.white38,
        ),
        child: const Text('Accept Terms to Continue',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Plan {
  final int count;
  final String frequency;
  final double amount;
  final bool mostPopular;
  const _Plan(this.count, this.frequency, this.amount,
      {this.mostPopular = false});
}
