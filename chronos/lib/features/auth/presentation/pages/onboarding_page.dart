import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/feature_walkthrough_page.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import '../bloc/onboarding/onboarding_event.dart';
import '../bloc/onboarding/onboarding_state.dart';

const _slides = [
  WalkthroughSlide(
    title: 'All your money.\nOne system.',
    subtitle: 'Banking, crypto, payments and\nlife tools, all connected.',
    icon: Icons.account_balance_wallet_rounded,
    accentColor: Color(0xFF3B82F6),
    pexelsQuery: 'contactless payment finance mobile',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/7669659/7669659-hd_1080_1920_25fps.mp4',
  ),
  WalkthroughSlide(
    title: 'Buy now.\nPay intelligently.',
    subtitle: 'Flexible payments, smart limits\nand responsible spending.',
    icon: Icons.shopping_bag_rounded,
    accentColor: Color(0xFFE53935),
    pexelsQuery: 'smartphone mobile payment e-commerce',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/7680438/7680438-hd_1080_1920_25fps.mp4',
  ),
  WalkthroughSlide(
    title: 'Powered by\nPanther AI',
    subtitle: 'Real-time insights, predictions\nand guidance built around you.',
    icon: Icons.psychology_rounded,
    accentColor: Color(0xFF7C6EF0),
    pexelsQuery: 'artificial intelligence technology neon',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/6984649/6984649-hd_1080_1920_30fps.mp4',
  ),
  WalkthroughSlide(
    title: 'Trade beyond\nthe basics',
    subtitle: 'Crypto, NFTs, tokenized assets,\nanalytics and AI insights.',
    icon: Icons.currency_bitcoin_rounded,
    accentColor: Color(0xFFF7931A),
    pexelsQuery: 'cryptocurrency bitcoin trading smartphone',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/7413963/7413963-hd_1080_1920_25fps.mp4',
  ),
  WalkthroughSlide(
    title: 'Your Life,\nOrganized',
    subtitle: 'Learning, growth, vision and\nwellbeing in one place.',
    icon: Icons.self_improvement_rounded,
    accentColor: Color(0xFF14B8A6),
    pexelsQuery: 'yoga wellness lifestyle nature park',
    fallbackVideoUrl:
        'https://videos.pexels.com/video-files/8173075/8173075-hd_1080_1920_30fps.mp4',
  ),
];

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _finish(BuildContext context) =>
      context.read<OnboardingBloc>().add(const OnboardingCompleted());

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingNotRequired) {
          context.go(RouteConstants.signUp.toPath);
        }
      },
      child: FeatureWalkthroughPage(
        slides: _slides,
        onSkip: () => _finish(context),
        onFinish: () => _finish(context),
      ),
    );
  }
}

class OnboardingRoute extends StatelessWidget {
  const OnboardingRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => sl<OnboardingBloc>(),
      child: const OnboardingPage(),
    );
  }
}
