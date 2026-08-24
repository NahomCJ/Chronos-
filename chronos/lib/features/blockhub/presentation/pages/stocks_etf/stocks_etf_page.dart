import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StocksEtfPage extends StatefulWidget {
  const StocksEtfPage({super.key});

  @override
  State<StocksEtfPage> createState() => _StocksEtfPageState();
}

class _StocksEtfPageState extends State<StocksEtfPage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHero(context),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStocksList(),
                _buildEtfList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl:
                'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF0D1B2A)),
            errorWidget: (_, __, ___) =>
                Container(color: const Color(0xFF0D1B2A)),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 40,
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFFF5F7FA)],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Stocks & ETFs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _statChip('\$8,240', 'Portfolio'),
                    const SizedBox(width: 10),
                    _statChip('+\$142 (1.76%)', 'Today',
                        positive: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statChip(String value, String label, {bool positive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (positive)
            const Icon(Icons.arrow_upward_rounded,
                color: Color(0xFF4ADE80), size: 11),
          if (positive) const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              color: positive ? const Color(0xFF4ADE80) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          _tab('Stocks', 0),
          const SizedBox(width: 20),
          _tab('ETFs', 1),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF12122A)
                  : const Color(0xFF888899),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isActive ? 28 : 0,
            decoration: BoxDecoration(
              color: const Color(0xFF12122A),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStocksList() {
    const stocks = [
      _Asset('AAPL', 'Apple', '\$189.30', '+0.84%', true, 0xFF1C1C1E),
      _Asset('MSFT', 'Microsoft', '\$415.60', '+1.23%', true, 0xFF00A4EF),
      _Asset('GOOGL', 'Alphabet', '\$175.20', '-0.32%', false, 0xFF4285F4),
      _Asset('AMZN', 'Amazon', '\$201.40', '+2.01%', true, 0xFFFF9900),
      _Asset('TSLA', 'Tesla', '\$248.10', '-1.45%', false, 0xFFCC0000),
      _Asset('NVDA', 'NVIDIA', '\$875.40', '+3.22%', true, 0xFF76B900),
      _Asset('META', 'Meta', '\$520.80', '+0.67%', true, 0xFF0866FF),
      _Asset('BRK', 'Berkshire', '\$384.20', '+0.12%', true, 0xFF1A1A2E),
    ];
    return _assetList(stocks);
  }

  Widget _buildEtfList() {
    const etfs = [
      _Asset('SPY', 'S&P 500 ETF', '\$528.40', '+0.91%', true, 0xFF0052FF),
      _Asset('QQQ', 'Nasdaq 100', '\$464.30', '+1.14%', true, 0xFF6366F1),
      _Asset('VTI', 'Total Market', '\$248.70', '+0.78%', true, 0xFF059669),
      _Asset('ARKK', 'ARK Innovation', '\$52.10', '-0.55%', false, 0xFFEC4899),
      _Asset('GLD', 'Gold ETF', '\$218.90', '+0.33%', true, 0xFFF59E0B),
      _Asset('TLT', 'Bond 20Y ETF', '\$96.40', '-0.21%', false, 0xFF64748B),
      _Asset('VWO', 'Emerging Mkts', '\$44.80', '+0.48%', true, 0xFF0EA5E9),
    ];
    return _assetList(etfs);
  }

  Widget _assetList(List<_Asset> assets) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: assets.length,
      itemBuilder: (context, i) => _assetRow(assets[i]),
    );
  }

  Widget _assetRow(_Asset asset) {
    return GestureDetector(
      onTap: () => _showAssetSheet(asset),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Color(asset.colorHex).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  asset.ticker.length > 3
                      ? asset.ticker.substring(0, 3)
                      : asset.ticker,
                  style: TextStyle(
                    color: Color(asset.colorHex),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset.ticker,
                      style: const TextStyle(
                          color: Color(0xFF12122A),
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(asset.name,
                      style: const TextStyle(
                          color: Color(0xFF888899), fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(asset.price,
                    style: const TextStyle(
                        color: Color(0xFF12122A),
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 3),
                _MiniSparkline(isPositive: asset.isPositive),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: asset.isPositive
                        ? const Color(0xFF22C55E).withValues(alpha: 0.10)
                        : const Color(0xFFEF4444).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    asset.change,
                    style: TextStyle(
                      color: asset.isPositive
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssetSheet(_Asset asset) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: const Color(0xFF0D0D1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AssetDetailSheet(asset: asset),
    );
  }
}

class _AssetDetailSheet extends StatelessWidget {
  final _Asset asset;
  const _AssetDetailSheet({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(asset.colorHex).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    asset.ticker.length > 3
                        ? asset.ticker.substring(0, 3)
                        : asset.ticker,
                    style: TextStyle(
                      color: Color(asset.colorHex),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                    Text(asset.ticker,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(asset.price,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(
                    asset.change,
                    style: TextStyle(
                      color: asset.isPositive
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          _MiniChart(isPositive: asset.isPositive),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _sheetButton('Buy', true, () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(child: _sheetButton('Sell', false, () => Navigator.pop(context))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sheetButton(String label, bool primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: primary ? Colors.white : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: primary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: primary ? const Color(0xFF0D0D1A) : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  final bool isPositive;
  const _MiniSparkline({required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 16,
      child: CustomPaint(painter: _SparklinePainter(isPositive: isPositive)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final bool isPositive;
  const _SparklinePainter({required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final rng = math.Random(isPositive ? 42 : 13);
    final points = List.generate(8, (i) {
      final x = size.width * i / 7;
      final base = isPositive ? (1 - i / 7) : (i / 7);
      final y = size.height * (0.2 + base * 0.6 + (rng.nextDouble() - 0.5) * 0.3);
      return Offset(x, y.clamp(0, size.height));
    });

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.isPositive != isPositive;
}

class _MiniChart extends StatelessWidget {
  final bool isPositive;
  const _MiniChart({required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _ChartPainter(isPositive: isPositive),
        child: Container(),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final bool isPositive;
  const _ChartPainter({required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final color = isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rng = math.Random(isPositive ? 7 : 3);
    final pts = List.generate(20, (i) {
      final x = size.width * i / 19;
      final trend = isPositive ? (1 - i / 19) * 0.6 : (i / 19) * 0.6;
      final y = size.height * (0.1 + trend + (rng.nextDouble() - 0.5) * 0.25);
      return Offset(x, y.clamp(4, size.height - 4));
    });

    final linePath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    final fillPath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      fillPath.lineTo(pts[i].dx, pts[i].dy);
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.lineTo(pts.first.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
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
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.isPositive != isPositive;
}

class _Asset {
  final String ticker;
  final String name;
  final String price;
  final String change;
  final bool isPositive;
  final int colorHex;

  const _Asset(
      this.ticker, this.name, this.price, this.change, this.isPositive, this.colorHex);
}
