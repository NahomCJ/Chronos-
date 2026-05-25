import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'risk_disclosure_page.dart';

class BlockHubWelcomePage extends StatelessWidget {
  const BlockHubWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // ── White top section ──────────────────────────────────────────
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Header
                        Text(
                          'BlockHub',
                          style: TextStyles.titleLarge.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Title — two lines
                        Text(
                          'Trade smarter',
                          textAlign: TextAlign.center,
                          style: TextStyles.headlineMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                          ),
                        ),
                        Text(
                          'Own your assets.',
                          textAlign: TextAlign.center,
                          style: TextStyles.headlineMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Description
                        Text(
                          'Trade crypto & tokenized assets with AI-powered insights from Panther. Secure, regulated, and built for the future.',
                          textAlign: TextAlign.center,
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.grey[600],
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Badges: 2 on top row, 1 centered below
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _badge(Icons.shield_outlined, 'Regulated'),
                            const SizedBox(width: 12),
                            _badge(Icons.auto_awesome, 'AI-Powered'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _badge(Icons.lock_outline, 'Custodial'),
                      ],
                    ),
                  ),
                ),
                // ── Dark section: crypto cards ─────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                      image: AssetImage('assets/background.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _cryptoGrid(),
                ),
                // ── Buttons ────────────────────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                      image: AssetImage('assets/background.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              () => Navigator.of(
                                context,
                                rootNavigator: true,
                              ).push(
                                MaterialPageRoute(
                                  builder: (_) => const RiskDisclosurePage(),
                                ),
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyles.labelLarge.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            'Learn More',
                            style: TextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFDC8F4A), size: 17),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cryptoGrid() {
    final cards = [
      _CryptoData(
        'BTC',
        'Bitcoin',
        '\$52,291',
        '+0.25%',
        true,
        const Color(0xFFF59E0B),
      ),
      _CryptoData(
        'SOL',
        'Solana',
        '\$14,291',
        '-0.25%',
        false,
        const Color(0xFF9945FF),
      ),
      _CryptoData(
        'ITC',
        'Litecoin',
        '\$8,291',
        '-0.25%',
        false,
        const Color(0xFF345D9D),
      ),
      _CryptoData(
        'ETH',
        'Ethereum',
        '\$28,291',
        '+0.25%',
        true,
        const Color(0xFF627EEA),
      ),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _cryptoCard(cards[0])),
            const SizedBox(width: 12),
            Expanded(child: _cryptoCard(cards[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _cryptoCard(cards[2])),
            const SizedBox(width: 12),
            Expanded(child: _cryptoCard(cards[3])),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _cryptoCard(_CryptoData d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: d.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    d.symbol[0],
                    style: TextStyle(
                      color: d.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.symbol,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      d.name,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                d.isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color:
                    d.isPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            d.price,
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            d.change,
            style: TextStyles.bodySmall.copyWith(
              color:
                  d.isPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: CustomPaint(
              painter: _MiniChartPainter(d.isPositive),
              size: const Size(double.infinity, 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _CryptoData {
  final String symbol, name, price, change;
  final bool isPositive;
  final Color color;
  const _CryptoData(
    this.symbol,
    this.name,
    this.price,
    this.change,
    this.isPositive,
    this.color,
  );
}

class _MiniChartPainter extends CustomPainter {
  final bool isPositive;
  _MiniChartPainter(this.isPositive);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color =
              isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final pts =
        isPositive
            ? [0.7, 0.5, 0.6, 0.4, 0.5, 0.3, 0.2]
            : [0.3, 0.5, 0.4, 0.6, 0.5, 0.7, 0.8];
    final xStep = size.width / (pts.length - 1);
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = i * xStep;
      final y = size.height * pts[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final px = (i - 1) * xStep;
        final py = size.height * pts[i - 1];
        path.cubicTo((px + x) / 2, py, (px + x) / 2, y, x, y);
      }
    }
    canvas.drawPath(path, paint);

    // End dot
    final lastX = (pts.length - 1) * xStep;
    final lastY = size.height * pts.last;
    canvas.drawCircle(
      Offset(lastX, lastY),
      3,
      Paint()
        ..color =
            isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
