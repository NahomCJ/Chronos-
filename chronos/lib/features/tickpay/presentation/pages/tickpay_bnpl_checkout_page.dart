import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/tickpay_account_cubit.dart';
import '../bloc/tickpay_account_state.dart';
import '../utils/tickpay_media.dart';
import '../constants/tickpay_colors.dart';

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
      backgroundColor: TickpayColors.scaffoldLight,
      body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
            Column(
        children: [
          Container(
            color: TickpayColors.scaffoldDark,
            child: SafeArea(
              bottom: false,
              child: _buildHeader(context),
            ),
          ),
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
                  const Center(
                    child: Text(
                      'Your first payment of \$249.75 will be charged today',
                      style: TextStyle(color: TickpayColors.textMutedDark, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
          ],
        ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
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
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TickpayColors.accentPurple.withValues(alpha: 0.85),
            TickpayColors.accentPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
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
                        color: Colors.white.withValues(alpha: 0.5),
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
                color: TickpayColors.textPrimaryLight,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
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
                    ? TickpayColors.accentPurple.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? TickpayColors.accentPurple
                        : TickpayColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                                  ? TickpayColors.accentPurple
                                  : TickpayColors.divider,
                              width: 1.5),
                          color: isSelected
                              ? TickpayColors.accentPurple
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 12)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${plan.count} Payments',
                              style: const TextStyle(
                                  color: TickpayColors.textPrimaryLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text(plan.frequency,
                              style: const TextStyle(
                                  color: TickpayColors.textMutedLight, fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${plan.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: TickpayColors.textPrimaryLight,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const Text('per payment',
                              style: TextStyle(
                                  color: TickpayColors.textMutedLight, fontSize: 11)),
                          const SizedBox(height: 2),
                          const Text('0% APR',
                              style: TextStyle(
                                  color: TickpayColors.positive,
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
                          gradient: LinearGradient(
                            colors: [
                              TickpayColors.accentPurple.withValues(alpha: 0.85),
                              TickpayColors.accentPurple,
                            ],
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
                color: TickpayColors.textPrimaryLight,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TickpayColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: dates.asMap().entries.map((e) {
              final isFirst = e.key == 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: e.key < dates.length - 1
                      ? const Border(
                          bottom: BorderSide(color: TickpayColors.divider))
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isFirst
                            ? TickpayColors.positive.withValues(alpha: 0.15)
                            : TickpayColors.neutralSurface,
                        shape: BoxShape.circle,
                      ),
                      child: isFirst
                          ? const Icon(Icons.check,
                              color: TickpayColors.positive, size: 14)
                          : Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: TickpayColors.textMutedLight, fontSize: 11))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value,
                              style: TextStyle(
                                  color: isFirst
                                      ? TickpayColors.textPrimaryLight
                                      : TickpayColors.textMutedLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          Text('Payment ${e.key + 1} of 4',
                              style: const TextStyle(
                                  color: TickpayColors.textMutedLight, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Text('\$249.75',
                        style: TextStyle(
                            color: TickpayColors.textPrimaryLight,
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
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total Amount',
            style: TextStyle(
                color: TickpayColors.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        Text('\$999.00',
            style: TextStyle(
                color: TickpayColors.textPrimaryLight,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method',
            style: TextStyle(
                color: TickpayColors.textPrimaryLight,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _methodOption(0, Icons.account_balance_outlined, 'Bank Account',
            'Checking ****4892'),
        const SizedBox(height: 10),
        _methodOption(1, Icons.credit_card, 'Debit Card', 'Visa ****7823'),
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
              ? TickpayColors.accentPurple.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? TickpayColors.accentPurple
                  : TickpayColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TickpayColors.accentPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: TickpayColors.accentPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: TickpayColors.textPrimaryLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: TickpayColors.textMutedLight, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                    color: TickpayColors.accentPurple, shape: BoxShape.circle),
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
                      ? TickpayColors.positive
                      : TickpayColors.divider),
              color: _agreedToTerms
                  ? TickpayColors.positive
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
            text: const TextSpan(
              style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 12),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                        color: TickpayColors.accentPurple,
                        decoration: TextDecoration.underline)),
                TextSpan(text: ' and '),
                TextSpan(
                    text: 'Payment Agreement',
                    style: TextStyle(
                        color: TickpayColors.accentPurple,
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
    return BlocConsumer<TickpayAccountCubit, TickpayAccountState>(
      listener: (context, state) {
        if (state is TickpayPurchaseSuccess) {
          context.pushReplacement(RouteConstants.tickpayOrderConfirmed.toPath);
        } else if (state is TickpayActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: TickpayColors.negative,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TickpayActionLoading;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_agreedToTerms && !isLoading)
                ? () {
                    final plan = _plans[_selectedPlan];
                    context.read<TickpayAccountCubit>().createPurchase(
                          amount: plan.count * plan.amount,
                          merchant: 'TickPay Purchase',
                        );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TickpayColors.brandRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              elevation: 0,
              disabledBackgroundColor: TickpayColors.neutralSurface,
              disabledForegroundColor: TickpayColors.textMutedLight,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Accept & Confirm Purchase',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        );
      },
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
