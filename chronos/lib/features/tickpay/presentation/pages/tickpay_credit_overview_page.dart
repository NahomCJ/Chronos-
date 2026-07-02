import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/tickpay_account_cubit.dart';
import '../bloc/tickpay_account_state.dart';

class TickPayCreditOverviewPage extends StatelessWidget {
  const TickPayCreditOverviewPage({super.key});

  static const _kDark = const Color(0xFF0D0D1A);
  static const _kLight = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TickpayAccountCubit, TickpayAccountState>(
      builder: (context, state) {
        final account = state is TickpayAccountLoaded ? state : null;
        return Scaffold(
          backgroundColor: _kLight,
          body: Stack(
              children: [
                Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
                Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
                Column(
            children: [
              Container(
                color: _kDark,
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
                      const SizedBox(height: 20),
                      _buildCreditHeader(account),
                      const SizedBox(height: 24),
                      _buildUtilizationCard(account),
                      const SizedBox(height: 24),
                      _buildRecentActivity(account),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
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
      },
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
          const Text(
            'Credit Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Manage your credit line',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditHeader(TickpayAccountLoaded? account) {
    final fmt = NumberFormat('#,##0.00');
    final available = account?.available ?? 0.0;
    final limit = account?.creditLimit ?? 0.0;
    final used = account?.creditUsed ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Available Credit',
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                account == null ? '---' : '\$${fmt.format(available)}',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  account == null
                      ? 'of --- limit'
                      : 'of \$${fmt.format(limit)} limit',
                  style: const TextStyle(
                      color: Color(0xFF999999), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'TickPay Credit Line',
            style: TextStyle(color: Color(0xFF999999), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Credit Used',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                Text(
                  account == null ? '---' : '\$${fmt.format(used)}',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilizationCard(TickpayAccountLoaded? account) {
    final fmt = NumberFormat('#,##0.00');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Credit Utilization',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _DonutPainter(
                    value: account == null
                        ? 0.0
                        : (account.creditLimit == 0
                            ? 0.0
                            : account.creditUsed / account.creditLimit)),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        account == null
                            ? '0%'
                            : '${(account.creditLimit == 0 ? 0 : (account.creditUsed / account.creditLimit * 100)).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Used',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildUtilRow(
              'Credit Used',
              account == null ? '\$0' : '\$${fmt.format(account.creditUsed)}',
              account == null || account.creditLimit == 0
                  ? 0.0
                  : math.min(account.creditUsed / account.creditLimit, 1.0),
              const Color(0xFF7C3AED)),
          const SizedBox(height: 10),
          _buildUtilRow(
              'Available',
              account == null ? '\$0' : '\$${fmt.format(account.available)}',
              account == null || account.creditLimit == 0
                  ? 1.0
                  : math.min(account.available / account.creditLimit, 1.0),
              const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  Widget _buildUtilRow(String label, String amount, double ratio, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(color: Color(0xFF555555), fontSize: 13)),
              ],
            ),
            Text(
              '$amount (${(ratio * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(TickpayAccountLoaded? account) {
    final fmt = NumberFormat('#,##0.00');
    final txs = account?.transactions.take(4).toList() ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'View All',
              style: TextStyle(color: Color(0xFF7C3AED), fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (txs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No transactions yet.',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
          )
        else
          ...txs.map((tx) => _buildActivityRow(
                tx.merchant ?? tx.type,
                '${tx.createdAt.month}/${tx.createdAt.day} · ${tx.type}',
                '\$${fmt.format(tx.amount)}',
                tx.isRepayment,
              )),
      ],
    );
  }

  Widget _buildActivityRow(
      String title, String subtitle, String amount, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isPositive
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFF1A1A1A), fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 12)),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: isPositive
                    ? const Color(0xFF00C853)
                    : const Color(0xFFFF5252),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D0D1A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text('Request Credit Increase',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D0D1A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFCCCCCC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Payment History',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double value;
  const _DonutPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = const Color(0xFFEEEEEE);
    canvas.drawCircle(center, radius, bg);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF7C3AED);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, fg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
