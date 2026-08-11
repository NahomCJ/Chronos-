import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/pexels_service.dart';

/// Config for a single walkthrough slide. Video fills the entire screen —
/// [accentColor] only tints the progress bar, tag chips and CTA pill.
class WalkthroughSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<String> tags;
  final String pexelsQuery;
  final String fallbackVideoUrl;

  const WalkthroughSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.pexelsQuery,
    required this.fallbackVideoUrl,
    this.tags = const [],
  });
}

/// Full-bleed, edge-to-edge video walkthrough — no card, no white page
/// background. The video fills the whole screen behind status bar and all;
/// controls are small icon buttons anchored to the four corners (logo +
/// skip up top, mute toggle + CTA pill down low) so the footage stays the
/// focal point. Title/subtitle/tags sit directly on the video over a
/// bottom scrim. Used by the main app onboarding as well as the TickPay,
/// BlockHub and LifeX first-time walkthroughs.
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
  bool _muted = true;
  int _loadingForIndex = -1;

  @override
  void initState() {
    super.initState();
    _videoUrls = widget.slides.map((s) => s.fallbackVideoUrl).toList();
    _controller = PageController();
    // video_player throws MEDIA_ERR_SRC_NOT_SUPPORTED in Chrome — stay on
    // the gradient/icon placeholder there instead of attempting playback.
    if (!kIsWeb) {
      _loadVideo(0);
      _fetchPexelsVideos();
    }
  }

  /// Background: replace each fallback with a fresh portrait video from
  /// Pexels, picking the best candidate rather than just the first hit.
  Future<void> _fetchPexelsVideos() async {
    for (int i = 0; i < widget.slides.length; i++) {
      final videos = await PexelsService.searchVideos(
        widget.slides[i].pexelsQuery,
        perPage: 15,
        orientation: 'portrait',
      );
      if (!mounted || videos.isEmpty) continue;

      final url = _bestPortraitUrl(videos);
      if (url == null || !mounted) continue;
      _videoUrls[i] = url;
      if (i == _index) _loadVideo(i);
    }
  }

  /// Prefer a clean HD portrait clip with a loop-friendly duration (4-25s —
  /// long enough not to feel like a jump-cut, short enough to loop
  /// unnoticed) over whatever Pexels happened to rank first.
  String? _bestPortraitUrl(List<PexelsVideo> videos) {
    final candidates =
        videos.where((v) => v.portraitHdUrl != null).toList(growable: false);
    if (candidates.isEmpty) return null;
    final sorted = [...candidates]
      ..sort((a, b) {
        int score(PexelsVideo v) =>
            (v.duration >= 4 && v.duration <= 25) ? 1 : 0;
        final byLoopability = score(b) - score(a);
        if (byLoopability != 0) return byLoopability;
        return b.duration.compareTo(a.duration);
      });
    return sorted.first.portraitHdUrl;
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
    ctrl.setVolume(_muted ? 0 : 1);
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
    if (!kIsWeb) _loadVideo(v);
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _currentCtrl?.setVolume(_muted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slides[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, i) => _SlideVisual(
              slide: widget.slides[i],
              videoCtrl: i == _index && _videoReady ? _currentCtrl : null,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Column(
                children: [
                  _ProgressBars(
                    count: widget.slides.length,
                    index: _index,
                    color: slide.accentColor,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _LogoBadge(),
                      _GlassIconButton(
                        icon: Icons.close_rounded,
                        onTap: widget.onSkip,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _GlassIconButton(
                        icon: _muted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        onTap: _toggleMute,
                      ),
                      const Spacer(),
                      _NextPill(
                        label: _isLast ? widget.finishLabel : 'Next',
                        color: slide.accentColor,
                        onTap: _next,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideVisual extends StatelessWidget {
  final WalkthroughSlide slide;
  final VideoPlayerController? videoCtrl;
  const _SlideVisual({required this.slide, required this.videoCtrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.2,
              colors: [
                slide.accentColor.withValues(alpha: 0.45),
                const Color(0xFF08080F),
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: videoCtrl != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
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
              size: 72,
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ),
        // Scrim so the corner icon buttons stay legible over bright video.
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 170,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99000000), Colors.transparent],
              ),
            ),
          ),
        ),
        // Scrim so title/subtitle/tags and the bottom controls stay legible.
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.5,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xE6000000), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 118,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (slide.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        slide.tags.map((t) => _TagChip(label: t)).toList(),
                  ),
                ),
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.14,
                  letterSpacing: -0.4,
                  shadows: [
                    Shadow(
                        color: Colors.black54,
                        blurRadius: 16,
                        offset: Offset(0, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                slide.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 15,
                  height: 1.5,
                  shadows: const [
                    Shadow(
                        color: Colors.black54,
                        blurRadius: 12,
                        offset: Offset(0, 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressBars extends StatelessWidget {
  final int count;
  final int index;
  final Color color;
  const _ProgressBars(
      {required this.count, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (i) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
            height: 3.5,
            decoration: BoxDecoration(
              color: i <= index ? color : Colors.white.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.28), width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Small translucent circular icon button, anchored to a screen corner —
/// keeps controls out of the way of the video.
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.32),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.22), width: 0.8),
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Image.asset(
        'assets/Chronoslogo-icon-black.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _NextPill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NextPill(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 17),
          ],
        ),
      ),
    );
  }
}
