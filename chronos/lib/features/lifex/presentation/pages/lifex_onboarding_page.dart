import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXOnboardingPage extends StatefulWidget {
  const LifeXOnboardingPage({super.key});

  @override
  State<LifeXOnboardingPage> createState() => _LifeXOnboardingPageState();
}

class _LifeXOnboardingPageState extends State<LifeXOnboardingPage>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _current = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _slides = [
    _Slide(
      tag: 'WELCOME',
      title: 'Live Your\nBest Life',
      subtitle:
          'LifeX is your personal life operating system — combining AI, data, and human wisdom to help you thrive in every dimension.',
      imageUrl:
          'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=900',
      color: Color(0xFF0F766E),
      features: [
        '11 life dimensions tracked in one app',
        'AI-powered insights from Chris',
        'Real progress, not just motivation',
      ],
      icon: Icons.spa_rounded,
    ),
    _Slide(
      tag: 'HEALTH & ACTIVITY',
      title: 'Move Better,\nFeel Better',
      subtitle:
          'Track your fitness, nutrition, sleep and vitals. LifeX learns from your banking data and habits to build a full picture of your wellbeing.',
      imageUrl:
          'https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=900',
      color: Color(0xFF14B8A6),
      features: [
        'Activity streaks & step tracking',
        'Health metrics from wearables',
        'Spending on health insights',
      ],
      icon: Icons.favorite_rounded,
    ),
    _Slide(
      tag: 'MIND & SPIRIT',
      title: 'Inner Peace\nOuter Strength',
      subtitle:
          'Guided meditations, daily reflections, and spiritual practices tailored to your beliefs. A quiet mind leads to better decisions in every area of life.',
      imageUrl:
          'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=900',
      color: Color(0xFF8B5CF6),
      features: [
        'Daily meditation & mindfulness',
        'Gratitude journaling prompts',
        'Spiritual growth milestones',
      ],
      icon: Icons.self_improvement_rounded,
    ),
    _Slide(
      tag: 'LEARNING & GROWTH',
      title: 'Knowledge\nIs Power',
      subtitle:
          'Curated learning paths, book summaries, skill tracking and educational spending analysis. Stay curious — every day is a chance to grow.',
      imageUrl:
          'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=900',
      color: Color(0xFF6366F1),
      features: [
        'Daily learning streaks',
        'Recommended resources by Chris',
        'Skill level progress tracking',
      ],
      icon: Icons.school_rounded,
    ),
    _Slide(
      tag: 'VISION & WEALTH',
      title: 'Build the Life\nYou Imagine',
      subtitle:
          'Set bold goals, track financial milestones, and visualise your future. Chris analyses your Chronos transactions to surface opportunities you might miss.',
      imageUrl:
          'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=900',
      color: Color(0xFF3B82F6),
      features: [
        'Goal boards & milestone tracking',
        'Financial health score',
        'AI-powered life planning',
      ],
      icon: Icons.remove_red_eye_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _fadeCtrl.reset();
      _pageCtrl
          .nextPage(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut)
          .then((_) => _fadeCtrl.forward());
    } else {
      context.go(RouteConstants.lifex.toPath);
    }
  }

  void _skip() => context.go(RouteConstants.lifex.toPath);

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) {
              _fadeCtrl.reset();
              setState(() => _current = i);
              _fadeCtrl.forward();
            },
            itemCount: _slides.length,
            itemBuilder: (_, i) => _buildSlide(_slides[i]),
          ),
          // Bottom overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _buildBottom(slide),
            ),
          ),
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: _skip,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25), width: 1),
                ),
                child: Text('Skip',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(_Slide slide) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: slide.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: slide.color.withValues(alpha: 0.2)),
          errorWidget: (_, __, ___) =>
              Container(color: slide.color.withValues(alpha: 0.2)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.45, 1],
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.4),
                Colors.black.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottom(_Slide slide) {
    final isLast = _current == _slides.length - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, MediaQuery.of(context).padding.bottom + 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tag
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: slide.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: slide.color.withValues(alpha: 0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(slide.icon, color: slide.color, size: 12),
                const SizedBox(width: 5),
                Text(slide.tag,
                    style: TextStyle(
                        color: slide.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Title
          Text(slide.title,
              style: TextStyles.displaySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 36,
                height: 1.1,
              )),
          const SizedBox(height: 12),
          // Subtitle
          Text(slide.subtitle,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 14,
                  height: 1.55)),
          const SizedBox(height: 20),
          // Feature bullets
          ...slide.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: slide.color.withValues(alpha: 0.15),
                      ),
                      child: Icon(Icons.check_rounded,
                          color: slide.color, size: 11),
                    ),
                    const SizedBox(width: 10),
                    Text(f,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13)),
                  ],
                ),
              )),
          const SizedBox(height: 28),
          Row(
            children: [
              // Dots
              Row(
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    width: i == _current ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _current
                          ? slide.color
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Next / Start button
              GestureDetector(
                onTap: _next,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: slide.color,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: slide.color.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isLast ? 'Get Started' : 'Next',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Icon(
                          isLast
                              ? Icons.rocket_launch_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String tag;
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color color;
  final List<String> features;
  final IconData icon;

  const _Slide({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.color,
    required this.features,
    required this.icon,
  });
}
