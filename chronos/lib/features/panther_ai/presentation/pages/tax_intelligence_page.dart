import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

final NumberFormat _moneyFormatWhole = NumberFormat('#,##0');
String _moneyWhole(double value) => '\$${_moneyFormatWhole.format(value)}';

class TaxIntelligencePage extends StatefulWidget {
  const TaxIntelligencePage({super.key});

  @override
  State<TaxIntelligencePage> createState() => _TaxIntelligencePageState();
}

class _TaxIntelligencePageState extends State<TaxIntelligencePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  static const _bg = Color(0xFFF5F6FA);
  static const _amber = Color(0xFFF59E0B);
  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFEF4444);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _textSubtle = Color(0xFF9CA3AF);
  static const _border = Color(0xFFE8EAF0);

  static const _breakdown = [
    _TaxItem('Federal Income', 2840, Color(0xFFEF4444)),
    _TaxItem('State Income', 680, Color(0xFFF59E0B)),
    _TaxItem('FICA / Social Security', 520, Color(0xFF6366F1)),
    _TaxItem('Medicare', 160, Color(0xFF14B8A6)),
  ];

  static const _deductions = [
    _Deduction('401(k) Contributions', '\$4,200', Color(0xFF22C55E)),
    _Deduction('Health Insurance (pre-tax)', '\$1,800', Color(0xFF22C55E)),
    _Deduction('Home Office Deduction', '\$960', Color(0xFF22C55E)),
    _Deduction('Student Loan Interest', '\$350', Color(0xFF6366F1)),
  ];

  double get _total => _breakdown.fold(0, (s, e) => s + e.amount);

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
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3F4F6),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF374151), size: 16),
          ),
        ),
        title: const Text('Tax Intelligence',
            style: TextStyle(
                color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded, color: _amber, size: 11),
                const SizedBox(width: 5),
                Text('Tax Year 2025',
                    style: TextStyle(
                        color: _amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildPieChart(),
                  const SizedBox(height: 24),
                  _buildBreakdownSection(),
                  const SizedBox(height: 24),
                  _buildDeductionsSection(),
                  const SizedBox(height: 24),
                  _buildChrisInsight(),
                  const SizedBox(height: 24),
                  _buildQuarterlyTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _amber.withValues(alpha: 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _amber.withValues(alpha: 0.3), width: 1),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _amber.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: _amber, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Tax Owed',
                      style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12)),
                  SizedBox(height: 2),
                  Text('\$4,200',
                      style: TextStyle(
                          color: _textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Effective Rate',
                      style: TextStyle(
                          color: _textSubtle,
                          fontSize: 11)),
                  SizedBox(height: 2),
                  Text('18.4%',
                      style: TextStyle(
                          color: _textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _statPill('Due Date', 'Apr 15, 2026', _amber),
              const SizedBox(width: 10),
              _statPill('Paid So Far', '\$3,100', _green),
              const SizedBox(width: 10),
              _statPill('Remaining', '\$1,100', _red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
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
                style: const TextStyle(
                    color: _textSubtle, fontSize: 10)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
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
          const Text('Tax Breakdown',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      items: _breakdown,
                      total: _total,
                      progress: _anim.value,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _breakdown
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: e.color)),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.name,
                                        style: const TextStyle(
                                            color: _textSecondary,
                                            fontSize: 11)),
                                    Text(
                                        _moneyWhole(e.amount),
                                        style: const TextStyle(
                                            color: _textPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category Breakdown',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._breakdown.map((e) {
          final pct = e.amount / _total;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 0.8),
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
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: e.color)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.name,
                          style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text(_moneyWhole(e.amount),
                        style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct * _anim.value,
                    backgroundColor: _border,
                    valueColor: AlwaysStoppedAnimation(e.color),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${(pct * 100).toStringAsFixed(1)}% of total',
                    style: const TextStyle(
                        color: _textSubtle,
                        fontSize: 10)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDeductionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Deductions Found',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Saves \$1,380',
                  style: TextStyle(
                      color: _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _deductions
                .map((d) => _DeductionTile(deduction: d))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChrisInsight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _amber.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _amber.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _amber, size: 16),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chris suggests',
                    style: TextStyle(
                        color: _amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 5),
                Text(
                  'Maximizing your 401(k) contribution to \$23,500 this year could reduce your federal tax bill by up to \$2,820. You\'re currently \$4,200 below the limit.',
                  style: TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterlyTimeline() {
    final quarters = [
      ('Q1 2025', 'Paid', '\$775', true),
      ('Q2 2025', 'Paid', '\$775', true),
      ('Q3 2025', 'Paid', '\$775', true),
      ('Q4 2025', 'Due Jan 15', '\$775', false),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quarterly Estimates',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...quarters.map((q) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: q.$4
                          ? _green.withValues(alpha: 0.10)
                          : _amber.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                        q.$4
                            ? Icons.check_rounded
                            : Icons.schedule_rounded,
                        color: q.$4 ? _green : _amber,
                        size: 14),
                  ),
                  const SizedBox(width: 12),
                  Text(q.$1,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(q.$3,
                          style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      Text(q.$2,
                          style: TextStyle(
                              color: q.$4 ? _green : _amber,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<_TaxItem> items;
  final double total;
  final double progress;
  const _PieChartPainter(
      {required this.items, required this.total, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    double startAngle = -pi / 2;

    for (final item in items) {
      final sweep = (item.amount / total) * 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        Paint()..color = item.color,
      );
      startAngle += sweep;
    }

    canvas.drawCircle(center, radius * 0.55,
        Paint()..color = Colors.white);

    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${_moneyWhole(total)}\n',
            style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          const TextSpan(
            text: 'total',
            style: TextStyle(
                color: Color(0xFF6B7080), fontSize: 10),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas,
        center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => old.progress != progress;
}

class _DeductionTile extends StatelessWidget {
  final _Deduction deduction;
  const _DeductionTile({required this.deduction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Color(0xFFE8EAF0), width: 0.8)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: deduction.color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(deduction.name,
                style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13)),
          ),
          Text(deduction.amount,
              style: TextStyle(
                  color: deduction.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TaxItem {
  final String name;
  final double amount;
  final Color color;
  const _TaxItem(this.name, this.amount, this.color);
}

class _Deduction {
  final String name;
  final String amount;
  final Color color;
  const _Deduction(this.name, this.amount, this.color);
}
