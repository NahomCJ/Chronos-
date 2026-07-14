import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/net_worth.dart';
import '../bloc/net_worth_bloc.dart';
import '../bloc/net_worth_event.dart';
import '../bloc/net_worth_state.dart';

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
  late final NetWorthBloc _bloc;

  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);
  static const _amber = Color(0xFFF59E0B);
  static const _purple = Color(0xFF7C6EF0);

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<NetWorthBloc>();
    _bloc.add(const NetWorthLoadRequested());
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
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
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
            BlocBuilder<NetWorthBloc, NetWorthState>(
              builder: (context, state) {
                if (state is! NetWorthLoaded) return const SizedBox.shrink();
                final changePct = state.summary.changePct;
                final positive = changePct >= 0;
                final color = positive ? _green : _red;
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          positive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: color,
                          size: 13),
                      const SizedBox(width: 4),
                      Text(
                          '${positive ? '+' : ''}${changePct.toStringAsFixed(1)}% · 90d',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<NetWorthBloc, NetWorthState>(
          builder: (context, state) {
            if (state is NetWorthError) {
              return _buildErrorState(state.message);
            }
            if (state is! NetWorthLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: _purple),
              );
            }
            return AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(state.summary),
                    const SizedBox(height: 24),
                    _buildLineChart(state.summary.trend),
                    const SizedBox(height: 24),
                    _buildAssetLiabilityBars(state.summary),
                    const SizedBox(height: 24),
                    _buildAssetsList(state.summary),
                    const SizedBox(height: 24),
                    _buildLiabilitiesList(state.summary),
                    const SizedBox(height: 24),
                    _buildWhatIfCard(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: _red, size: 32),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: _textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _bloc.add(const NetWorthLoadRequested()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(NetWorthSummary summary) {
    final positive = summary.changeAmount >= 0;
    final changeColor = positive ? _green : _red;
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
          const Text('Net Worth',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          Text('\$${_fmtK(summary.netWorth)}',
              style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                  positive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: changeColor,
                  size: 14),
              const SizedBox(width: 4),
              Text(
                  '${positive ? '+' : '-'}\$${_fmtK(summary.changeAmount.abs())} over the last 90 days',
                  style: TextStyle(
                      color: changeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _netStatCol('Total Assets', '\$${_fmtK(summary.totalAssets)}',
                  _green),
              Container(width: 1, height: 40, color: _border),
              _netStatCol('Total Liabilities',
                  '-\$${_fmtK(summary.totalLiabilities)}', _red),
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

  Widget _buildLineChart(List<NetWorthTrendPoint> trend) {
    final points = _historyPoints(trend);
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
          const Text('90-Day Trend',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          if (points.length < 2)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Not enough history yet to chart a trend.',
                style: TextStyle(color: _textSecondary, fontSize: 12),
              ),
            )
          else ...[
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _LineChartPainter(
                    data: points, progress: _anim.value, color: _green),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: points
                  .map((h) => Text(h.$1,
                      style: TextStyle(color: _textSecondary, fontSize: 10)))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssetLiabilityBars(NetWorthSummary summary) {
    final max = summary.totalAssets <= 0 ? 1.0 : summary.totalAssets;
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
          _barRow('Assets', summary.totalAssets, max, _green),
          const SizedBox(height: 10),
          _barRow('Liabilities', summary.totalLiabilities, max, _red),
          const SizedBox(height: 10),
          _barRow('Net Worth', summary.netWorth, max, _blue),
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

  Widget _buildAssetsList(NetWorthSummary summary) =>
      _buildNWSection('Assets', _assetItems(summary), _green);
  Widget _buildLiabilitiesList(NetWorthSummary summary) =>
      _buildNWSection('Liabilities', _liabilityRows(summary), _red);

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

  List<_NWItem> _assetItems(NetWorthSummary summary) {
    final items = <_NWItem>[
      _NWItem('Bank & Savings', summary.bankBalances, _green,
          Icons.account_balance_rounded),
    ];
    if (summary.investmentHoldings.isNotEmpty) {
      items.addAll(summary.investmentHoldings.map((h) => _NWItem(
            h.tickerSymbol != null ? '${h.name} (${h.tickerSymbol})' : h.name,
            h.value,
            _blue,
            _iconForAssetClass(h.assetClass),
          )));
    } else {
      items.add(_NWItem(
          'Investments', summary.investments, _blue, Icons.show_chart_rounded));
    }
    items.add(_NWItem(
        'Crypto', summary.crypto, _amber, Icons.currency_bitcoin_rounded));
    items.add(_NWItem(
        'Other Savings', summary.otherSavings, _purple, Icons.savings_rounded));
    return items;
  }

  List<_NWItem> _liabilityRows(NetWorthSummary summary) {
    if (summary.liabilityItems.isEmpty) {
      return [
        _NWItem('No liabilities connected', 0, _textSecondary,
            Icons.info_outline_rounded),
      ];
    }
    return summary.liabilityItems
        .map((l) =>
            _NWItem(l.name, l.value, _red, _iconForLiabilityCategory(l.category)))
        .toList();
  }

  IconData _iconForAssetClass(String assetClass) {
    switch (assetClass) {
      case 'equities':
        return Icons.show_chart_rounded;
      case 'bonds':
        return Icons.account_balance_rounded;
      case 'retirement':
        return Icons.savings_rounded;
      case 'cash':
        return Icons.attach_money_rounded;
      case 'crypto':
        return Icons.currency_bitcoin_rounded;
      default:
        return Icons.pie_chart_rounded;
    }
  }

  IconData _iconForLiabilityCategory(String category) {
    switch (category) {
      case 'mortgage':
        return Icons.home_outlined;
      case 'auto_loan':
        return Icons.directions_car_outlined;
      case 'student_loan':
        return Icons.school_outlined;
      case 'personal_loan':
        return Icons.request_quote_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Widget _buildWhatIfCard(NetWorthLoaded state) {
    final projection = state.projection;
    const presets = [100.0, 300.0, 500.0];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    if (state.projectionLoading)
                      const Text('Crunching your what-if scenario…',
                          style: TextStyle(
                              color: _textSecondary, fontSize: 12, height: 1.5))
                    else
                      Text(
                        projection?.insight ??
                            'Connect more accounts to unlock a personalized net worth projection.',
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 12, height: 1.5),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('If I save extra per month:',
              style: TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: presets.map((delta) {
              final selected = projection?.monthlyContributionDelta == delta;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _bloc.add(
                      NetWorthProjectionRequested(monthlyContributionDelta: delta)),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? _green.withValues(alpha: 0.12) : _bg,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: selected ? _green : _border),
                    ),
                    child: Text(
                      '+\$${delta.toStringAsFixed(0)}/mo',
                      style: TextStyle(
                        color: selected ? _green : _textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<(String, double)> _historyPoints(List<NetWorthTrendPoint> trend) {
    if (trend.isEmpty) return [];
    const maxPoints = 6;
    final step = (trend.length / maxPoints).ceil().clamp(1, trend.length);
    final sampled = <NetWorthTrendPoint>[];
    for (int i = 0; i < trend.length; i += step) {
      sampled.add(trend[i]);
    }
    if (sampled.isEmpty || sampled.last != trend.last) {
      sampled.add(trend.last);
    }
    return sampled.map((p) => (_shortDate(p.date), p.netWorth)).toList();
  }

  String _shortDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return iso;
    }
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
    final range = max - min == 0 ? 1.0 : max - min;

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
