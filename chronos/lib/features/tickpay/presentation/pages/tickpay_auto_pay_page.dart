import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TickPayAutoPayPage extends StatefulWidget {
  const TickPayAutoPayPage({super.key});

  @override
  State<TickPayAutoPayPage> createState() => _TickPayAutoPayPageState();
}

class _TickPayAutoPayPageState extends State<TickPayAutoPayPage> {
  int _selectedMethod = 0;
  final List<bool> _autoPayEnabled = [true, true, false, true];

  static const _plans = [
    _AutoPlan('iPhone 15 Pro', 'Apple Store', '1/4', '\$249.75', 'May 22'),
    _AutoPlan('Sony WH-1000XM5', 'Best Buy', '2/4', '\$87.25', 'May 24'),
    _AutoPlan('Air Max Plus', 'Nike', '3/4', '\$45.00', 'May 26'),
    _AutoPlan('MacBook Air M3', 'Apple Store', '2/5', '\$274.75', 'Jun 5'),
  ];

  @override
  Widget build(BuildContext context) {
    final activeCount = _autoPayEnabled.where((e) => e).length;
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
                        const SizedBox(height: 16),
                        _buildActiveCard(activeCount),
                        const SizedBox(height: 24),
                        _buildPaymentMethodSection(),
                        const SizedBox(height: 24),
                        _buildPlansSection(),
                        const SizedBox(height: 24),
                        _buildHowItWorks(),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Auto-Pay',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Manage automatic payments',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: Color(0xFFDC8F4A), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard(int activeCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00C853).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF00C853).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Color(0xFF00C853), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$activeCount Active Auto-Pays',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text(
                    'Payments are automatically deducted on due dates. You will receive a notification 2 days before each payment.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _methodRow(0, Icons.account_balance_outlined, 'Bank Account',
            'Checking ****4892'),
        const SizedBox(height: 10),
        _methodRow(1, Icons.credit_card, 'Debit Card', 'Visa ****7823'),
      ],
    );
  }

  Widget _methodRow(int index, IconData icon, String title, String subtitle) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF7C3AED).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 18),
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
                    color: Color(0xFF7C3AED), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment Plans',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text('View All',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        ..._plans.asMap().entries.map((e) {
          final i = e.key;
          final plan = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _autoPayEnabled[i]
                          ? const Color(0xFF00C853).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: _autoPayEnabled[i]
                          ? const Color(0xFF00C853)
                          : Colors.white38,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(plan.installment,
                                  style: const TextStyle(
                                      color: Color(0xFF00C853),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 6),
                            Text('Next ${plan.nextDate}',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 11)),
                          ],
                        ),
                        Text('Next payment  ${plan.amount}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoPayEnabled[i],
                    onChanged: (v) =>
                        setState(() => _autoPayEnabled[i] = v),
                    activeColor: const Color(0xFF00C853),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHowItWorks() {
    final points = [
      'Payments are deducted automatically on due dates.',
      'You can pause auto-pay anytime before the due date.',
      'Notifications are sent 2 days before each payment.',
      'Ensure sufficient funds to avoid late fees.',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              const Text('How Auto-Pay Works',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: const BoxDecoration(
                          color: Colors.white38, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(p,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _AutoPlan {
  final String name, store, installment, amount, nextDate;
  const _AutoPlan(
      this.name, this.store, this.installment, this.amount, this.nextDate);
}
