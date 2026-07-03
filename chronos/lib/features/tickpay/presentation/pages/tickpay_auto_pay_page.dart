import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';

class TickPayAutoPayPage extends StatefulWidget {
  const TickPayAutoPayPage({super.key});

  @override
  State<TickPayAutoPayPage> createState() => _TickPayAutoPayPageState();
}

class _TickPayAutoPayPageState extends State<TickPayAutoPayPage> {
  int _selectedMethod = 0;
  final List<bool> _enabled = [true, true, false, true];

  static const _plans = [
    _Plan('iPhone 15 Pro', 'Apple Store', '1/4', '\$249.75', 'May 22'),
    _Plan('Sony WH-1000XM5', 'Best Buy', '2/4', '\$87.25', 'May 24'),
    _Plan('Air Max Plus', 'Nike', '3/4', '\$45.00', 'May 26'),
    _Plan('MacBook Air M3', 'Apple Store', '2/5', '\$274.75', 'Jun 5'),
  ];

  @override
  Widget build(BuildContext context) {
    final activeCount = _enabled.where((e) => e).length;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
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
                    _buildPaymentMethods(),
                    const SizedBox(height: 24),
                    _buildPlans(),
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
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8)],
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Auto-Pay',
                  style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Manage automatic payments',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: Color(0xFFDC8F4A), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF00C853).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xFF00C853), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count Active Auto-Pays',
                    style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 15, fontWeight: FontWeight.w700)),
                Text(
                  'Payments deducted on due dates. Notified 2 days before.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method',
            style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _methodRow(0, Icons.account_balance_outlined, 'Bank Account', 'Checking ****4892'),
        const SizedBox(height: 10),
        _methodRow(1, Icons.credit_card, 'Debit Card', 'Visa ****7823'),
      ],
    );
  }

  Widget _methodRow(int index, IconData icon, String title, String subtitle) {
    final isSel = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? const Color(0xFF7C3AED) : Colors.grey.shade200,
            width: isSel ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
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
                      style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            if (isSel)
              Container(
                width: 22, height: 22,
                decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment Plans',
                style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => context.push(RouteConstants.tickpayActivePlans.toPath),
              child: Text('View All', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._plans.asMap().entries.map((e) {
          final i = e.key;
          final plan = e.value;
          final on = _enabled[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: on
                          ? const Color(0xFF00C853).withValues(alpha: 0.1)
                          : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.shopping_bag_outlined,
                        color: on ? const Color(0xFF00C853) : Colors.grey.shade400, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name,
                            style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(plan.installment,
                                  style: const TextStyle(color: Color(0xFF00C853), fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 6),
                            Text('Next ${plan.nextDate}',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                          ],
                        ),
                        Text('Next payment  ${plan.amount}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                  ),
                  Switch(
                    value: on,
                    onChanged: (v) => setState(() => _enabled[i] = v),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade400, size: 16),
              const SizedBox(width: 8),
              Text('How Auto-Pay Works',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5, height: 5,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(p, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _Plan {
  final String name, store, installment, amount, nextDate;
  const _Plan(this.name, this.store, this.installment, this.amount, this.nextDate);
}
