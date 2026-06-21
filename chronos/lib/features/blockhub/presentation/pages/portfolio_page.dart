import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/blockhub_entities.dart';
import '../bloc/portfolio/portfolio_bloc.dart';
import '../bloc/portfolio/portfolio_event.dart';
import '../bloc/portfolio/portfolio_state.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  String _selectedTimeframe = '1D';
  late final PortfolioBloc _portfolioBloc;

  @override
  void initState() {
    super.initState();
    _portfolioBloc = GetIt.I<PortfolioBloc>()
      ..add(PortfolioLoadRequested());
  }

  @override
  void dispose() {
    _portfolioBloc.close();
    super.dispose();
  }

  List<PortfolioAsset> _toDisplayAssets(List<CryptoHolding> holdings) {
    final total =
        holdings.fold<double>(0.0, (s, h) => s + h.totalValue);
    final colors = [
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
      const Color(0xFF9945FF),
      const Color(0xFF2775CA),
      const Color(0xFF6366F1),
    ];
    return holdings.asMap().entries.map((e) {
      final h = e.value;
      final pct = total > 0 ? (h.totalValue / total) * 100 : 0.0;
      return PortfolioAsset(
        name: h.asset,
        symbol: h.asset,
        amount: h.amount,
        value: h.totalValue,
        change: h.pnlPercent,
        isPositive: h.pnlPercent >= 0,
        color: colors[e.key % colors.length],
        percentage: pct,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return BlocProvider.value(
      value: _portfolioBloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.65))),
            SafeArea(
              child: BlocBuilder<PortfolioBloc, PortfolioState>(
                builder: (context, state) {
                  final holdings = state is PortfolioLoaded
                      ? _toDisplayAssets(state.holdings)
                      : <PortfolioAsset>[];
                  final totalValue = state is PortfolioLoaded
                      ? state.totalValue
                      : null;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, isSmallScreen),
                        const SizedBox(height: 24),
                        _buildTotalValueSection(isSmallScreen, totalValue),
                        const SizedBox(height: 20),
                        _buildPerformanceCards(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildPerformanceChart(isSmallScreen),
                        const SizedBox(height: 24),
                        _buildAssetAllocation(isSmallScreen, holdings),
                        const SizedBox(height: 24),
                        _buildYourHoldings(isSmallScreen, holdings),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Portfolio',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.download, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalValueSection(bool isSmallScreen, double? totalValue) {
    final displayValue = totalValue != null
        ? '\$${totalValue.toStringAsFixed(2)}'
        : '\$-';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Value',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayValue,
            style: TextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 32 : 36,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+\$2,841',
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+7.1% today',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCards(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gains',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$35,420.6',
                    style: TextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '72.7%',
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 10 : 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Losses',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$13,329.75',
                    style: TextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '27.3%',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 10 : 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                ),
                Row(
                  children:
                      ['1D', '1W', '1M', '1Y'].map((timeframe) {
                        final isSelected = _selectedTimeframe == timeframe;
                        return GestureDetector(
                          onTap:
                              () => setState(
                                () => _selectedTimeframe = timeframe,
                              ),
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              timeframe,
                              style: TextStyles.bodySmall.copyWith(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.6),
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                fontSize: isSmallScreen ? 10 : 11,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: CustomPaint(
                painter: PerformanceChartPainter(),
                size: const Size(double.infinity, 160),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetAllocation(bool isSmallScreen, List<PortfolioAsset> holdings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Asset Allocation',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(
                    painter: DonutChartPainter(assets: holdings),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children:
                        holdings.take(4).map((asset) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: asset.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  asset.symbol,
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: isSmallScreen ? 10 : 11,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${asset.percentage.toStringAsFixed(1)}%',
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isSmallScreen ? 10 : 11,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '42% of your portfolio is concentrated in 2 assets',
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYourHoldings(bool isSmallScreen, List<PortfolioAsset> holdings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Holdings',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'Total Portfolio',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '+\$3,080.25',
                    style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...holdings.map(
              (asset) => _buildHoldingItem(asset, isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingItem(PortfolioAsset asset, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: asset.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                asset.symbol.substring(0, 1),
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      asset.symbol,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                    if (asset.isAMC) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AMC',
                          style: TextStyles.bodySmall.copyWith(
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Avg ${asset.amount.toStringAsFixed(asset.amount < 1 ? 4 : 2)}',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isSmallScreen ? 10 : 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${asset.value.toStringAsFixed(asset.value > 1000 ? 0 : 2)}',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${asset.isPositive ? '+' : ''}${asset.change.toStringAsFixed(1)}%',
                style: TextStyles.bodySmall.copyWith(
                  color:
                      asset.isPositive ? const Color(0xFF10B981) : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 10 : 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class PortfolioAsset {
  final String name;
  final String symbol;
  final double amount;
  final double value;
  final double change;
  final bool isPositive;
  final Color color;
  final double percentage;
  final bool isAMC;

  PortfolioAsset({
    required this.name,
    required this.symbol,
    required this.amount,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.color,
    required this.percentage,
    this.isAMC = false,
  });
}

class PerformanceChartPainter extends CustomPainter {
  // Sample portfolio data points (value in $k)
  static const _data = [18.2, 19.5, 17.8, 20.1, 21.4, 19.9, 22.3, 23.1, 22.8, 24.5];
  static const _labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];

  @override
  void paint(Canvas canvas, Size size) {
    const teal = Color(0xFF10B981);
    const labelColor = Color(0x99FFFFFF);
    const topPad = 24.0;
    const bottomPad = 20.0;
    const sidePad = 8.0;
    final chartH = size.height - topPad - bottomPad;
    final chartW = size.width - sidePad * 2;

    final minV = _data.reduce((a, b) => a < b ? a : b) - 1;
    final maxV = _data.reduce((a, b) => a > b ? a : b) + 1;
    final range = maxV - minV;

    // Map data to pixel coordinates
    List<Offset> pts = [];
    for (int i = 0; i < _data.length; i++) {
      final x = sidePad + chartW * i / (_data.length - 1);
      final y = topPad + chartH * (1 - (_data[i] - minV) / range);
      pts.add(Offset(x, y));
    }

    // Gradient fill under the curve
    final fillPath = Path();
    fillPath.moveTo(pts.first.dx, size.height - bottomPad);
    fillPath.lineTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    fillPath.lineTo(pts.last.dx, size.height - bottomPad);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [teal.withValues(alpha: 0.30), teal.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, topPad, size.width, chartH)),
    );

    // Smooth line
    final linePath = Path();
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = teal
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Data point dots + value labels on every other point
    final dotPaint = Paint()..color = teal;
    final bgPaint = Paint()..color = const Color(0xFF0D0D1A);
    final labelStyle = const TextStyle(
      color: labelColor,
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );
    final monthStyle = const TextStyle(
      color: labelColor,
      fontSize: 8,
    );

    for (int i = 0; i < pts.length; i++) {
      // Dot
      canvas.drawCircle(pts[i], 3, bgPaint);
      canvas.drawCircle(pts[i], 2, dotPaint);

      // Value label above every other point
      if (i % 2 == 0) {
        final valTp = TextPainter(
          text: TextSpan(text: '\$${_data[i].toStringAsFixed(1)}k', style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        valTp.paint(canvas, Offset(pts[i].dx - valTp.width / 2, pts[i].dy - 16));
      }

      // Month label at bottom
      final mTp = TextPainter(
        text: TextSpan(text: _labels[i], style: monthStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      mTp.paint(canvas, Offset(pts[i].dx - mTp.width / 2, size.height - bottomPad + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  final List<PortfolioAsset> assets;

  DonutChartPainter({required this.assets});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    double startAngle = -1.57; // Start from top

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12;

    for (final asset in assets.take(4)) {
      final sweepAngle = (asset.percentage / 100) * 6.28; // 2π
      paint.color = asset.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
