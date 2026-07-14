import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/theme/panther_colors.dart';
import '../bloc/affordability_bloc.dart';
import '../bloc/affordability_event.dart';
import '../bloc/affordability_state.dart';

class AffordabilityCheckPage extends StatefulWidget {
  const AffordabilityCheckPage({super.key});

  @override
  State<AffordabilityCheckPage> createState() =>
      _AffordabilityCheckPageState();
}

class _AffordabilityCheckPageState extends State<AffordabilityCheckPage> {
  late final AffordabilityBloc _bloc;
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController(text: 'General Purchase');

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<AffordabilityBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _runCheck() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    _bloc.add(AffordabilityCheckRequested(
      amount: amount,
      merchant: _merchantController.text.trim().isEmpty
          ? 'General Purchase'
          : _merchantController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: PantherColors.bg,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A))),
            ),
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
                          _buildInputCard(),
                          const SizedBox(height: 16),
                          BlocBuilder<AffordabilityBloc, AffordabilityState>(
                            builder: (context, state) {
                              if (state is AffordabilityLoading) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          PantherColors.brand),
                                    ),
                                  ),
                                );
                              }
                              if (state is AffordabilityLoaded) {
                                return _buildResultCard(state);
                              }
                              if (state is AffordabilityError) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    state.message,
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: PantherColors.negative,
                                    ),
                                  ),
                                );
                              }
                              return _buildPlaceholderCard();
                            },
                          ),
                          const SizedBox(height: 22),
                          _buildAffordabilityFactors(),
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
              icon:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Column(
            children: [
              Text(
                'Affordability & BNPL Readiness',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Prevent financial regret',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PantherColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check Affordability',
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: TextStyles.titleLarge.copyWith(
              color: PantherColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyles.titleLarge.copyWith(
                color: PantherColors.textSubtle,
                fontSize: 28,
              ),
              prefixText: '\$ ',
              prefixStyle: TextStyles.titleLarge.copyWith(
                color: PantherColors.textSecondary,
                fontSize: 28,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _merchantController,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Merchant / purpose',
              hintStyle: TextStyles.bodyMedium.copyWith(
                color: PantherColors.textSubtle,
              ),
              prefixIcon: const Icon(Icons.storefront_outlined,
                  color: PantherColors.textSubtle, size: 18),
              filled: true,
              fillColor: PantherColors.cardAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _runCheck,
              style: ElevatedButton.styleFrom(
                backgroundColor: PantherColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'Check Now',
                style: TextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(AffordabilityLoaded state) {
    final result = state.result;
    final isApproved = result.verdict.toUpperCase().contains('APPROV') ||
        result.verdict.toUpperCase().contains('YES') ||
        result.verdict.toUpperCase().contains('SAFE') ||
        result.verdict.toUpperCase().contains('CAN');
    final verdictColor =
        isApproved ? PantherColors.positive : PantherColors.negative;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: verdictColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isApproved ? Icons.check_circle_outline : Icons.warning_amber,
                color: verdictColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                result.verdict,
                style: TextStyles.titleMedium.copyWith(
                  color: verdictColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.summary,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (result.safeAmount != null) ...[
            const SizedBox(height: 12),
            Text(
              'Safe amount: \$${result.safeAmount!.toStringAsFixed(2)}',
              style: TextStyles.bodyMedium.copyWith(
                color: PantherColors.positive,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PantherColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome,
              color: PantherColors.brand, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enter an amount above and tap "Check Now" to get an AI-powered affordability assessment.',
              style: TextStyles.bodySmall.copyWith(
                color: PantherColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffordabilityFactors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Affordability Factors',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFactorCard(
                'Active BNPL',
                'Credit used',
                '-2%',
                PantherColors.textSecondary,
                _ChartType.slight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFactorCard(
                'Spending Pattern',
                'Stable',
                '+1%',
                PantherColors.positive,
                _ChartType.wavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFactorCard(
                'Affordability Level',
                '75%',
                '+1%',
                PantherColors.positive,
                _ChartType.rising,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFactorCard(
                'Balance Trend',
                'Growing',
                '+3%',
                PantherColors.positive,
                _ChartType.flat,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFactorCard(
    String title,
    String subtitle,
    String change,
    Color chartColor,
    _ChartType chartType,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PantherColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.textSubtle,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: CustomPaint(
              painter: _MiniChartPainter(chartColor, chartType),
              size: const Size(double.infinity, 40),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            change,
            style: TextStyles.bodySmall.copyWith(
              color: change.startsWith('-')
                  ? PantherColors.negative
                  : PantherColors.positive,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChartType { flat, slight, wavy, rising }

class _MiniChartPainter extends CustomPainter {
  final Color color;
  final _ChartType type;
  _MiniChartPainter(this.color, this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    List<double> points;
    switch (type) {
      case _ChartType.flat:
        points = [0.5, 0.48, 0.52, 0.49, 0.51, 0.48, 0.5, 0.47, 0.5, 0.49];
        break;
      case _ChartType.slight:
        points = [0.4, 0.45, 0.42, 0.5, 0.48, 0.55, 0.52, 0.58, 0.55, 0.6];
        break;
      case _ChartType.wavy:
        points = [0.6, 0.4, 0.55, 0.35, 0.5, 0.4, 0.45, 0.35, 0.5, 0.4];
        break;
      case _ChartType.rising:
        points = [0.7, 0.65, 0.6, 0.62, 0.55, 0.5, 0.52, 0.45, 0.4, 0.35];
        break;
    }

    final xStep = size.width / (points.length - 1);
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i * xStep;
      final y = size.height * points[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * xStep;
        final prevY = size.height * points[i - 1];
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
