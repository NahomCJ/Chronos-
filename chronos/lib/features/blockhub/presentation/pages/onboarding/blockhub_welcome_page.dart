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

  static const _bg = Color(0xFFF7F8FA);
  static const _titleColor = Color(0xFF1A1A2E);
  static const _subtitleColor = Color(0xFF6B7080);
  static const _accent = Color(0xFF7C6EF0);

  static const _videoUrl =
      'https://videos.pexels.com/video-files/7413963/7413963-hd_1080_1920_25fps.mp4';

  static const _features = [
    _Feature(Icons.currency_bitcoin_rounded, 'Crypto Trading',
        'Buy, sell and swap digital assets instantly', Color(0xFFF7931A)),
    _Feature(Icons.collections_rounded, 'NFT Gallery',
        'Mint, collect and trade unique digital art', Color(0xFFEC4899)),
    _Feature(Icons.psychology_rounded, 'Panther AI',
        'AI-powered signals and market intelligence', Color(0xFF7C6EF0)),
    _Feature(Icons.account_balance_wallet_rounded, 'Multi-Chain Wallet',
        'Ethereum, Polygon, Arbitrum & Base support', Color(0xFF3B82F6)),
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
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVideoCard(),
                    const SizedBox(height: 28),
                    _buildHero(),
                    const SizedBox(height: 32),
                    _buildFeatures(),
                    const SizedBox(height: 28),
                    _buildStatsRow(),
                  ],
                ),
              ),
            ),
            _buildBottomCta(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _titleColor, size: 16),
            ),
          ),
          const Spacer(),
          Text('BlockHub',
              style: TextStyle(
                  color: _titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiskDisclosurePage()),
            ),
            child: const Text('Skip',
                style: TextStyle(color: _subtitleColor, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard() {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, __) => Opacity(
        opacity: (_animCtrl.value * 2).clamp(0.0, 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: _accent.withValues(alpha: 0.08)),
                AnimatedOpacity(
                  opacity: _videoReady ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: _videoReady
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoCtrl.value.size.width,
                            height: _videoCtrl.value.size.height,
                            child: VideoPlayer(_videoCtrl),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (!_videoReady)
                  const Center(
                    child: Icon(Icons.currency_bitcoin_rounded,
                        size: 64, color: Color(0x557C6EF0)),
                  ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: _accent)),
                        const SizedBox(width: 6),
                        const Text('POWERED BY PANTHER AI',
                            style: TextStyle(
                                color: _accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, __) => Opacity(
        opacity: (_animCtrl.value * 2).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - _animCtrl.value)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The crypto hub\nyou\'ve been\nwaiting for.',
                  style: TextStyle(
                      color: _titleColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.5)),
              SizedBox(height: 14),
              Text(
                'Trade crypto, collect NFTs and get AI-powered market intelligence — all in one place.',
                style: TextStyle(
                    color: _subtitleColor, fontSize: 15, height: 1.6),
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
                  padding: const EdgeInsets.only(bottom: 12),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: f.color.withValues(alpha: 0.12),
            ),
            child: Icon(f.icon, color: f.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title,
                    style: const TextStyle(
                        color: _titleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(f.subtitle,
                    style: const TextStyle(
                        color: _subtitleColor, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Color(0xFFC7CBD4), size: 14),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: _titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _subtitleColor, fontSize: 9, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
                color: _accent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: _accent.withValues(alpha: 0.32),
                      blurRadius: 16,
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
          const Text('By continuing you agree to our Terms & Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(color: _subtitleColor, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _Feature(this.icon, this.title, this.subtitle, this.color);
}
