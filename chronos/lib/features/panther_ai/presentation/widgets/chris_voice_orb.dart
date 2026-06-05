import 'dart:math' as math;
import 'package:flutter/material.dart';

enum OrbState { idle, thinking, speaking }

class ChrisVoiceOrb extends StatefulWidget {
  final OrbState state;
  final double size;
  final List<Color>? idleColorOverride;

  const ChrisVoiceOrb({
    super.key,
    required this.state,
    this.size = 140,
    this.idleColorOverride,
  });

  @override
  State<ChrisVoiceOrb> createState() => _ChrisVoiceOrbState();
}

class _ChrisVoiceOrbState extends State<ChrisVoiceOrb>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _morphController;
  late AnimationController _stateTransitionController;

  OrbState _currentState = OrbState.idle;
  OrbState _targetState = OrbState.idle;

  @override
  void initState() {
    super.initState();
    _currentState = widget.state;
    _targetState = widget.state;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _stateTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(ChrisVoiceOrb old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _targetState = widget.state;
      _stateTransitionController.forward(from: 0).then((_) {
        setState(() => _currentState = _targetState);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _morphController.dispose();
    _stateTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _morphController,
        _stateTransitionController,
      ]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _OrbPainter(
            pulseValue: _pulseController.value,
            morphValue: _morphController.value,
            state: _currentState,
            transitionProgress: _stateTransitionController.value,
            targetState: _targetState,
            idleColorOverride: widget.idleColorOverride,
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double pulseValue;
  final double morphValue;
  final OrbState state;
  final double transitionProgress;
  final OrbState targetState;
  final List<Color>? idleColorOverride;

  const _OrbPainter({
    required this.pulseValue,
    required this.morphValue,
    required this.state,
    required this.transitionProgress,
    required this.targetState,
    this.idleColorOverride,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.32;

    final (pulseSpeed, pulseAmp, morphAmp) = _stateParams(state);

    final pulse = 1.0 +
        math.sin(pulseValue * math.pi * 2 * pulseSpeed) * pulseAmp;

    _drawOuterGlow(canvas, center, baseRadius * 1.8 * pulse);
    _drawBlob(canvas, center, baseRadius * 1.15 * pulse, morphAmp);
    _drawCore(canvas, center, baseRadius * pulse);
    _drawHighlight(canvas, center, baseRadius * pulse);
  }

  (double, double, double) _stateParams(OrbState s) {
    return switch (s) {
      OrbState.idle => (0.8, 0.03, 0.05),
      OrbState.thinking => (2.0, 0.07, 0.12),
      OrbState.speaking => (4.0, 0.12, 0.20),
    };
  }

  List<Color> _stateColors(OrbState s) {
    return switch (s) {
      OrbState.idle => idleColorOverride ?? [
          const Color(0xFFDC8F4A),
          const Color(0xFFB06428),
          const Color(0xFFFFBF7C),
        ],
      OrbState.thinking => [
          const Color(0xFF6A8EDC),
          const Color(0xFF3A5BAA),
          const Color(0xFF8AAAFF),
        ],
      OrbState.speaking => [
          const Color(0xFFE07040),
          const Color(0xFFCC3A80),
          const Color(0xFFFFB050),
        ],
    };
  }

  List<Color> get _colors {
    if (transitionProgress == 0.0 || state == targetState) {
      return _stateColors(state);
    }
    final from = _stateColors(state);
    final to = _stateColors(targetState);
    return List.generate(3, (i) => Color.lerp(from[i], to[i], transitionProgress)!);
  }

  void _drawOuterGlow(Canvas canvas, Offset center, double radius) {
    final c = _colors;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          c[0].withValues(alpha: 0.20),
          c[1].withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(center, radius, paint);
  }

  void _drawBlob(Canvas canvas, Offset center, double radius, double morphAmp) {
    final c = _colors;
    final path = Path();
    const segments = 72;

    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * math.pi * 2;
      final t = morphValue * math.pi * 2;

      final r = radius *
          (1.0 +
              morphAmp * math.sin(angle * 3 + t) +
              morphAmp * 0.6 * math.sin(angle * 5 - t * 1.3) +
              morphAmp * 0.3 * math.sin(angle * 7 + t * 0.7));

      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          c[0].withValues(alpha: 0.45),
          c[1].withValues(alpha: 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, paint);
  }

  void _drawCore(Canvas canvas, Offset center, double radius) {
    final c = _colors;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [c[2], c[0], c[1]],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  void _drawHighlight(Canvas canvas, Offset center, double radius) {
    final hlCenter = Offset(
      center.dx - radius * 0.22,
      center.dy - radius * 0.22,
    );
    final hlRadius = radius * 0.42;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.38),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: hlCenter, radius: hlRadius));

    canvas.drawCircle(hlCenter, hlRadius, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.pulseValue != pulseValue ||
      old.morphValue != morphValue ||
      old.state != state ||
      old.transitionProgress != transitionProgress ||
      old.targetState != targetState ||
      old.idleColorOverride != idleColorOverride;
}
