import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_walkthrough_page.dart';
import '../constants/tickpay_colors.dart';

const _slides = [
  WalkthroughSlide(
    title: 'Shop now,\npay smart',
    subtitle: 'Buy from your favorite brands and\nsplit payments your way.',
    icon: Icons.shopping_bag_rounded,
    accentColor: TickpayColors.brandRed,
    pexelsQuery: 'online shopping smartphone checkout',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/7680438/7680438-hd_1080_1920_25fps.mp4',
  ),
  WalkthroughSlide(
    title: 'Flexible plans,\nreal limits',
    subtitle: 'See your credit line, plan payments,\nand stay in control.',
    icon: Icons.credit_score_rounded,
    accentColor: TickpayColors.accentPurple,
    pexelsQuery: 'credit card finance planning',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/7534191/7534191-hd_1080_1920_30fps.mp4',
  ),
  WalkthroughSlide(
    title: 'AI picks that fit\nyour budget',
    subtitle: 'Chris finds deals and flags what\nyou can actually afford.',
    icon: Icons.auto_awesome_rounded,
    accentColor: TickpayColors.info,
    pexelsQuery: 'artificial intelligence shopping recommendation',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/6984649/6984649-hd_1080_1920_30fps.mp4',
  ),
];

/// First-time, skippable video walkthrough for TickPay. Shown once before
/// the dashboard; see the `tickpay_walkthrough_seen` gate in
/// [TickPayDashboardPage].
class TickpayWalkthroughPage extends StatelessWidget {
  final VoidCallback onDone;
  const TickpayWalkthroughPage({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return FeatureWalkthroughPage(
      slides: _slides,
      onSkip: onDone,
      onFinish: onDone,
    );
  }
}
