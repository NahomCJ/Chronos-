import 'package:flutter/material.dart';

import '../../../../../core/widgets/feature_walkthrough_page.dart';
import 'risk_disclosure_page.dart';

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
  ),
  WalkthroughSlide(
    title: 'Mint, collect\nand trade NFTs',
    subtitle: 'Your gallery for unique digital art\nand collectibles.',
    icon: Icons.collections_rounded,
    accentColor: Color(0xFFEC4899),
    tags: ['Mint', 'Collect', 'Trade'],
    pexelsQuery: 'digital art neon abstract cinematic',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/20407079/20407079-hd_1080_1920_50fps.mp4',
  ),
  WalkthroughSlide(
    title: 'Powered by\nPanther AI',
    subtitle: 'AI-powered signals and market\nintelligence, built in.',
    icon: Icons.psychology_rounded,
    accentColor: Color(0xFF7C6EF0),
    tags: ['AI Signals', 'Market Intel'],
    pexelsQuery: 'purple light waves abstract technology',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/34576602/14651995_1080_1920_30fps.mp4',
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
  ),
];

/// First-time, skippable video walkthrough for BlockHub. Shown once before
/// the experience-level and wallet setup steps.
class BlockHubWelcomePage extends StatelessWidget {
  const BlockHubWelcomePage({super.key});

  void _continue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RiskDisclosurePage()),
    );
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
