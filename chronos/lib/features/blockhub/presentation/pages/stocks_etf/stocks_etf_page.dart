import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../data/data_source/stocks_remote_data_source.dart';

class StocksEtfPage extends StatefulWidget {
  const StocksEtfPage({super.key});

  @override
  State<StocksEtfPage> createState() => _StocksEtfPageState();
}

class _StocksEtfPageState extends State<StocksEtfPage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late TabController _tabController;

  final _dataSource = GetIt.instance<StocksRemoteDataSource>();
  List<StockQuoteModel> _quotes = [];
  StockPortfolioModel? _portfolio;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _dataSource.getQuotes(),
        _dataSource.getPortfolio(),
      ]);
      if (!mounted) return;
      setState(() {
        _quotes = results[0] as List<StockQuoteModel>;
        _portfolio = results[1] as StockPortfolioModel;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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
      body: RefreshIndicator(
        onRefresh: _load,
        child: Column(
          children: [
            _buildHero(context),
            _buildTabBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _assetList(_quotes.where((q) => q.kind == 'STOCK').toList()),
                            _assetList(_quotes.where((q) => q.kind == 'ETF').toList()),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.wifi_off_rounded, color: Color(0xFF888899), size: 40),
        const SizedBox(height: 12),
        Text(
          'Couldn\'t load live prices.\n${_error ?? ''}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF888899), fontSize: 13),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(onPressed: _load, child: const Text('Retry')),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    final totalValue = _portfolio?.totalValueUsd ?? 0;
    final totalPnl = _portfolio?.totalPnl ?? 0;
    final totalPnlPct = _portfolio?.totalPnlPct ?? 0;
    final isPositive = totalPnl >= 0;

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
                    GestureDetector(
                      onTap: _loading ? null : _load,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 18),
                      ),
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
                    _statChip('\$${totalValue.toStringAsFixed(2)}', 'Portfolio'),
                    const SizedBox(width: 10),
                    _statChip(
                      '${isPositive ? '+' : ''}\$${totalPnl.toStringAsFixed(2)} (${totalPnlPct.toStringAsFixed(2)}%)',
                      'Total P&L',
                      positive: isPositive,
                    ),
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

  Widget _assetList(List<StockQuoteModel> assets) {
    if (assets.isEmpty) {
      return const Center(
        child: Text('No live prices available right now.',
            style: TextStyle(color: Color(0xFF888899), fontSize: 13)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: assets.length,
      itemBuilder: (context, i) => _assetRow(assets[i]),
    );
  }

  Widget _assetRow(StockQuoteModel asset) {
    final isPositive = (asset.changePct ?? 0) >= 0;
    final colorHex = _colorForSymbol(asset.symbol);
    StockHoldingModel? holding;
    for (final h in _portfolio?.holdings ?? const <StockHoldingModel>[]) {
      if (h.symbol == asset.symbol) {
        holding = h;
        break;
      }
    }

    return GestureDetector(
      onTap: () => _showAssetSheet(asset, holding),
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
                color: Color(colorHex).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  asset.symbol.length > 3
                      ? asset.symbol.substring(0, 3)
                      : asset.symbol,
                  style: TextStyle(
                    color: Color(colorHex),
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
                  Text(asset.symbol,
                      style: const TextStyle(
                          color: Color(0xFF12122A),
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(asset.name,
                      style: const TextStyle(
                          color: Color(0xFF888899), fontSize: 11)),
                  if (holding != null)
                    Text('${holding.shares.toStringAsFixed(2)} shares held',
                        style: const TextStyle(
                            color: Color(0xFF7C6EF0),
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  asset.price != null ? '\$${asset.price!.toStringAsFixed(2)}' : '—',
                  style: const TextStyle(
                      color: Color(0xFF12122A),
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                const SizedBox(height: 3),
                _MiniSparkline(isPositive: isPositive),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF22C55E).withValues(alpha: 0.10)
                        : const Color(0xFFEF4444).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${(asset.changePct ?? 0).toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive
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

  int _colorForSymbol(String symbol) {
    const palette = [
      0xFF1C1C1E,
      0xFF00A4EF,
      0xFF4285F4,
      0xFFFF9900,
      0xFFCC0000,
      0xFF76B900,
      0xFF0866FF,
      0xFF0052FF,
      0xFF6366F1,
      0xFF059669,
      0xFFEC4899,
      0xFFF59E0B,
    ];
    return palette[symbol.hashCode.abs() % palette.length];
  }

  void _showAssetSheet(StockQuoteModel asset, StockHoldingModel? holding) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D0D1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AssetDetailSheet(
        asset: asset,
        holding: holding,
        colorHex: _colorForSymbol(asset.symbol),
        dataSource: _dataSource,
        onOrderPlaced: _load,
      ),
    );
  }
}

class _AssetDetailSheet extends StatefulWidget {
  final StockQuoteModel asset;
  final StockHoldingModel? holding;
  final int colorHex;
  final StocksRemoteDataSource dataSource;
  final VoidCallback onOrderPlaced;

  const _AssetDetailSheet({
    required this.asset,
    required this.holding,
    required this.colorHex,
    required this.dataSource,
    required this.onOrderPlaced,
  });

  @override
  State<_AssetDetailSheet> createState() => _AssetDetailSheetState();
}

class _AssetDetailSheetState extends State<_AssetDetailSheet> {
  bool _submitting = false;
  String? _error;

  Future<void> _placeOrder(bool isBuy) async {
    final shares = await _promptShares(isBuy);
    if (shares == null || shares <= 0) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = isBuy
          ? await widget.dataSource.buy(widget.asset.symbol, shares)
          : await widget.dataSource.sell(widget.asset.symbol, shares);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      widget.onOrderPlaced();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${result.side == 'BUY' ? 'Bought' : 'Sold'} ${result.shares.toStringAsFixed(2)} '
            '${result.symbol} at \$${result.price.toStringAsFixed(2)} (\$${result.amountUsd.toStringAsFixed(2)} total)',
          ),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  Future<double?> _promptShares(bool isBuy) async {
    final controller = TextEditingController(text: '1');
    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF15152A),
        title: Text(
          '${isBuy ? 'Buy' : 'Sell'} ${widget.asset.symbol}',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Shares',
            labelStyle: TextStyle(color: Color(0xFF888899)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, double.tryParse(controller.text)),
            child: Text(isBuy ? 'Buy' : 'Sell'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final isPositive = (asset.changePct ?? 0) >= 0;

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
                  color: Color(widget.colorHex).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    asset.symbol.length > 3
                        ? asset.symbol.substring(0, 3)
                        : asset.symbol,
                    style: TextStyle(
                      color: Color(widget.colorHex),
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
                    Text(asset.symbol,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    asset.price != null ? '\$${asset.price!.toStringAsFixed(2)}' : '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}${(asset.changePct ?? 0).toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive
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
          if (widget.holding != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.holding!.shares.toStringAsFixed(2)} shares · avg \$${widget.holding!.avgPrice.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${widget.holding!.unrealizedPnl >= 0 ? '+' : ''}\$${widget.holding!.unrealizedPnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: widget.holding!.unrealizedPnl >= 0
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFF87171),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          _MiniChart(isPositive: isPositive),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: Color(0xFFF87171), fontSize: 12)),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _sheetButton('Buy', true,
                      _submitting ? null : () => _placeOrder(true))),
              const SizedBox(width: 12),
              Expanded(
                  child: _sheetButton('Sell', false,
                      _submitting ? null : () => _placeOrder(false))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sheetButton(String label, bool primary, VoidCallback? onTap) {
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
