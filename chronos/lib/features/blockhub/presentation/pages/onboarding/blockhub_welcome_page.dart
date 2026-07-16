import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'risk_disclosure_page.dart';

class BlockHubWelcomePage extends StatefulWidget {
  const BlockHubWelcomePage({super.key});

  @override
  State<BlockHubWelcomePage> createState() => _BlockHubWelcomePageState();
}

class _BlockHubWelcomePageState extends State<BlockHubWelcomePage>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _videoCtrl;
  late AnimationController _animCtrl;
  bool _videoReady = false;

  static const _bg = Color(0xFF06060E);
  static const _lightGray = Color(0xFFE5E5E5);
  static const _nearWhite = Color(0xFFF8F8F8);

  static const _videoUrl =
      'https://videos.pexels.com/video-files/7413963/7413963-hd_1080_1920_25fps.mp4';

  static const _features = [
    _Feature(Icons.currency_bitcoin_rounded, 'Crypto Trading',
        'Buy, sell and swap digital assets instantly'),
    _Feature(Icons.collections_rounded, 'NFT Gallery',
        'Mint, collect and trade unique digital art'),
    _Feature(Icons.psychology_rounded, 'Panther AI',
        'AI-powered signals and market intelligence'),
    _Feature(Icons.account_balance_wallet_rounded, 'Multi-Chain Wallet',
        'Ethereum, Polygon, Arbitrum & Base support'),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

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
    _animCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          // Video background
          if (_videoReady)
            AnimatedOpacity(
              opacity: _videoReady ? 0.3 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoCtrl.value.size.width,
                  height: _videoCtrl.value.size.height,
                  child: VideoPlayer(_videoCtrl),
                ),
              ),
            ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _bg.withValues(alpha: 0.7),
                  _bg.withValues(alpha: 0.85),
                  _bg,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        const SizedBox(height: 40),
                        _buildFeatures(),
                        const SizedBox(height: 40),
                        _buildStatsRow(),
                      ],
                    ),
                  ),
                ),
                _buildBottomCta(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _lightGray.withValues(alpha: 0.08),
              border: Border.all(
                  color: _lightGray.withValues(alpha: 0.2), width: 0.8),
            ),
            child: Icon(Icons.hub_rounded,
                color: _lightGray.withValues(alpha: 0.8), size: 18),
          ),
          const SizedBox(width: 8),
          const Text('BlockHub',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiskDisclosurePage()),
            ),
            child: Text('Skip',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45), fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, __) => Opacity(
        opacity: (_animCtrl.value * 2).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - _animCtrl.value)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _lightGray.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _lightGray.withValues(alpha: 0.2), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _lightGray.withValues(alpha: 0.7))),
                    const SizedBox(width: 6),
                    Text('POWERED BY PANTHER AI',
                        style: TextStyle(
                            color: _lightGray.withValues(alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('The crypto hub\nyou\'ve been\nwaiting for.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5)),
              const SizedBox(height: 16),
              Text(
                'Trade crypto, collect NFTs and get AI-powered market intelligence — all in one place.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 15,
                    height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: _features.asMap().entries.map((e) {
        final delay = e.key * 0.1;
        return AnimatedBuilder(
          animation: _animCtrl,
          builder: (_, __) {
            final t = ((_animCtrl.value - delay) / 0.6).clamp(0.0, 1.0);
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(20 * (1 - t), 0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildFeatureTile(e.value),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildFeatureTile(_Feature f) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.07), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _lightGray.withValues(alpha: 0.08),
            ),
            child: Icon(f.icon,
                color: _lightGray.withValues(alpha: 0.75), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(f.subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.2), size: 14),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statBox('50+', 'Cryptocurrencies'),
        const SizedBox(width: 12),
        _statBox('Multi-Chain', 'Wallet Support'),
        const SizedBox(width: 12),
        _statBox('AI-First', 'Intelligence'),
      ],
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _lightGray.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _lightGray.withValues(alpha: 0.12), width: 0.8),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: _nearWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 9,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiskDisclosurePage()),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: const Text('Get Started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          Text('By continuing you agree to our Terms & Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25), fontSize: 11)),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Feature(this.icon, this.title, this.subtitle);
}
