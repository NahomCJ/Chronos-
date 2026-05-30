import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/credit_account.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_formatters.dart';
import 'glass_card.dart';

/// Dark glass card on the Credit Overview screen visualising utilization with
/// a segmented ring plus two breakdown bars. Matches the Figma treatment where
/// this card sits over the dark background, above the light "Recent Activity"
/// sheet.
class CreditUtilizationCard extends StatelessWidget {
  final CreditAccount account;

  const CreditUtilizationCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final int percent = (account.utilization * 100).round();

    return GlassCard(
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credit Utilization',
            style: TextStyles.titleMedium.copyWith(
              color: TickpayColors.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: _SegmentedRingPainter(account.utilization),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: TextStyles.headlineMedium.copyWith(
                          color: TickpayColors.textOnDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Used',
                        style: TextStyles.bodySmall
                            .copyWith(color: TickpayColors.textMutedDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _BreakdownBar(
            label: 'Active Plans',
            amount: account.activePlansAmount,
            fraction: account.activePlansFraction,
          ),
          const SizedBox(height: 14),
          _BreakdownBar(
            label: 'Pending Charges',
            amount: account.pendingChargesAmount,
            fraction: account.pendingChargesFraction,
          ),
        ],
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  final String label;
  final double amount;
  final double fraction;

  const _BreakdownBar({
    required this.label,
    required this.amount,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyles.bodySmall
                  .copyWith(color: TickpayColors.textMutedDark),
            ),
            Text(
              '${TickpayFormatters.money(amount)} (${(fraction * 100).toStringAsFixed(1)}%)',
              style: TextStyles.bodySmall.copyWith(
                color: TickpayColors.textOnDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 5,
            backgroundColor: TickpayColors.glassStrong,
            valueColor: const AlwaysStoppedAnimation(TickpayColors.textOnDark),
          ),
        ),
      ],
    );
  }
}

/// Paints a segmented (dashed) progress ring like the Figma utilization gauge.
class _SegmentedRingPainter extends CustomPainter {
  final double progress;

  _SegmentedRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const int segments = 24;
    const double gap = 0.12; // radians of empty space between segments.
    const double stroke = 10;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final double segArc = (2 * math.pi / segments) - gap;
    final int filled = (progress * segments).round();

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.18);

    final fillPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    for (int i = 0; i < segments; i++) {
      final double start =
          -math.pi / 2 + i * (2 * math.pi / segments) + gap / 2;
      canvas.drawArc(
        rect,
        start,
        segArc,
        false,
        i < filled ? fillPaint : basePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
