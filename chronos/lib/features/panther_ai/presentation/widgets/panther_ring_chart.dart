import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/panther_colors.dart';

/// One wedge of a [PantherRingChart] — a labeled value with its own color.
/// [icon], if set, renders as a small glyph inside the legend's dot instead
/// of a bare color dot — used by Auto-Invest to show an asset-class icon
/// next to each slice. Left null, existing callers render exactly as before.
class PantherRingSlice {
  final String label;
  final double value;
  final Color color;
  final IconData? icon;
  const PantherRingSlice({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });
}

/// Shared composition-chart widget for "how is X made up of Y" screens
/// (debt composition, tax breakdown, spending mix). Replaces the one-off
/// `_DonutPainter`/`_PieChartPainter` classes that used to be duplicated
/// per page — those drew bare arcs with no center total and no percentage
/// on the legend, which made them unreadable at a glance.
class PantherRingChart extends StatelessWidget {
  final List<PantherRingSlice> slices;
  final String centerLabel;
  final String centerSubLabel;
  final double progress;
  final double size;

  const PantherRingChart({
    super.key,
    required this.slices,
    required this.centerLabel,
    required this.centerSubLabel,
    this.progress = 1.0,
    this.size = 152,
  });

  double get _total => slices.fold(0.0, (s, e) => s + e.value);

  @override
  Widget build(BuildContext context) {
    final total = _total;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  slices: slices,
                  total: total,
                  progress: progress,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerLabel,
                    style: const TextStyle(
                      color: PantherColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    centerSubLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: PantherColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slices.map((s) {
              final pct = total <= 0 ? 0.0 : (s.value / total) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    if (s.icon != null)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.color.withValues(alpha: 0.14),
                        ),
                        child: Icon(s.icon, size: 12, color: s.color),
                      )
                    else
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.color,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.label,
                        style: const TextStyle(
                          color: PantherColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: s.color,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<PantherRingSlice> slices;
  final double total;
  final double progress;
  const _RingPainter({
    required this.slices,
    required this.total,
    required this.progress,
  });

  static const _strokeWidth = 16.0;
  static const _gap = 0.045;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - _strokeWidth / 2 - 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = PantherColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );

    if (total <= 0) return;

    double startAngle = -pi / 2;
    for (final s in slices) {
      final sweep = (s.value / total) * 2 * pi * progress;
      final drawSweep = (sweep - _gap).clamp(0.0, sweep);
      if (drawSweep > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + _gap / 2,
          drawSweep,
          false,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = _strokeWidth
            ..strokeCap = StrokeCap.round,
        );
      }
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.slices != slices || old.total != total;
}
