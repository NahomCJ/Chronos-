import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';

class NftPriceHistoryPage extends StatefulWidget {
  const NftPriceHistoryPage({super.key});

  @override
  State<NftPriceHistoryPage> createState() => _NftPriceHistoryPageState();
}

class _NftPriceHistoryPageState extends State<NftPriceHistoryPage> {
  String _selectedPeriod = '1Y';
  final _periods = ['7D', '1M', '3M', '1Y', 'ALL'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
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
                        _buildStatsCard(),
                        const SizedBox(height: 16),
                        _buildChartCard(),
                        const SizedBox(height: 16),
                        _buildMarketAnalytics(),
                        const SizedBox(height: 16),
                        _buildRecentSales(),
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
          Column(
            children: [
              Text(
                'Price History',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                'Holographic #9012',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Expanded(child: _statCol('Current Price', '3.5 ETH', Colors.white)),
          _vertDivider(),
          Expanded(child: _statCol('Floor Price', '2.5 ETH', Colors.white)),
          _vertDivider(),
          Expanded(child: _statCol('Change', '+15%', const Color(0xFF22C55E))),
        ],
      ),
    );
  }

  Widget _statCol(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyles.titleMedium.copyWith(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _vertDivider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFFDC8F4A), size: 18),
              const SizedBox(width: 6),
              Text(
                'Floor Price Trend',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ..._periods.map(
                (p) => GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = p),
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _selectedPeriod == p
                              ? Colors.white
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      p,
                      style: TextStyles.bodySmall.copyWith(
                        color:
                            _selectedPeriod == p
                                ? Colors.black
                                : Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight:
                            _selectedPeriod == p
                                ? FontWeight.w700
                                : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _PriceChartPainter(),
              size: const Size(double.infinity, 140),
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                [
                      '2024-02',
                      '2024-04',
                      '2024-06',
                      '2024-08',
                      '2024-10',
                      '2025-01',
                    ]
                    .map(
                      (l) => Text(
                        l,
                        style: TextStyles.bodySmall.copyWith(
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

  Widget _buildMarketAnalytics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Analytics',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          _analyticsRow('Average Hold Time', '45 days', Colors.white, false),
          _divider(),
          _analyticsRow('Price Volatility', 'Medium', Colors.white, false),
          _divider(),
          _liquidityRow(),
        ],
      ),
    );
  }

  Widget _analyticsRow(
    String label,
    String value,
    Color valueColor,
    bool isLast,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _liquidityRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Liquidity Score',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF22C55E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '72/100',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    color: Colors.white.withValues(alpha: 0.07),
    height: 1,
    thickness: 0.5,
  );

  Widget _buildRecentSales() {
    final sales = [
      _Sale('2.8 ETH', '2025-01-25', '0x1234...5678', '0x9876...5432'),
      _Sale('2.5 ETH', '2024-11-10', '0xabcd...efgh', '0x1234...5678'),
      _Sale('2.2 ETH', '2024-08-15', '0x5555...6666', '0xabcd...efgh'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sales',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...sales.map(
          (s) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.07),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.amount,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      s.date,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'From ${s.from} to ${s.to}',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

class _PriceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Y-axis grid lines
    final gridPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Y-axis labels
    final labels = ['0', '0.8', '1.6', '2.4', '3.2'];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < labels.length; i++) {
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 9,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, size.height * (1 - i / 4) - 6));
    }

    // Price line (amber/orange)
    final linePaint =
        Paint()
          ..color = const Color(0xFFDC8F4A)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Normalized y values (0=bottom, 1=top) for the price line
    final points = [
      0.3,
      0.45,
      0.35,
      0.55,
      0.5,
      0.65,
      0.6,
      0.75,
      0.7,
      0.72,
      0.68,
      0.75,
    ];
    final xStep = size.width / (points.length - 1);
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = i * xStep;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * xStep;
        final prevY = size.height * (1 - points[i - 1]);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Sale {
  final String amount, date, from, to;
  const _Sale(this.amount, this.date, this.from, this.to);
}
