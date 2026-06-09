import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../../core/theme/text_theme.dart';
import 'risk_disclosure_page.dart';

class BlockHubWelcomePage extends StatefulWidget {
  const BlockHubWelcomePage({super.key});

  @override
  State<BlockHubWelcomePage> createState() => _BlockHubWelcomePageState();
}

class _BlockHubWelcomePageState extends State<BlockHubWelcomePage> {
  late final VideoPlayerController _videoCtrl;
  bool _videoReady = false;

  // Crypto trading on smartphone  vertical portrait (Pexels #34453413)
  static const _videoUrl =
      'https://videos.pexels.com/video-files/34453413/14599279_1080_1920_25fps.mp4';

  @override
  void initState() {
    super.initState();
    _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(_videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _videoCtrl
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      });
  }

  @override
  void dispose() {
    _videoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── White top section ──────────────────────────────────────────
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Logo / brand
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.hub_outlined,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'BlockHub',
                          style: TextStyles.titleLarge.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Trade smarter.',
                      textAlign: TextAlign.center,
                      style: TextStyles.headlineMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Own your assets.',
                      textAlign: TextAlign.center,
                      style: TextStyles.headlineMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Trade crypto & tokenized assets with\nAI-powered insights from Panther.',
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.grey[500],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Badges row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _badge(Icons.shield_outlined, 'Regulated'),
                        const SizedBox(width: 8),
                        _badge(Icons.auto_awesome, 'AI-Powered'),
                        const SizedBox(width: 8),
                        _badge(Icons.lock_outline, 'Custodial'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Dark section with video bg + crypto cards ──────────────────
            SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  // Video background
                  if (_videoReady)
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoCtrl.value.size.width,
                          height: _videoCtrl.value.size.height,
                          child: VideoPlayer(_videoCtrl),
                        ),
                      ),
                    )
                  else
                    Container(color: const Color(0xFF0D0A1E)),

                  // Dark overlay so cards are readable
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xDD000000), Color(0xF5000000)],
                        ),
                      ),
                    ),
                  ),

                  // Crypto cards + buttons on top
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                    child: Column(
                      children: [
                        _cryptoGrid(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RiskDisclosurePage(),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
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
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward,
                                        size: 16, color: Colors.black),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(
                                      color: Colors.white54, width: 1),
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
                      ],
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

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFDC8F4A), size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: const Color(0xFF444444),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cryptoGrid() {
    final cards = [
      _CryptoData('BTC', 'Bitcoin', '\$52,291', '+0.25%', true,
          const Color(0xFFF59E0B)),
      _CryptoData('SOL', 'Solana', '\$14,291', '-0.25%', false,
          const Color(0xFF9945FF)),
      _CryptoData('ITC', 'Litecoin', '\$8,291', '-0.25%', false,
          const Color(0xFF345D9D)),
      _CryptoData('ETH', 'Ethereum', '\$28,291', '+0.25%', true,
          const Color(0xFF627EEA)),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _cryptoCard(cards[0])),
            const SizedBox(width: 10),
            Expanded(child: _cryptoCard(cards[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _cryptoCard(cards[2])),
            const SizedBox(width: 10),
            Expanded(child: _cryptoCard(cards[3])),
          ],
        ),
      ],
    );
  }

  Widget _cryptoCard(_CryptoData d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
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
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.symbol,
                        style: TextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                    Text(d.name,
                        style: TextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 10)),
                  ],
                ),
              ),
              Icon(
                d.isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: d.isPositive
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(d.price,
              style: TextStyles.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(d.change,
              style: TextStyles.bodySmall.copyWith(
                  color: d.isPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          const SizedBox(height: 6),
          SizedBox(
            height: 24,
            child: CustomPaint(
              painter: _MiniChartPainter(d.isPositive),
              size: const Size(double.infinity, 24),
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
      this.symbol, this.name, this.price, this.change, this.isPositive,
      this.color);
}

class _MiniChartPainter extends CustomPainter {
  final bool isPositive;
  _MiniChartPainter(this.isPositive);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pts = isPositive
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
