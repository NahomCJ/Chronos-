
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/constants.dart';
import '../ui_models/onboarding_slide_ui_model.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import '../bloc/onboarding/onboarding_event.dart';
import '../bloc/onboarding/onboarding_state.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  int _index = 0;

  final List<OnboardingSlideModel> _slides = const [
    OnboardingSlideModel(
      assetPath: 'assets/onboarding_1.png',
      title: 'All your money. One system.',
      subtitle: 'Banking, crypto, payments, life\ntools connected.',
    ),
    OnboardingSlideModel(
      assetPath: 'assets/onboarding_2.png',
      title: 'Powered by Panther AI',
      subtitle: 'Real-time insights, predictions,\nand guidance built around you.',
    ),
    OnboardingSlideModel(
      assetPath: 'assets/onboarding_3.png',
      title: 'Buy now. Pay intelligently.',
      subtitle: 'Flexible payments, smart limits, and\nresponsible spending.',
    ),
    OnboardingSlideModel(
      assetPath: 'assets/onboarding_4.png',
      title: 'Trade beyond the basics',
      subtitle: 'Crypto, NFTs, tokenized assets,\nanalytics, and AI insights.',
    ),
    OnboardingSlideModel(
      assetPath: 'assets/onboarding_5.png',
      title: 'Your Life, Organized',
      subtitle: 'Learning, growth, vision, and wellbeing in\none place.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _slides.length - 1;

  void _finish() {
    context.read<OnboardingBloc>().add(const OnboardingCompleted());
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingNotRequired) {
          context.go(RouteConstants.signUp.toPath);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Space.verticalSmall,
              Container(
                height: 2,
                margin: Constants.paddingHorizontalMedium,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: Constants.borderRadiusFull,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (_index + 1) / _slides.length,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5B400),
                        borderRadius: Constants.borderRadiusFull,
                      ),
                    ),
                  ),
                ),
              ),
              Space.verticalMedium,
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) {
                    setState(() => _index = value);
                  },
                  itemBuilder: (context, i) {
                    final slide = _slides[i];
                    return OnboardingSlide(
                      assetPath: slide.assetPath,
                      title: slide.title,
                      subtitle: slide.subtitle,
                    );
                  },
                ),
              ),
              Padding(
                padding: Constants.paddingHorizontalLarge,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _finish,
                          child: const Text('Skip >>>'),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: Constants.paddingHorizontalTiny,
                          height: 8,
                          width: i == _index ? 20 : 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? const Color(0xFF2A3443)
                                : const Color(0xFFD8DEE7),
                            borderRadius: Constants.borderRadiusFull,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _next,
                          child: Text(_isLast ? 'Get Started' : 'Next'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Space.verticalMedium,
            ],
          ),
        ),
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

