import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';

class TickPayUpcomingPaymentsPage extends StatelessWidget {
  const TickPayUpcomingPaymentsPage({super.key});

  static const _payments = [
    _Payment('iPhone 15 Pro', 'Apple Store', '\$249.75', '1 of 4', 'Due Today', true),
    _Payment('Sony WH-1000XM5', 'Best Buy', '\$87.25', '2 of 4', 'Due Soon', true),
    _Payment('Air Max Plus', 'Nike', '\$45.00', '3 of 4', 'Due Soon', false),
    _Payment('MacBook Air M3', 'Apple Store', '\$274.75', '2 of 5', 'Scheduled', true),
    _Payment('55" 4K TV', 'Samsung', '\$149.75', '1 of 4', 'Scheduled', true),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Due Today': return const Color(0xFFEF4444);
      case 'Due Soon':  return const Color(0xFFF59E0B);
      default:          return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildDueTodayCard(),
            _buildCalendarCard(),
            Expanded(child: _buildPaymentList(context)),
          ],
        ),
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
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8)],
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E), size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upcoming Payments',
                  style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Manage your payment schedule',
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

  Widget _buildDueTodayCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF9F67FF)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Due Today',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('\$249.75',
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('May 2026',
                    style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 15, fontWeight: FontWeight.w700)),
                Row(children: [
                  Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 22),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
                ]),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((d) => Text(d,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11,
                      fontWeight: FontWeight.w600))).toList(),
            ),
            const SizedBox(height: 6),
            _calRow([1,2,3,4,5,6,7], []),
            _calRow([8,9,10,11,12,13,14], []),
            _calRow([15,16,17,18,19,20,21], []),
            _calRow([22,23,24,25,26,27,28], [24, 28]),
            _calRow([29,30,null,null,null,null,null], []),
          ],
        ),
      ),
    );
  }

  Widget _calRow(List<int?> days, List<int> marked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          if (d == null) return const SizedBox(width: 30, height: 30);
          final isMarked = marked.contains(d);
          return Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: isMarked ? const Color(0xFF7C3AED) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$d', style: TextStyle(
                color: isMarked ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 13,
                fontWeight: isMarked ? FontWeight.bold : FontWeight.normal,
              )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text('All Payments',
              style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _buildRow(context, _payments[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, _Payment p) {
    final sc = _statusColor(p.status);
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayRepayNow.toPath),
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
              decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.shopping_bag_outlined, color: sc, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(p.store,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(p.amount,
                    style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: sc.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(p.status,
                          style: TextStyle(color: sc, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    if (p.autoPay) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Auto-pay',
                            style: TextStyle(color: Color(0xFF00C853), fontSize: 10, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Payment {
  final String name, store, amount, installment, status;
  final bool autoPay;
  const _Payment(this.name, this.store, this.amount, this.installment, this.status, this.autoPay);
}
