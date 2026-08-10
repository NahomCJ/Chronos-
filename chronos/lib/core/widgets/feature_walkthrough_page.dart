import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/pexels_service.dart';

const _pageBg = Color(0xFFF7F8FA);
const _dotInactive = Color(0xFFDADEE6);
const _titleColor = Color(0xFF1A1A2E);
const _subtitleColor = Color(0xFF6B7080);

/// Config for a single walkthrough slide. [accentColor] is rendered flat
/// (no gradient/animation) on the icon badge, dots and CTA for that slide.
class WalkthroughSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String pexelsQuery;
  final String fallbackVideoUrl;

  const WalkthroughSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.pexelsQuery,
    required this.fallbackVideoUrl,
  });
}

/// Reusable light-themed, skippable, swipeable video walkthrough.
/// White page background, video clip inside a rounded card, static-color
/// icon badge per slide, and a rounded pill CTA. Used by the main app
/// onboarding as well as the TickPay and LifeX first-time walkthroughs.
class FeatureWalkthroughPage extends StatefulWidget {
  final List<WalkthroughSlide> slides;
  final VoidCallback onSkip;
  final VoidCallback onFinish;
  final String finishLabel;

  const FeatureWalkthroughPage({
    super.key,
    required this.slides,
    required this.onSkip,
    required this.onFinish,
    this.finishLabel = 'Get Started',
  });

  @override
  State<FeatureWalkthroughPage> createState() =>
      _FeatureWalkthroughPageState();
}

class _FeatureWalkthroughPageState extends State<FeatureWalkthroughPage> {
  late final PageController _controller;
  late final List<String> _videoUrls;
  VideoPlayerController? _currentCtrl;

  int _index = 0;
  bool _videoReady = false;
  int _loadingForIndex = -1;

  @override
  void initState() {
    super.initState();
    _videoUrls = widget.slides.map((s) => s.fallbackVideoUrl).toList();
    _controller = PageController();
    _loadVideo(0);
    _fetchPexelsVideos();
  }

  /// Background: replace each fallback with a fresh portrait video from Pexels.
  Future<void> _fetchPexelsVideos() async {
    for (int i = 0; i < widget.slides.length; i++) {
      final videos = await PexelsService.searchVideos(
        widget.slides[i].pexelsQuery,
        perPage: 5,
        orientation: 'portrait',
      );
      if (!mounted || videos.isEmpty) continue;

      final url = videos
          .map((v) => v.portraitHdUrl)
          .firstWhere((u) => u != null, orElse: () => null);

      if (url == null || !mounted) continue;
      _videoUrls[i] = url;
      if (i == _index) _loadVideo(i);
    }
  }

  /// Load video for [index]. Newer calls cancel older in-flight loads.
  Future<void> _loadVideo(int index) async {
    _loadingForIndex = index;

    VideoPlayerController? ctrl;
    try {
      ctrl = VideoPlayerController.networkUrl(Uri.parse(_videoUrls[index]));
      await ctrl.initialize();
    } catch (_) {
      ctrl?.dispose();
      return;
    }

    if (!mounted || _loadingForIndex != index) {
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

  @override
  void dispose() {
    _controller.dispose();
    _currentCtrl?.dispose();
    super.dispose();
  }

  bool get _isLast => _index == widget.slides.length - 1;

  void _next() {
    if (_isLast) {
      widget.onFinish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onPageChanged(int v) {
    setState(() {
      _index = v;
      _videoReady = false;
    });
    _loadVideo(v);
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slides[_index];
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        value: (_index + 1) / widget.slides.length,
                        backgroundColor: _dotInactive,
                        valueColor: AlwaysStoppedAnimation(slide.accentColor),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onSkip,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: _subtitleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.slides.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, i) => _SlideBody(
                  slide: widget.slides[i],
                  videoCtrl: i == _index && _videoReady ? _currentCtrl : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: i == _index ? 22 : 6,
                        decoration: BoxDecoration(
                          color: i == _index ? slide.accentColor : _dotInactive,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: slide.accentColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: slide.accentColor.withValues(alpha: 0.32),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        _isLast ? widget.finishLabel : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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
    );
  }
}

class _SlideBody extends StatelessWidget {
  final WalkthroughSlide slide;
  final VideoPlayerController? videoCtrl;
  const _SlideBody({required this.slide, required this.videoCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: slide.accentColor.withValues(alpha: 0.08)),
                  AnimatedOpacity(
                    opacity: videoCtrl != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 350),
                    child: videoCtrl != null
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: videoCtrl!.value.size.width,
                              height: videoCtrl!.value.size.height,
                              child: VideoPlayer(videoCtrl!),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (videoCtrl == null)
                    Center(
                      child: Icon(
                        slide.icon,
                        size: 64,
                        color: slide.accentColor.withValues(alpha: 0.35),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(slide.icon, color: slide.accentColor, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: const TextStyle(
                    color: _titleColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.subtitle,
                  style: const TextStyle(
                    color: _subtitleColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
