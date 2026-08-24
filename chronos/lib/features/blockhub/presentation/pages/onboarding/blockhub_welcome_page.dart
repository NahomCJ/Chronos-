import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/widgets/feature_walkthrough_page.dart';
import 'risk_disclosure_page.dart';

const _walkthroughVideo = 'assets/videos/blockhub_walkthrough.mp4';

const _slides = [
  WalkthroughSlide(
    title: 'Crypto trading,\nmade simple',
    subtitle: 'Buy, sell and swap digital assets\ninstantly, at real market rates.',
    icon: Icons.currency_bitcoin_rounded,
    accentColor: Color(0xFFF7931A),
    tags: ['Buy', 'Sell', 'Swap'],
    pexelsQuery: 'cryptocurrency bitcoin trading smartphone',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/7413963/7413963-hd_1080_1920_25fps.mp4',
    localVideoAsset: _walkthroughVideo,
  ),
  WalkthroughSlide(
    title: 'Stocks & ETFs,\nright here',
    subtitle: 'Invest in top companies and funds\nwith real-time market data.',
    icon: Icons.show_chart_rounded,
    accentColor: Color(0xFF22C55E),
    tags: ['Stocks', 'ETFs', 'Dividends'],
    pexelsQuery: 'stock market finance trading chart',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/20407079/20407079-hd_1080_1920_50fps.mp4',
    localVideoAsset: _walkthroughVideo,
  ),
  WalkthroughSlide(
    title: 'Automated\nTrading',
    subtitle: 'Smart signals and portfolio automation —\nlet Panther AI work the market for you.',
    icon: Icons.psychology_rounded,
    accentColor: Color(0xFF7C6EF0),
    tags: ['Auto-Trade', 'AI Signals'],
    pexelsQuery: 'purple light waves abstract technology',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/34576602/14651995_1080_1920_30fps.mp4',
    localVideoAsset: _walkthroughVideo,
  ),
  WalkthroughSlide(
    title: 'One wallet,\nevery chain',
    subtitle: 'Ethereum, Polygon, Arbitrum and\nBase — all in a single wallet.',
    icon: Icons.account_balance_wallet_rounded,
    accentColor: Color(0xFF3B82F6),
    tags: ['Ethereum', 'Polygon', 'Base'],
    pexelsQuery: 'mobile wallet payment technology',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/4109600/4109600-hd_1080_1920_30fps.mp4',
    localVideoAsset: _walkthroughVideo,
  ),
];

/// First-time, skippable video walkthrough for BlockHub. Shown once before
/// the experience-level and wallet setup steps.
class BlockHubWelcomePage extends StatelessWidget {
  const BlockHubWelcomePage({super.key});

  Future<void> _continue(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('blockhub_onboarding_completed', true);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RiskDisclosurePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeatureWalkthroughPage(
      slides: _slides,
      onSkip: () => _continue(context),
      onFinish: () => _continue(context),
    );
  }
}
