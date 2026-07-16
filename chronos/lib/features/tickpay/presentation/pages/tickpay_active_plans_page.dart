import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/tickpay_colors.dart';

class TickPayActivePlansPage extends StatefulWidget {
  const TickPayActivePlansPage({super.key});

  @override
  State<TickPayActivePlansPage> createState() => _TickPayActivePlansPageState();
}

class _TickPayActivePlansPageState extends State<TickPayActivePlansPage> {
  int? _expandedIndex;

  static const _plans = [
    _Plan(
      brand: 'Amazon',
      tag: 'Electronics',
      tagColor: TickpayColors.chipElectronicsText,
      tagBg: TickpayColors.chipElectronicsBg,
      icon: Icons.shopping_cart_outlined,
      iconColor: Color(0xFFFF9900),
      paid: 3,
      total: 4,
      amount: '\$3xx',
      totalAmount: '\$599',
      paidAmount: '\$449.25',
      remaining: '\$149.75',
      nextPayment: '\$149.75',
      progress: 0.75,
    ),
    _Plan(
      brand: 'Nike',
      tag: 'Fashion',
      tagColor: TickpayColors.chipFashionText,
      tagBg: TickpayColors.chipFashionBg,
      icon: Icons.check_circle_outline,
      iconColor: Colors.white,
      paid: 2,
      total: 3,
      amount: '\$450',
      totalAmount: '\$450',
      paidAmount: '\$300.00',
      remaining: '\$150.00',
      nextPayment: '\$150.00',
      progress: 0.67,
    ),
    _Plan(
      brand: 'Apple Store',
      tag: 'Electronics',
      tagColor: TickpayColors.chipElectronicsText,
      tagBg: TickpayColors.chipElectronicsBg,
      icon: Icons.apple,
      iconColor: Colors.white,
      paid: 2,
      total: 4,
      amount: '\$1,299',
      totalAmount: '\$1,299',
      paidAmount: '\$649.50',
      remaining: '\$649.50',
      nextPayment: '\$324.75',
      progress: 0.50,
    ),
    _Plan(
      brand: 'IKEA',
      tag: 'Home',
      tagColor: TickpayColors.chipHomeText,
      tagBg: TickpayColors.chipHomeBg,
      icon: Icons.home_outlined,
      iconColor: Color(0xFF34D399),
      paid: 1,
      total: 5,
      amount: '\$850',
      totalAmount: '\$850',
      paidAmount: '\$170.00',
      remaining: '\$680.00',
      nextPayment: '\$170.00',
      progress: 0.20,
    ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: TickpayColors.scaffoldDark,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _buildPlanCard(context, i, _plans[i]),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Active Plans',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '4 active installments',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: TickpayColors.warning,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [TickpayColors.accentPurple, TickpayColors.scaffoldDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Remaining',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    '\$1,629.25',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.attach_money, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, int index, _Plan plan) {
    final isExpanded = _expandedIndex == index;
    return GestureDetector(
      onTap: () =>
          setState(() => _expandedIndex = isExpanded ? null : index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TickpayColors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: plan.iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(plan.icon, color: plan.iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.brand,
                            style: const TextStyle(
                              color: TickpayColors.textPrimaryLight,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: plan.tagBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              plan.tag,
                              style: TextStyle(
                                color: plan.tagColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan.paid} of ${plan.total} payments made',
                        style: const TextStyle(
                          color: TickpayColors.textMutedLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  plan.totalAmount,
                  style: const TextStyle(
                    color: TickpayColors.textPrimaryLight,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              _buildProgressSection(plan),
              const SizedBox(height: 14),
              _buildExpandedDetails(plan),
              const SizedBox(height: 14),
              _buildViewDetailsButton(context),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _expandedIndex = null),
                child: const Text(
                  'See Less',
                  style: TextStyle(
                    color: TickpayColors.accentPurple,
                    fontSize: 13,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              _buildViewDetailsButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(_Plan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                color: TickpayColors.textMutedLight,
                fontSize: 12,
              ),
            ),
            Text(
              '${(plan.progress * 100).toInt()}%',
              style: const TextStyle(
                color: TickpayColors.textPrimaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: plan.progress,
            backgroundColor: TickpayColors.divider,
            valueColor: const AlwaysStoppedAnimation(TickpayColors.accentPurple),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedDetails(_Plan plan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TickpayColors.neutralSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TickpayColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailCol('Paid', plan.paidAmount, TickpayColors.positive),
              _detailCol('Remaining', plan.remaining, TickpayColors.textPrimaryLight),
            ],
          ),
          const Divider(color: TickpayColors.divider, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Next Payment',
                style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 12),
              ),
              Text(
                plan.nextPayment,
                style: const TextStyle(
                  color: TickpayColors.textPrimaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: TickpayColors.textMutedLight, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: valueColor, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildViewDetailsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: TickpayColors.scaffoldDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'View Details',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _Plan {
  final String brand, tag, amount, totalAmount, paidAmount, remaining, nextPayment;
  final Color tagColor, tagBg, iconColor;
  final IconData icon;
  final int paid, total;
  final double progress;

  const _Plan({
    required this.brand,
    required this.tag,
    required this.tagColor,
    required this.tagBg,
    required this.icon,
    required this.iconColor,
    required this.paid,
    required this.total,
    required this.amount,
    required this.totalAmount,
    required this.paidAmount,
    required this.remaining,
    required this.nextPayment,
    required this.progress,
  });
}
