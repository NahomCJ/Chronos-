import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TickPayOrderHistoryPage extends StatefulWidget {
  const TickPayOrderHistoryPage({super.key});

  @override
  State<TickPayOrderHistoryPage> createState() =>
      _TickPayOrderHistoryPageState();
}

class _TickPayOrderHistoryPageState extends State<TickPayOrderHistoryPage> {
  int _filterIndex = 0;
  static const _filters = ['All', 'In Transit', 'Delivered', 'Processing'];

  static const _orders = [
    _Order('#ORD-2024-1547', 'May 3, 2026', 'iPhone 15 Pro', '\$999',
        '4/4 paid', 'Completed', null),
    _Order('#ORD-2024-1523', 'May 5, 2026', 'Apple Watch Ultra', '\$799',
        '2/4 paid', 'In Transit', 'Track Order'),
    _Order('#ORD-2024-1489', 'Apr 28, 2026', 'AirPods Pro + Nike Air Max',
        '\$429', '0/1', 'Delivered', null),
    _Order('#ORD-2024-1412', 'Apr 20, 2026', 'MacBook Air M3', '\$1,089',
        '1/1 paid', 'Cancelled', null),
    _Order('#ORD-2024-1389', 'Apr 10, 2026', 'iPad Pro 12.9"', '\$1,099',
        '0/4', 'Processing', null),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'In Transit': return const Color(0xFF3B82F6);
      case 'Delivered':  return const Color(0xFF00C853);
      case 'Cancelled':  return const Color(0xFFFF5252);
      case 'Processing': return const Color(0xFFDC8F4A);
      default:           return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1A0A2E),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildFilters(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _buildOrderCard(context, _orders[i]),
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
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order History',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('${_orders.length} orders',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.asMap().entries.map((e) {
            final isSelected = _filterIndex == e.key;
            return GestureDetector(
              onTap: () => setState(() => _filterIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF1A0A2E)
                            : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, _Order order) {
    final statusColor = _statusColor(order.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.id,
                  style: const TextStyle(
                      color: Color(0xFF999999), fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(order.status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(order.date,
              style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 11)),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: Color(0xFF999999), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.product,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                color: Color(0xFF999999), fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(order.total,
                            style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text('Payment  ${order.installments}',
                        style: const TextStyle(
                            color: Color(0xFFBBBBBB), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A0A2E),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Color(0xFFCCCCCC)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Receipt',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order.status == 'In Transit'
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF1A0A2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    order.actionLabel ?? 'Buy Again',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Order {
  final String id, date, product, total, installments, status;
  final String? actionLabel;
  const _Order(this.id, this.date, this.product, this.total, this.installments,
      this.status, this.actionLabel);
}
