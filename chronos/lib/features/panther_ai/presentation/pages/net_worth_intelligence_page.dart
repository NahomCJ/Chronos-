import 'package:flutter/material.dart';

class NetWorthIntelligencePage extends StatefulWidget {
  const NetWorthIntelligencePage({super.key});

  @override
  State<NetWorthIntelligencePage> createState() =>
      _NetWorthIntelligencePageState();
}

class _NetWorthIntelligencePageState extends State<NetWorthIntelligencePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);

  static const _assets = [
    _NWItem('Checking & Savings', 14200, Color(0xFF22C55E), Icons.account_balance_rounded),
    _NWItem('Investment Portfolio', 45890, Color(0xFF3B82F6), Icons.show_chart_rounded),
    _NWItem('Real Estate', 320000, Color(0xFF6366F1), Icons.home_rounded),
    _NWItem('Retirement (401k)', 38400, Color(0xFF14B8A6), Icons.savings_rounded),
    _NWItem('Crypto', 4200, Color(0xFFF59E0B), Icons.currency_bitcoin_rounded),
  ];

  static const _liabilities = [
    _NWItem('Mortgage', 285000, Color(0xFFEF4444), Icons.home_outlined),
    _NWItem('Car Loan', 12400, Color(0xFFEC4899), Icons.directions_car_outlined),
    _NWItem('Student Loan', 18200, Color(0xFF8B5CF6), Icons.school_outlined),
    _NWItem('Credit Card', 3200, Color(0xFFF59E0B), Icons.credit_card_outlined),
  ];

  static const _history = [
    ('Jan', 38200.0),
    ('Feb', 40100.0),
    ('Mar', 43800.0),
    ('Apr', 42200.0),
    ('May', 45600.0),
    ('Jun', 47200.0),
  ];

  double get _totalAssets => _assets.fold(0.0, (s, a) => s + a.value);
  double get _totalLiabilities => _liabilities.fold(0.0, (s, l) => s + l.value);
  double get _netWorth => _totalAssets - _totalLiabilities;

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
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3F4F6)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF374151), size: 16),
          ),
        ),
        title: const Text('Net Worth',
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
              color: _green.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up_rounded, color: _green, size: 13),
                const SizedBox(width: 4),
                const Text('+8.2% YTD',
                    style: TextStyle(
                        color: _green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.65))),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 24),
                  _buildLineChart(),
                  const SizedBox(height: 24),
                  _buildAssetLiabilityBars(),
                  const SizedBox(height: 24),
                  _buildAssetsList(),
                  const SizedBox(height: 24),
                  _buildLiabilitiesList(),
                  const SizedBox(height: 24),
                  _buildChrisInsight(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _green.withValues(alpha: 0.08),
            _blue.withValues(alpha: 0.04),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _green.withValues(alpha: 0.25), width: 1),
        color: _card,
        boxShadow: [
          BoxShadow(
              color: _green.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Net Worth',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          Text('\$${_fmtK(_netWorth)}',
              style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.arrow_upward_rounded, color: _green, size: 14),
              const SizedBox(width: 4),
              const Text('+\$3,600 since last month',
                  style: TextStyle(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _netStatCol('Total Assets', '\$${_fmtK(_totalAssets)}', _green),
              Container(width: 1, height: 40, color: _border),
              _netStatCol('Total Liabilities', '-\$${_fmtK(_totalLiabilities)}', _red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _netStatCol(String label, String value, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: _textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
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
          const Text('6-Month Trend',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _LineChartPainter(
                  data: _history, progress: _anim.value, color: _green),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _history
                .map((h) => Text(h.$1,
                    style: TextStyle(color: _textSecondary, fontSize: 10)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetLiabilityBars() {
    final max = _totalAssets;
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
          const Text('Assets vs Liabilities',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _barRow('Assets', _totalAssets, max, _green),
          const SizedBox(height: 10),
          _barRow('Liabilities', _totalLiabilities, max, _red),
          const SizedBox(height: 10),
          _barRow('Net Worth', _netWorth, max, _blue),
        ],
      ),
    );
  }

  Widget _barRow(String label, double value, double max, Color color) {
    return Row(
      children: [
        SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(color: _textSecondary, fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ((value / max) * _anim.value).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE8EAF0),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('\$${_fmtK(value)}',
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildAssetsList() => _buildNWSection('Assets', _assets, _green);
  Widget _buildLiabilitiesList() =>
      _buildNWSection('Liabilities', _liabilities, _red);

  Widget _buildNWSection(String title, List<_NWItem> items, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('\$${_fmtK(items.fold(0.0, (s, e) => s + e.value))}',
                style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border, width: 0.8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: items.map((e) {
              final isLast = e == items.last;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(color: _border, width: 0.8)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.color.withValues(alpha: 0.10)),
                      child: Icon(e.icon, color: e.color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(e.name,
                            style: const TextStyle(
                                color: _textPrimary, fontSize: 13))),
                    Text('\$${_fmtK(e.value)}',
                        style: TextStyle(
                            color: e.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChrisInsight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: 0.10)),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _green, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chris says',
                    style: TextStyle(
                        color: _green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(
                  "You're on track to hit \$100k net worth by Q3 2027 at your current savings rate. Increasing monthly savings by \$300 would get you there 8 months sooner.",
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
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _LineChartPainter extends CustomPainter {
  final List<(String, double)> data;
  final double progress;
  final Color color;
  const _LineChartPainter(
      {required this.data, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final min = data.map((e) => e.$2).reduce(mathMin);
    final max = data.map((e) => e.$2).reduce(mathMax);
    final range = max - min;

    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].$2 - min) / range) * size.height;
      points.add(Offset(x, y));
    }

    final animatedPoints = points
        .take((points.length * progress).ceil().clamp(1, points.length))
        .toList();

    final path = Path()..moveTo(animatedPoints.first.dx, size.height);
    for (final p in animatedPoints) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(animatedPoints.last.dx, size.height);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    if (animatedPoints.length > 1) {
      final linePath = Path()
        ..moveTo(animatedPoints.first.dx, animatedPoints.first.dy);
      for (final p in animatedPoints.skip(1)) {
        linePath.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        linePath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawCircle(animatedPoints.last, 5, Paint()..color = color);
    canvas.drawCircle(
        animatedPoints.last,
        5,
        Paint()
          ..color = const Color(0xFFF5F6FA)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  double mathMin(double a, double b) => a < b ? a : b;
  double mathMax(double a, double b) => a > b ? a : b;

  @override
  bool shouldRepaint(_LineChartPainter old) => old.progress != progress;
}

class _NWItem {
  final String name;
  final double value;
  final Color color;
  final IconData icon;
  const _NWItem(this.name, this.value, this.color, this.icon);
}
