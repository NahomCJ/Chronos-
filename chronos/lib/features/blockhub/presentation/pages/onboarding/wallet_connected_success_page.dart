import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletConnectedSuccessPage extends StatefulWidget {
  const WalletConnectedSuccessPage({super.key});

  @override
  State<WalletConnectedSuccessPage> createState() =>
      _WalletConnectedSuccessPageState();
}

class _WalletConnectedSuccessPageState
    extends State<WalletConnectedSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _confettiCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _slideAnim;

  static const _bg = Color(0xFF06060E);
  static const _amber = Color(0xFFF59E0B);
  static const _green = Color(0xFF22C55E);
  static const _teal = Color(0xFF14B8A6);

  final _confettiItems = List.generate(
    20,
    (i) => _ConfettiItem(
      x: Random().nextDouble(),
      y: Random().nextDouble() * -1,
      color: [
        const Color(0xFFF59E0B),
        const Color(0xFF22C55E),
        const Color(0xFF3B82F6),
        const Color(0xFF8B5CF6),
        const Color(0xFF14B8A6),
      ][i % 5],
      size: 6.0 + Random().nextDouble() * 8,
      speed: 0.3 + Random().nextDouble() * 0.7,
    ),
  );

  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('blockhub_wallet_setup_completed', true);
    if (mounted) {
      Navigator.of(context, rootNavigator: true)
          .popUntil((route) => route.isFirst);
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _slideAnim =
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _confettiCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
            SafeArea(
        child: Stack(
          children: [
            // Confetti
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                    items: _confettiItems, progress: _confettiCtrl.value),
              ),
            ),

            // Content
            Column(
              children: [
                const Spacer(),
                _buildSuccessOrb(),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (_, __) => Opacity(
                    opacity: _slideAnim.value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - _slideAnim.value)),
                      child: _buildContent(),
                    ),
                  ),
                ),
                const Spacer(),
                _buildBottomSection(),
              ],
            ),
          ],
        ),
      ),
          ],
        ),
    );
  }

  Widget _buildSuccessOrb() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        final glow = 0.3 + _pulseCtrl.value * 0.4;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: 0.04 + _pulseCtrl.value * 0.06),
              ),
            ),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: 0.08 + _pulseCtrl.value * 0.08),
              ),
            ),
            // Core circle
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _green.withValues(alpha: 0.5),
                    _green.withValues(alpha: 0.15),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                      color: _green.withValues(alpha: glow),
                      blurRadius: 30,
                      spreadRadius: 4),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 48),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Text('Wallet Connected!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Text(
            'You\'re all set. Your blockchain wallet is live and ready to trade, collect and grow.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
                height: 1.6),
          ),
          const SizedBox(height: 28),
          _buildCapabilityRow(),
        ],
      ),
    );
  }

  Widget _buildCapabilityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _capabilityBadge(Icons.currency_bitcoin_rounded, 'Trade', _amber),
        const SizedBox(width: 14),
        _capabilityBadge(Icons.show_chart_rounded, 'Stocks', _teal),
        const SizedBox(width: 14),
        _capabilityBadge(Icons.psychology_rounded, 'AI Intel', const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _capabilityBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          GestureDetector(
            onTap: _completeSetup,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: _green.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: const Text('Enter BlockHub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          Text('Your assets are secured by military-grade encryption',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25), fontSize: 11)),
        ],
      ),
    );
  }
}

class _ConfettiItem {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double speed;
  const _ConfettiItem(
      {required this.x,
      required this.y,
      required this.color,
      required this.size,
      required this.speed});
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiItem> items;
  final double progress;
  const _ConfettiPainter({required this.items, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final item in items) {
      final y = (item.y + progress * item.speed * 1.5) % 1.2;
      final x = item.x * size.width;
      final yPos = y * size.height;
      if (yPos < 0 || yPos > size.height) continue;

      canvas.drawRect(
        Rect.fromCenter(
            center: Offset(x, yPos),
            width: item.size,
            height: item.size * 0.5),
        Paint()
          ..color = item.color.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
