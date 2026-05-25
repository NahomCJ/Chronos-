import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'blockhub_risk_analysis_page.dart';

class BlockHubPortfolioPage extends StatefulWidget {
  const BlockHubPortfolioPage({super.key});

  @override
  State<BlockHubPortfolioPage> createState() => _BlockHubPortfolioPageState();
}

class _BlockHubPortfolioPageState extends State<BlockHubPortfolioPage> {
  String _period = '1W';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildTotalValueCard(),
                        const SizedBox(height: 16),
                        _buildPerformanceCard(),
                        const SizedBox(height: 16),
                        _buildAssetAllocation(),
                        const SizedBox(height: 16),
                        _buildYourHoldings(),
                        const SizedBox(height: 16),
                        _buildPantherRiskCard(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Text(
            'Portfolio',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.download_outlined,
                color: Colors.white.withValues(alpha: 0.7),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalValueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B0764), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Value',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$48,750.25',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Color(0xFF22C55E),
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+2.45%',
                      style: TextStyles.bodySmall.copyWith(
                        color: const Color(0xFF22C55E),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+\$1165.32 today',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _subCard('Crypto', '\$35,420.5', '72.7%')),
              const SizedBox(width: 10),
              Expanded(child: _subCard('AMC Assets', '\$13,329.75', '27.3%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subCard(String label, String value, String pct) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            pct,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Row(
                children:
                    ['1D', '1W', '1M', '1Y'].map((p) {
                      final sel = _period == p;
                      return GestureDetector(
                        onTap: () => setState(() => _period = p),
                        child: Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                sel
                                    ? const Color(0xFF7C3AED)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p,
                            style: TextStyles.bodySmall.copyWith(
                              color:
                                  sel
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _PortfolioChartPainter(),
              size: const Size(double.infinity, 100),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                ['Jan 20', 'Jan 22', 'Jan 24', 'Jan 26', 'Jan 29']
                    .map(
                      (l) => Text(
                        l,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 9,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetAllocation() {
    final assets = [
      _Asset('BTC', '32.9%', const Color(0xFFF7931A)),
      _Asset('ETH', '24.6%', const Color(0xFF627EEA)),
      _Asset('SOL', '14.3%', const Color(0xFF9945FF)),
      _Asset('tAAPL', '18.3%', const Color(0xFF22C55E)),
      _Asset('tTSLA', '6.0%', const Color(0xFFEF4444)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                color: Color(0xFFDC8F4A),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Asset Allocation',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(painter: _DonutChartPainter(assets)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children:
                      assets
                          .map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: a.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      a.symbol,
                                      style: TextStyles.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    a.pct,
                                    style: TextStyles.bodySmall.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0B100).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF0B100).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF0B100),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '42% of your portfolio is concentrated in 2 assets',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourHoldings() {
    final holdings = [
      _Holding(
        'BTC',
        '0.21 BTC',
        'Avg: \$43,670',
        '\$16,062.5',
        '+\$1562.5 (+10.78%)',
        true,
      ),
      _Holding(
        'ETH',
        '3.5 ETH',
        'Avg: \$3,200',
        '\$11,971.75',
        '+\$771.75 (+6.89%)',
        true,
      ),
      _Holding(
        'SOL',
        '48 SOL',
        'Avg: \$140',
        '\$6,974.4',
        '+\$254.4 (+3.78%)',
        true,
      ),
      _Holding(
        'tAAPL',
        '63 tAAPL',
        'Avg: \$175',
        '\$8,922.5',
        '+\$172.5 (+1.97%)',
        true,
      ),
      _Holding(
        'tTSLA',
        '1 tTSLA',
        'Avg: \$250',
        '\$4,371.12',
        '-\$128.88 (-2.86%)',
        false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFFDC8F4A), size: 16),
              const SizedBox(width: 6),
              Text(
                'Your Holdings',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Profit/Loss',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+\$3,080.25',
                    style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF22C55E),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '+6.74%',
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF22C55E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'Invested: \$45,670',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          ...holdings.asMap().entries.map((e) {
            final isLast = e.key == holdings.length - 1;
            return Column(
              children: [
                _holdingRow(e.value),
                if (!isLast)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.06),
                    height: 1,
                    thickness: 0.5,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _holdingRow(_Holding h) {
    final color =
        h.isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h.symbol,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  h.amount,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
                Text(
                  h.avg,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                h.value,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                h.change,
                style: TextStyles.bodySmall.copyWith(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPantherRiskCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFDC8F4A),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Panther Risk Analysis',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Risk Score',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '68/',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '100',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 0.68,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFDC8F4A),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Balanced',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your portfolio shows moderate concentration risk. Consider diversifying across more assets to reduce volatility exposure.',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BlockHubRiskAnalysisPage(),
                    ),
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
              child: Text(
                'View Detailed Analysis',
                style: TextStyles.labelMedium.copyWith(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Insights are informational, not financial advice.',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Asset {
  final String symbol, pct;
  final Color color;
  const _Asset(this.symbol, this.pct, this.color);
}

class _Holding {
  final String symbol, amount, avg, value, change;
  final bool isPositive;
  const _Holding(
    this.symbol,
    this.amount,
    this.avg,
    this.value,
    this.change,
    this.isPositive,
  );
}

class _PortfolioChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.07)
          ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final paint =
        Paint()
          ..color = const Color(0xFF7C3AED)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final fill =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF7C3AED).withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;
    final pts = [0.7, 0.6, 0.65, 0.5, 0.55, 0.4, 0.45, 0.35, 0.3];
    final xStep = size.width / (pts.length - 1);
    final path = Path(), fillPath = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = i * xStep;
      final y = size.height * pts[i];
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        final px = (i - 1) * xStep;
        final py = size.height * pts[i - 1];
        path.cubicTo((px + x) / 2, py, (px + x) / 2, y, x, y);
        fillPath.cubicTo((px + x) / 2, py, (px + x) / 2, y, x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _DonutChartPainter extends CustomPainter {
  final List<_Asset> assets;
  _DonutChartPainter(this.assets);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16;
    final pcts = [0.329, 0.246, 0.143, 0.183, 0.060];
    double startAngle = -1.5708;
    for (int i = 0; i < assets.length; i++) {
      paint.color = assets[i].color;
      final sweep = pcts[i] * 6.2832;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep - 0.05,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
