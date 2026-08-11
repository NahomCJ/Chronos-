import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_walkthrough_page.dart';

const _lifexTeal = Color(0xFF14B8A6);

const _slides = [
  WalkthroughSlide(
    title: 'Your life,\nall in one place',
    subtitle: 'Health, finance, learning and growth —\ntracked together, not scattered.',
    icon: Icons.self_improvement_rounded,
    accentColor: _lifexTeal,
    tags: ['Health', 'Finance', 'Learning'],
    pexelsQuery: 'wellness lifestyle nature calm',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/8173075/8173075-hd_1080_1920_30fps.mp4',
  ),
  WalkthroughSlide(
    title: 'A guide who\nknows you',
    subtitle: 'Chris checks in, spots patterns and\nnudges you toward your goals.',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF7C6EF0),
    tags: ['Chris AI', 'Check-ins', 'Nudges'],
    pexelsQuery: 'artificial intelligence technology neon',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/6984649/6984649-hd_1080_1920_30fps.mp4',
  ),
  WalkthroughSlide(
    title: 'Twelve modules,\none score',
    subtitle: 'Financial, social, spiritual and more —\nsee how they add up.',
    icon: Icons.insights_rounded,
    accentColor: Color(0xFF3B82F6),
    tags: ['12 Modules', 'One Score', 'Insights'],
    pexelsQuery: 'purple abstract data visualization',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/7101912/7101912-hd_1080_1920_30fps.mp4',
  ),
];

/// First-time, skippable video walkthrough for LifeX. Shown once before the
/// hub; see the `lifex_walkthrough_seen` gate in [LifeXPage]. Distinct from
/// the deeper chat-based `lifex_onboarding_page.dart` survey, which stays
/// unaffected.
class LifexWalkthroughPage extends StatelessWidget {
  final VoidCallback onDone;
  const LifexWalkthroughPage({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return FeatureWalkthroughPage(
      slides: _slides,
      onSkip: onDone,
      onFinish: onDone,
    );
  }
}
