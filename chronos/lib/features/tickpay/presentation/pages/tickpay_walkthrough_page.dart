import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_walkthrough_page.dart';
import '../constants/tickpay_colors.dart';

const _slides = [
  WalkthroughSlide(
    title: 'Shop now,\npay smart',
    subtitle: 'Buy from your favorite brands and\nsplit payments your way.',
    icon: Icons.shopping_bag_rounded,
    accentColor: TickpayColors.brandRed,
    tags: ['Shopping', 'Brands', 'Flexible Pay'],
    pexelsQuery: 'young woman shopping fashion boutique smiling',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/6565836/6565836-hd_1080_1920_24fps.mp4',
  ),
  WalkthroughSlide(
    title: 'Flexible plans,\nreal limits',
    subtitle: 'See your credit line, plan payments,\nand stay in control.',
    icon: Icons.credit_score_rounded,
    accentColor: TickpayColors.accentPurple,
    tags: ['Credit Line', 'Planning', 'Control'],
    pexelsQuery: 'contactless card payment hand close up',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/6995103/6995103-hd_1080_1920_30fps.mp4',
  ),
  WalkthroughSlide(
    title: 'AI picks that fit\nyour budget',
    subtitle: 'Chris finds deals and flags what\nyou can actually afford.',
    icon: Icons.auto_awesome_rounded,
    accentColor: TickpayColors.info,
    tags: ['AI Picks', 'Budget', 'Deals'],
    pexelsQuery: 'smartphone shopping app scrolling deals',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/7547770/7547770-uhd_1440_2560_25fps.mp4',
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
