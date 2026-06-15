import 'dart:math';
import 'package:flutter/material.dart';

class LiabilitiesIntelligencePage extends StatefulWidget {
  const LiabilitiesIntelligencePage({super.key});

  @override
  State<LiabilitiesIntelligencePage> createState() =>
      _LiabilitiesIntelligencePageState();
}

class _LiabilitiesIntelligencePageState
    extends State<LiabilitiesIntelligencePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _red = Color(0xFFEF4444);
  static const _green = Color(0xFF22C55E);
  static const _purple = Color(0xFF7C6EF0);

  static const _debts = [
    _Debt('Mortgage', 285000, 320000, 3.8, 'Jan 2048',
        Color(0xFF6366F1), Icons.home_rounded),
    _Debt('Car Loan', 12400, 22000, 5.9, 'Mar 2027',
        Color(0xFF8B5CF6), Icons.directions_car_rounded),
    _Debt('Student Loan', 18200, 35000, 4.5, 'Aug 2031',
        Color(0xFF3B82F6), Icons.school_rounded),
    _Debt('Credit Card', 3200, 3200, 22.4, 'Revolving',
        Color(0xFFEF4444), Icons.credit_card_rounded),
  ];

  double get _totalDebt => _debts.fold(0.0, (s, d) => s + d.balance);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFF3F4F6)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF374151), size: 16),
          ),
        ),
        title: const Text('Liabilities',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('4 accounts',
                style: TextStyle(
                    color: _red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              _buildDonutChart(),
              const SizedBox(height: 24),
              _buildDebtList(),
              const SizedBox(height: 24),
              _buildPaydownStrategy(),
              const SizedBox(height: 24),
              _buildChrisInsight(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _red.withValues(alpha: 0.06),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _red.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: _red.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red.withValues(alpha: 0.10)),
                child: const Icon(Icons.credit_card_off_rounded,
                    color: _red, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Liabilities',
                      style: TextStyle(color: _textSecondary, fontSize: 12)),
                  Text('\$${_fmtK(_totalDebt)}',
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Monthly\nPayments',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                          height: 1.3)),
                  const SizedBox(height: 2),
                  const Text('\$2,340',
                      style: TextStyle(
                          color: _textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('Paid off\nThis year', '\$8,400', _green),
              const SizedBox(width: 10),
              _stat('Avg Interest', '9.2%', const Color(0xFFF59E0B)),
              const SizedBox(width: 10),
              _stat('Debt-to-\nIncome', '28%', _red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: _textSecondary,
                    fontSize: 10,
                    height: 1.3)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Debt Composition',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _DonutPainter(
                        debts: _debts,
                        total: _totalDebt,
                        progress: _anim.value),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _debts.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: d.color)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.name,
                                style: TextStyle(
                                    color: _textSecondary, fontSize: 11)),
                            Text('\$${_fmtK(d.balance)}',
                                style: const TextStyle(
                                    color: _textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Debt Accounts',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._debts.map((d) {
          final progress = 1.0 - (d.balance / d.originalBalance);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 0.8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: d.color.withValues(alpha: 0.10)),
                      child: Icon(d.icon, color: d.color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name,
                              style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text('${d.rate}% APR · Due ${d.payoffDate}',
                              style: TextStyle(
                                  color: _textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${_fmtK(d.balance)}',
                            style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        Text('${(progress * 100).toStringAsFixed(0)}% paid',
                            style: const TextStyle(
                                color: _green, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress * _anim.value,
                    backgroundColor: const Color(0xFFE8EAF0),
                    valueColor: AlwaysStoppedAnimation(d.color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPaydownStrategy() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purple.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_down_rounded, color: _purple, size: 18),
              const SizedBox(width: 8),
              const Text('Paydown Strategy',
                  style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          _strategyRow('Avalanche', 'Pay high-interest first',
              'Saves \$3,240 in interest', _green),
          const SizedBox(height: 10),
          _strategyRow('Snowball', 'Pay smallest balance first',
              'Pays off 1 debt by Mar 2026', const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _strategyRow(String name, String desc, String benefit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(desc,
                    style: TextStyle(color: _textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text(benefit,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChrisInsight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _red.withValues(alpha: 0.10)),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _red, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chris suggests',
                    style: TextStyle(
                        color: _red,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(
                  'Your credit card at 22.4% is costing you \$60/month in interest. Paying \$500 extra monthly would clear it in 7 months and save \$420.',
                  style: TextStyle(
                      color: _textSecondary, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtK(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _DonutPainter extends CustomPainter {
  final List<_Debt> debts;
  final double total;
  final double progress;
  const _DonutPainter(
      {required this.debts, required this.total, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    double startAngle = -pi / 2;

    for (final d in debts) {
      final sweep = (d.balance / total) * 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = d.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}

class _Debt {
  final String name;
  final double balance;
  final double originalBalance;
  final double rate;
  final String payoffDate;
  final Color color;
  final IconData icon;
  const _Debt(this.name, this.balance, this.originalBalance, this.rate,
      this.payoffDate, this.color, this.icon);
}
