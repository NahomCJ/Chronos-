import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';

class TickPayUpcomingPaymentsPage extends StatelessWidget {
  const TickPayUpcomingPaymentsPage({super.key});

  static const _payments = [
    _Payment('iPhone 15 Pro', 'Apple Store', '\$249.75', '1 of 4', 'Due Today',
        true, true),
    _Payment('Sony WH-1000XM5', 'Best Buy', '\$87.25', '2 of 4', 'Due Soon',
        true, true),
    _Payment(
        'Air Max Plus', 'Nike', '\$45.00', '3 of 4', 'Due Soon', false, false),
    _Payment('MacBook Air M3', 'Apple Store', '\$274.75', '2 of 5',
        'Scheduled', true, true),
    _Payment(
        '55" 4K TV', 'Samsung', '\$149.75', '1 of 4', 'Scheduled', true, true),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Due Today':
        return const Color(0xFFFF5252);
      case 'Due Soon':
        return const Color(0xFFDC8F4A);
      default:
        return const Color(0xFF7C3AED);
    }
  }

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
                _buildDueTodayCard(),
                _buildCalendarCard(),
                Expanded(child: _buildPaymentList(context)),
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
              const Text('Upcoming Payments',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Manage your payment schedule',
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

  Widget _buildDueTodayCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1C2E), Color(0xFF2D1F3D)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Due Today',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12)),
                  const Text('\$249.75',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFFF5252).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.calendar_today,
                  color: Color(0xFFFF5252), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('May 2026',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Icon(Icons.chevron_left,
                        color: Colors.white.withValues(alpha: 0.5), size: 20),
                    Icon(Icons.chevron_right,
                        color: Colors.white.withValues(alpha: 0.5), size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days
                  .map((d) => Text(d,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11)))
                  .toList(),
            ),
            const SizedBox(height: 8),
            _buildCalendarWeek([1, 2, 3, 4, 5, 6, 7], []),
            _buildCalendarWeek([8, 9, 10, 11, 12, 13, 14], []),
            _buildCalendarWeek([15, 16, 17, 18, 19, 20, 21], []),
            _buildCalendarWeek([22, 23, 24, 25, 26, 27, 28], [24, 28]),
            _buildCalendarWeek([29, 30, null, null, null, null, null], []),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarWeek(List<int?> days, List<int> highlighted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          if (d == null) return const SizedBox(width: 28, height: 28);
          final isHighlighted = highlighted.contains(d);
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF7C3AED)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$d',
                  style: TextStyle(
                      color: isHighlighted
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: isHighlighted
                          ? FontWeight.bold
                          : FontWeight.normal)),
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _buildPaymentRow(context, _payments[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(BuildContext context, _Payment p) {
    final statusColor = _statusColor(p.status);
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayRepayNow.toPath),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      color: Colors.white54, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      Text(p.store,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 11)),
                    ],
                  ),
                ),
                Text(p.amount,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(p.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                if (p.autoPay)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF00C853).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Auto-pay',
                        style: TextStyle(
                            color: Color(0xFF00C853),
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                  ),
                const Spacer(),
                Text('View Details',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11)),
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
  final bool autoPay, enabled;
  const _Payment(this.name, this.store, this.amount, this.installment,
      this.status, this.autoPay, this.enabled);
}
