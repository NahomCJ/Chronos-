import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/services/pexels_service.dart';
import '../../../tickpay/presentation/utils/tickpay_media.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import '../bloc/onboarding/onboarding_event.dart';
import '../bloc/onboarding/onboarding_state.dart';

class _SlideConfig {
  final String title;
  final String subtitle;
  final String pexelsQuery;
  final String fallbackUrl;
  const _SlideConfig({
    required this.title,
    required this.subtitle,
    required this.pexelsQuery,
    required this.fallbackUrl,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;

  VideoPlayerController? _currentCtrl;
  VideoPlayerController? _nextCtrl;

  int _index = 0;
  bool _videoReady = false;
  bool _isSwitching = false;

  // Mutable list — starts with verified fallbacks, gets replaced by live Pexels results
  late final List<String> _videoUrls;

  static const _configs = [
    _SlideConfig(
      title: 'All your money.\nOne system.',
      subtitle: 'Banking, crypto, payments and\nlife tools — all connected.',
      pexelsQuery: 'contactless payment finance mobile',
      fallbackUrl: TickPayMedia.onboardingFinance,
    ),
    _SlideConfig(
      title: 'Powered by\nPanther AI',
      subtitle: 'Real-time insights, predictions\nand guidance built around you.',
      pexelsQuery: 'artificial intelligence technology neon purple',
      fallbackUrl: TickPayMedia.onboardingAi,
    ),
    _SlideConfig(
      title: 'Buy now.\nPay intelligently.',
      subtitle: 'Flexible payments, smart limits\nand responsible spending.',
      pexelsQuery: 'woman shopping boutique fashion bags',
      fallbackUrl: TickPayMedia.onboardingShopping,
    ),
    _SlideConfig(
      title: 'Trade beyond\nthe basics',
      subtitle: 'Crypto, NFTs, tokenized assets,\nanalytics and AI insights.',
      pexelsQuery: 'cryptocurrency bitcoin trading smartphone',
      fallbackUrl: TickPayMedia.onboardingCrypto,
    ),
    _SlideConfig(
      title: 'Your Life,\nOrganized',
      subtitle: 'Learning, growth, vision and\nwellbeing in one place.',
      pexelsQuery: 'yoga meditation wellness park nature',
      fallbackUrl: TickPayMedia.onboardingLifestyle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _videoUrls = _configs.map((c) => c.fallbackUrl).toList();
    _controller = PageController();
    _initVideo(0);
    _fetchPexelsVideos();
  }

  /// Background fetch: tries to replace each fallback URL with a fresh
  /// portrait HD video from Pexels. Silently no-ops on any failure.
  Future<void> _fetchPexelsVideos() async {
    for (int i = 0; i < _configs.length; i++) {
      final videos = await PexelsService.searchVideos(
        _configs[i].pexelsQuery,
        perPage: 5,
        orientation: 'portrait',
      );
      if (!mounted || videos.isEmpty) continue;

      String? url;
      for (final v in videos) {
        final hd = v.videoFiles
            .where((f) => f.quality == 'hd' && f.fileType.contains('mp4'))
            .toList();
        if (hd.isNotEmpty) {
          url = hd.first.link;
          break;
        }
        final sd = v.videoFiles
            .where((f) => f.fileType.contains('mp4'))
            .toList();
        if (sd.isNotEmpty) {
          url = sd.first.link;
          break;
        }
      }

      if (url == null || !mounted) continue;
      _videoUrls[i] = url;
      // Reload only if this is the slide currently on screen
      if (i == _index) _initVideo(i);
    }
  }

  Future<void> _initVideo(int index) async {
    final ctrl = VideoPlayerController.networkUrl(
      Uri.parse(_videoUrls[index]),
    );
    await ctrl.initialize();
    if (!mounted) {
      ctrl.dispose();
      return;
    }
    ctrl.setLooping(true);
    ctrl.setVolume(0);
    ctrl.play();
    setState(() {
      _currentCtrl?.dispose();
      _currentCtrl = ctrl;
      _videoReady = true;
    });
  }

  Future<void> _preloadAndSwitch(int nextIndex) async {
    if (_isSwitching) return;
    _isSwitching = true;

    final next = VideoPlayerController.networkUrl(
      Uri.parse(_videoUrls[nextIndex]),
    );
    await next.initialize();
    if (!mounted) {
      next.dispose();
      _isSwitching = false;
      return;
    }
    next.setLooping(true);
    next.setVolume(0);

    setState(() {
      _nextCtrl?.dispose();
      _nextCtrl = next;
    });

    next.play();

    setState(() => _videoReady = false);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) {
      _isSwitching = false;
      return;
    }

    setState(() {
      _currentCtrl?.dispose();
      _currentCtrl = next;
      _nextCtrl = null;
      _videoReady = true;
    });
    _isSwitching = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _currentCtrl?.dispose();
    _nextCtrl?.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _configs.length - 1;

  void _finish() =>
      context.read<OnboardingBloc>().add(const OnboardingCompleted());

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onPageChanged(int v) {
    setState(() => _index = v);
    _preloadAndSwitch(v);
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
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Video background ──────────────────────────────────────────
            AnimatedOpacity(
              opacity: _videoReady ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _videoReady && _currentCtrl != null
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _currentCtrl!.value.size.width,
                        height: _currentCtrl!.value.size.height,
                        child: VideoPlayer(_currentCtrl!),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            if (!_videoReady) Container(color: const Color(0xFF0D0A1E)),

            // ── Gradient overlay ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x44000000),
                    Color(0x11000000),
                    Color(0xEE000000),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_index + 1) / _configs.length,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFF5B400)),
                        minHeight: 3,
                      ),
                    ),
                  ),

                  // Slide text
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _configs.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, i) => _SlideContent(
                        title: _configs[i].title,
                        subtitle: _configs[i].subtitle,
                      ),
                    ),
                  ),

                  // Navigation row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Row(
                      children: [
                        // Dots
                        Row(
                          children: List.generate(
                            _configs.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 6),
                              height: 6,
                              width: i == _index ? 22 : 6,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _next,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Text(
                              _isLast ? 'Get Started' : 'Next →',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
}

class _SlideContent extends StatelessWidget {
  final String title, subtitle;
  const _SlideContent({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
        ],
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
