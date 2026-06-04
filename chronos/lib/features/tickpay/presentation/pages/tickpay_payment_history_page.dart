import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TickPayPaymentHistoryPage extends StatefulWidget {
  const TickPayPaymentHistoryPage({super.key});

  @override
  State<TickPayPaymentHistoryPage> createState() =>
      _TickPayPaymentHistoryPageState();
}

class _TickPayPaymentHistoryPageState
    extends State<TickPayPaymentHistoryPage> {
  int _filterIndex = 0;
  static const _filters = ['All', 'Paid', 'Late', 'Refunded'];

  static const _transactions = [
    _Tx('iPhone 15 Pro', 'Apple Store', '-\$249.75', 'May 15, 2026',
        'Paid', '4/4', 'Bank ****4892'),
    _Tx('Sony WH-1000XM5', 'Best Buy', '-\$87.25', 'May 6, 2026',
        'Paid', '1/4', 'Card ****7823'),
    _Tx('Air Max Plus', 'Nike', '-\$45.00', 'May 6, 2026', 'Paid', '2/4',
        'Bank ****4892'),
    _Tx('MacBook Air M3', 'Apple Store', '-\$274.75', 'May 1, 2026',
        'Paid', '1/4', 'Bank ****4892'),
    _Tx('55" 4K TV', 'Samsung', '-\$149.75', 'Apr 28, 2026', 'Paid Late',
        '3/4', 'Card ****7823'),
    _Tx('AirPods Pro', 'Apple', '-\$62.25', 'Apr 22, 2026', 'Paid', '4/4',
        'Bank ****4892'),
    _Tx('EOS R5 Camera', 'Canon', '+\$974.75', 'Apr 15, 2026', 'Refunded',
        '1/4', 'Bank ****4892'),
    _Tx('Air Max Plus', 'Nike', '-\$45.00', 'Apr 10, 2026', 'Paid', '1/4',
        'Card ****7823'),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF00C853);
      case 'Paid Late':
        return const Color(0xFFDC8F4A);
      case 'Refunded':
        return const Color(0xFF3B82F6);
      default:
        return Colors.white54;
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
                _buildStats(),
                _buildFilters(),
                Expanded(child: _buildList()),
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
              const Text('Payment History',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Your transaction records',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
              child: _statCard('Total Paid', '\$764', Colors.white)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('On Time', '95%', const Color(0xFF00C853))),
          const SizedBox(width: 10),
          Expanded(
              child: _statCard('Total', '${_transactions.length}',
                  Colors.white)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
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
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(e.value,
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _buildTxCard(_transactions[i]),
    );
  }

  Widget _buildTxCard(_Tx tx) {
    final isPositive = tx.amount.startsWith('+');
    final statusColor = _statusColor(tx.status);
    return Container(
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.undo : Icons.arrow_upward,
                  color: isPositive
                      ? const Color(0xFF3B82F6)
                      : Colors.white54,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    Text(tx.store,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11)),
                  ],
                ),
              ),
              Text(tx.amount,
                  style: TextStyle(
                      color: isPositive
                          ? const Color(0xFF3B82F6)
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tx.status == 'Refunded'
                          ? Icons.undo
                          : tx.status == 'Paid Late'
                              ? Icons.warning_amber
                              : Icons.check_circle,
                      color: statusColor,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(tx.status,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(tx.installment,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
              const Spacer(),
              Text(tx.date,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 46),
              Text(tx.method,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tx {
  final String name, store, amount, date, status, installment, method;
  const _Tx(this.name, this.store, this.amount, this.date, this.status,
      this.installment, this.method);
}
