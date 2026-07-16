import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/tickpay_colors.dart';

class TickPayPaymentHistoryPage extends StatefulWidget {
  const TickPayPaymentHistoryPage({super.key});

  @override
  State<TickPayPaymentHistoryPage> createState() => _TickPayPaymentHistoryPageState();
}

class _TickPayPaymentHistoryPageState extends State<TickPayPaymentHistoryPage> {
  int _filterIndex = 0;
  static const _filters = ['All', 'Paid', 'Late', 'Refunded'];

  static const _transactions = [
    _Tx('iPhone 15 Pro', 'Apple Store', '-\$249.75', 'May 15, 2026', 'Paid', '4/4', 'Bank ****4892'),
    _Tx('Sony WH-1000XM5', 'Best Buy', '-\$87.25', 'May 6, 2026', 'Paid', '1/4', 'Card ****7823'),
    _Tx('Air Max Plus', 'Nike', '-\$45.00', 'May 6, 2026', 'Paid', '2/4', 'Bank ****4892'),
    _Tx('MacBook Air M3', 'Apple Store', '-\$274.75', 'May 1, 2026', 'Paid', '1/4', 'Bank ****4892'),
    _Tx('55" 4K TV', 'Samsung', '-\$149.75', 'Apr 28, 2026', 'Paid Late', '3/4', 'Card ****7823'),
    _Tx('AirPods Pro', 'Apple', '-\$62.25', 'Apr 22, 2026', 'Paid', '4/4', 'Bank ****4892'),
    _Tx('EOS R5 Camera', 'Canon', '+\$974.75', 'Apr 15, 2026', 'Refunded', '1/4', 'Bank ****4892'),
    _Tx('Air Max Plus', 'Nike', '-\$45.00', 'Apr 10, 2026', 'Paid', '1/4', 'Card ****7823'),
  ];

  Color _statusColor(String s) {
    switch (s) {
      case 'Paid':      return TickpayColors.positive;
      case 'Paid Late': return TickpayColors.warning;
      case 'Refunded':  return TickpayColors.info;
      default:          return TickpayColors.textMutedLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TickpayColors.scaffoldLight,
      body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
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
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8)],
              ),
              child: const Icon(Icons.arrow_back, color: TickpayColors.textPrimaryLight, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment History',
                  style: TextStyle(color: TickpayColors.textPrimaryLight, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Your transaction records',
                  style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(child: _statCard('Total Paid', '\$764', TickpayColors.accentPurple)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('On Time', '95%', TickpayColors.positive)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('Total', '${_transactions.length}', TickpayColors.textPrimaryLight)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 11)),
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
                color: isSelected ? TickpayColors.accentPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [] :
                    [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
              ),
              child: Text(e.value,
                  style: TextStyle(
                    color: isSelected ? Colors.white : TickpayColors.textMutedLight,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
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
    final sc = _statusColor(tx.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isPositive
                  ? TickpayColors.info.withValues(alpha: 0.1)
                  : TickpayColors.neutralSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.undo : Icons.arrow_upward,
              color: isPositive ? TickpayColors.info : TickpayColors.textMutedLight,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.name,
                    style: const TextStyle(color: TickpayColors.textPrimaryLight, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(tx.store, style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: sc.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(tx.status,
                          style: TextStyle(color: sc, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Text(tx.installment,
                        style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(tx.amount,
                  style: TextStyle(
                    color: isPositive ? TickpayColors.info : TickpayColors.textPrimaryLight,
                    fontSize: 14, fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 4),
              Text(tx.date, style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tx {
  final String name, store, amount, date, status, installment, method;
  const _Tx(this.name, this.store, this.amount, this.date, this.status, this.installment, this.method);
}
