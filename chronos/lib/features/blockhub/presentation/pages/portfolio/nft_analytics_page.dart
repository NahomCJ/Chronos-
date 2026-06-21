import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';

class NftAnalyticsPage extends StatelessWidget {
  const NftAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
          Positioned.fill(
            child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
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
                        _buildStatsGrid(),
                        const SizedBox(height: 16),
                        _buildChartCard(
                          'Portfolio Value Over Time',
                          const _LineChartWidget(color: Color(0xFF22C55E)),
                          xLabels: ['Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'],
                          yLabels: ['0', '2', '4', '6', '8'],
                        ),
                        const SizedBox(height: 16),
                        _buildChartCard(
                          'Performance by Collection',
                          const _BarChartWidget(),
                          xLabels: ['Chromatic', 'Holographic', 'Abstract'],
                        ),
                        const SizedBox(height: 16),
                        _buildIndividualPerformance(),
                        const SizedBox(height: 16),
                        _buildRiskAnalysis(),
                        const SizedBox(height: 16),
                        _buildHoldDuration(),
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
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Text(
            'Performance Analytics',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _statCard(Icons.trending_up, 'ROI', '+19.35%', const Color(0xFF22C55E)),
        _statCard(Icons.access_time_outlined, 'Avg Hold', '156d', Colors.white),
        _statCard(
          Icons.show_chart,
          'Volatility',
          'Medium',
          const Color(0xFFDC8F4A),
        ),
        _statCard(
          Icons.water_drop_outlined,
          'Liquidity',
          '78/100',
          Colors.white,
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFAB7FF8), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: TextStyles.bodyMedium.copyWith(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    String title,
    Widget chart, {
    List<String> xLabels = const [],
    List<String> yLabels = const [],
  }) {
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
          Text(
            title,
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(height: 120, child: chart),
          if (xLabels.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  xLabels
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
        ],
      ),
    );
  }

  Widget _buildIndividualPerformance() {
    final items = [
      _PerfItem(
        'Chromatic #1234',
        'Chromatic Dreams',
        '+40.9%',
        '+0.8 ETH',
        true,
      ),
      _PerfItem(
        'Holographic #9012',
        'Holographic Futures',
        '+25.0%',
        '+0.7 ETH',
        true,
      ),
      _PerfItem(
        'Abstract #3456',
        'Abstract Dimensions',
        '-8.3%',
        '-0.1 ETH',
        false,
      ),
    ];
    return _card(
      'Individual Performance',
      Column(
        children:
            items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              final c =
                  e.value.isPositive
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.value.name,
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                e.value.collection,
                                style: TextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              e.value.pct,
                              style: TextStyles.bodySmall.copyWith(
                                color: c,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              e.value.eth,
                              style: TextStyles.bodySmall.copyWith(
                                color: c,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      color: Colors.white.withValues(alpha: 0.06),
                      height: 1,
                      thickness: 0.5,
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildRiskAnalysis() {
    return _card(
      'Risk Analysis',
      Column(
        children: [
          _riskRow('Price Volatility', 0.6, 'Medium', const Color(0xFFDC8F4A)),
          const SizedBox(height: 12),
          _riskRow('Liquidity Risk', 0.25, 'Low', const Color(0xFF22C55E)),
          const SizedBox(height: 12),
          _riskRow(
            'Concentration Risk',
            0.55,
            'Medium',
            const Color(0xFFDC8F4A),
          ),
        ],
      ),
    );
  }

  Widget _riskRow(String label, double value, String valueLabel, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
            Text(
              valueLabel,
              style: TextStyles.bodySmall.copyWith(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildHoldDuration() {
    final rows = [
      ('< 30 days', '0 NFTs'),
      ('30-90 days', '0 NFTs'),
      ('90-180 days', '1 NFT'),
      ('> 180 days', '2 NFTs'),
    ];
    return _card(
      'Hold Duration Distribution',
      Column(
        children:
            rows.asMap().entries.map((e) {
              final isLast = e.key == rows.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.value.$1,
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          e.value.$2,
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      color: Colors.white.withValues(alpha: 0.06),
                      height: 1,
                      thickness: 0.5,
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _card(String title, Widget child) {
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
          Text(
            title,
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final Color color;
  const _LineChartWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(color),
      size: const Size(double.infinity, 120),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final Color color;
  _LineChartPainter(this.color);

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
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final pts = [0.65, 0.55, 0.6, 0.45, 0.4, 0.3];
    final xStep = size.width / (pts.length - 1);
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = i * xStep;
      final y = size.height * pts[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final px = (i - 1) * xStep;
        final py = size.height * pts[i - 1];
        path.cubicTo((px + x) / 2, py, (px + x) / 2, y, x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _BarChartWidget extends StatelessWidget {
  const _BarChartWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarChartPainter(),
      size: const Size(double.infinity, 120),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.07)
          ..strokeWidth = 0.5;
    for (int i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final barPaint =
        Paint()
          ..color = const Color(0xFF22C55E)
          ..style = PaintingStyle.fill;
    final heights = [0.8, 0.65, 0.3];
    final barW = size.width / 6;
    final spacing = size.width / 3;
    for (int i = 0; i < heights.length; i++) {
      final x = spacing * i + spacing / 2 - barW / 2;
      final h = size.height * heights[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barW, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _PerfItem {
  final String name, collection, pct, eth;
  final bool isPositive;
  const _PerfItem(
    this.name,
    this.collection,
    this.pct,
    this.eth,
    this.isPositive,
  );
}
