import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/wallet_entity.dart';

final NumberFormat _moneyFormat = NumberFormat('#,##0.00');
String _money(double value) => '\$${_moneyFormat.format(value)}';

class RecentTransactions extends StatefulWidget {
  final List<TransactionEntity> transactions;

  const RecentTransactions({super.key, this.transactions = const []});

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  String _selectedFilter = 'All';

  List<TransactionEntity> get _filtered {
    if (widget.transactions.isNotEmpty) {
      if (_selectedFilter == 'All') return widget.transactions;
      if (_selectedFilter == 'Incoming') {
        return widget.transactions.where((t) => t.isCredit).toList();
      }
      if (_selectedFilter == 'Outgoing') {
        return widget.transactions.where((t) => !t.isCredit).toList();
      }
      return widget.transactions;
    }
    return _fallback
        .where((t) =>
            _selectedFilter == 'All' || t['type'] == _selectedFilter)
        .map((t) => TransactionEntity(
              id: '',
              type: t['type'] as String,
              amount: double.parse((t['amount'] as String)
                  .replaceAll('\$', '')
                  .replaceAll(',', '')
                  .replaceAll('+', '')
                  .replaceAll('-', '')),
              currency: 'USD',
              status: t['status'] as String,
              createdAt: '',
            ))
        .toList();
  }

  final List<Map<String, dynamic>> _fallback = [
    {
      'icon': Icons.store,
      'title': 'Apple Store',
      'subtitle': 'Shopping • Jan 17',
      'amount': '-\$299.00',
      'status': 'Completed',
      'isNegative': true,
      'type': 'Outgoing',
    },
    {
      'icon': Icons.local_atm,
      'title': 'ATM Withdrawal',
      'subtitle': 'Cash Out • Jan 17',
      'amount': '-\$500.00',
      'status': 'Completed',
      'isNegative': true,
      'type': 'Outgoing',
    },
    {
      'icon': Icons.account_balance_wallet,
      'title': 'Salary Deposit',
      'subtitle': 'Income • Jan 16',
      'amount': '+\$3,200.00',
      'status': 'Completed',
      'isNegative': false,
      'type': 'Incoming',
    },
    {
      'icon': Icons.refresh,
      'title': 'Amazon Refund',
      'subtitle': 'Refund • Jan 15',
      'amount': '+\$45.00',
      'status': 'Completed',
      'isNegative': false,
      'type': 'Refunds',
    },
    {
      'icon': Icons.directions_car,
      'title': 'Uber',
      'subtitle': 'Transport • Jan 17',
      'amount': '-\$29.00',
      'status': 'Completed',
      'isNegative': true,
      'type': 'Outgoing',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final useLive = widget.transactions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions',
                style: TextStyles.titleMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () {},
              child: Text('See All',
                  style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFFB8860B),
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Incoming'),
              const SizedBox(width: 8),
              _buildFilterChip('Outgoing'),
              const SizedBox(width: 8),
              _buildFilterChip('Refunds'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (useLive)
          ..._filtered.take(10).map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildTransactionItem(
                  icon: _iconFor(tx.type),
                  title: tx.type,
                  subtitle: _formatDate(tx.createdAt),
                  amount:
                      '${tx.isCredit ? '+' : '-'}${_money(tx.amount.abs())}',
                  status: tx.status,
                  isNegative: !tx.isCredit,
                ),
              ))
        else
          ..._filteredFallback().map((data) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildTransactionItem(
                  icon: data['icon'] as IconData,
                  title: data['title'] as String,
                  subtitle: data['subtitle'] as String,
                  amount: data['amount'] as String,
                  status: data['status'] as String,
                  isNegative: data['isNegative'] as bool,
                ),
              )),
        if (_filtered.isEmpty && useLive)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No transactions found',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5))),
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _filteredFallback() {
    if (_selectedFilter == 'All') return _fallback;
    return _fallback
        .where((t) => t['type'] == _selectedFilter)
        .toList();
  }

  IconData _iconFor(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
        return Icons.account_balance_wallet;
      case 'TRANSFER':
        return Icons.swap_horiz;
      case 'PURCHASE':
        return Icons.store;
      case 'REFUND':
        return Icons.refresh;
      default:
        return Icons.receipt_long;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 111, 186, 171)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Text(label,
            style: TextStyles.bodySmall.copyWith(
                color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String status,
    required bool isNegative,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyles.bodyMedium.copyWith(
                      color: isNegative
                          ? Colors.white
                          : const Color(0xFF10B981),
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(status,
                  style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
