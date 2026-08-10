import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';
import 'lifex_walkthrough_page.dart';

class LifeXPage extends StatefulWidget {
  const LifeXPage({super.key});

  @override
  State<LifeXPage> createState() => _LifeXPageState();
}

class _LifeXPageState extends State<LifeXPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  static const _bg = Color(0xFF0D0D22);
  static const _teal = Color(0xFF0F766E);
  static const _tealLight = Color(0xFF14B8A6);

  // Primary 7 — shown on the ring around the avatar.
  static const _modules = [
    _Module('Financial', Icons.account_balance_wallet_rounded),
    _Module('Health', Icons.monitor_heart_rounded),
    _Module('Social', Icons.people_rounded),
    _Module('Educational', Icons.menu_book_rounded),
    _Module('Relationship', Icons.handshake_rounded),
    _Module('Vision', Icons.rocket_launch_rounded),
    _Module('Spiritual', Icons.spa_rounded),
  ];

  // Remaining 5 — the ring is tuned for 7 evenly-spaced orbs; cramming 12
  // in would collide/overflow on small screens, so these get their own
  // grid below instead.
  static const _moreModules = [
    _Module('Activity', Icons.directions_run_rounded),
    _Module('Family', Icons.diversity_3_rounded),
    _Module('Feed', Icons.dynamic_feed_rounded),
    _Module('AI Insights', Icons.auto_awesome_rounded),
    _Module('Export', Icons.ios_share_rounded),
  ];

  bool _hasCheckedWalkthrough = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _checkWalkthroughStatus();
  }

  Future<void> _checkWalkthroughStatus() async {
    if (_hasCheckedWalkthrough) return;
    _hasCheckedWalkthrough = true;

    final prefs = await SharedPreferences.getInstance();
    final hasSeenWalkthrough =
        prefs.getBool('lifex_walkthrough_seen') ?? false;
    if (hasSeenWalkthrough || !mounted) return;

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => LifexWalkthroughPage(
          onDone: () async {
            await prefs.setBool('lifex_walkthrough_seen', true);
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onModuleTap(_Module module) {
    switch (module.title) {
      case 'Financial':
        context.push(RouteConstants.lifexFinance.toPath);
        break;
      case 'Health':
        context.push(RouteConstants.lifexHealth.toPath);
        break;
      case 'Social':
        context.push(RouteConstants.lifexSocial.toPath);
        break;
      case 'Educational':
        context.push(RouteConstants.lifexEducation.toPath);
        break;
      case 'Relationship':
        context.push(RouteConstants.lifexRelationship.toPath);
        break;
      case 'Vision':
        context.push(RouteConstants.lifexVision.toPath);
        break;
      case 'Spiritual':
        context.push(RouteConstants.lifexSpiritual.toPath);
        break;
      case 'Activity':
        context.push(RouteConstants.lifexActivity.toPath);
        break;
      case 'Family':
        context.push(RouteConstants.lifexFamily.toPath);
        break;
      case 'Feed':
        context.push(RouteConstants.lifexFeed.toPath);
        break;
      case 'AI Insights':
        context.push(RouteConstants.lifexAiInsights.toPath);
        break;
      case 'Export':
        context.push(RouteConstants.lifexExport.toPath);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(child: _buildRingSection(context)),
          SliverToBoxAdapter(child: _buildLifeScore()),
          SliverToBoxAdapter(child: _buildMoreModules()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 200 + topPadding,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=800',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF111130)),
            errorWidget: (_, __, ___) =>
                Container(color: const Color(0xFF111130)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  _bg,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // LifeX Active pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _teal.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _tealLight.withValues(alpha: 0.5),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) => Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _tealLight.withValues(
                                      alpha: 0.5 + _pulseCtrl.value * 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('LifeX Active',
                                style: TextStyle(
                                    color: _tealLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Retake survey button — Chris FAB styled
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.40),
                              width: 1.2),
                        ),
                        child: ChrisHomeFab(
                          size: 46,
                          onTap: () => context.push(RouteConstants.lifexOnboarding.toPath),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Your LifeX',
                    style: TextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Twelve domains. One life.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ring Section ─────────────────────────────────────────────────────────────

  Widget _buildRingSection(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final ringR = (w * 0.34).clamp(110.0, 148.0);
        final orbR = 34.0;
        final centerSize = 90.0;
        final sectionH = ringR * 2 + orbR * 2 + 40;

        return SizedBox(
          height: sectionH,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative outer ring arc
              _RingDecoration(radius: ringR + orbR + 6, pulse: _pulseCtrl),

              // User avatar in center
              _buildUserCenter(centerSize),

              // 7 domain orbs
              ...List.generate(_modules.length, (i) {
                final angle = -pi / 2 + (2 * pi * i / _modules.length);
                final dx = cos(angle) * ringR;
                final dy = sin(angle) * ringR;
                final m = _modules[i];
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: _DomainOrb(
                    module: m,
                    onTap: () => _onModuleTap(m),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCenter(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Decorative ring — purely aesthetic, not tied to any score.
        SizedBox(
          width: size + 16,
          height: size + 16,
          child: CircularProgressIndicator(
            value: 1,
            strokeWidth: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
                _tealLight.withValues(alpha: 0.35)),
            strokeCap: StrokeCap.round,
          ),
        ),
        // Avatar circle
        ClipOval(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _teal.withValues(alpha: 0.6),
                  const Color(0xFF0D0D2B),
                ],
              ),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white70, size: 32),
          ),
        ),
      ],
    );
  }

  // ── Life Score card ───────────────────────────────────────────────────────────

  // No score, no grade — just a warm entry point into each domain. Tapping
  // a chip navigates straight to that page, same as tapping its orb above.
  Widget _buildLifeScore() {
    const highlighted = ['Financial', 'Health', 'Vision', 'Spiritual'];
    final chips = _modules.where((m) => highlighted.contains(m.title));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _teal.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _teal.withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _tealLight.withValues(alpha: 0.15),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          color: _tealLight, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your LifeX Journey',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text(
                            'Explore each part of your life at your own pace.',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final m in chips) ...[
                      _domainChip(m),
                      if (m.title != highlighted.last) const SizedBox(width: 6),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── More in LifeX ─────────────────────────────────────────────────────────────

  Widget _buildMoreModules() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('More in LifeX',
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: _moreModules.map((m) => _MoreModuleTile(
                  module: m,
                  onTap: () => _onModuleTap(m),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _domainChip(_Module module) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onModuleTap(module),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(module.icon, color: Colors.white70, size: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(module.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ── Ring decoration ───────────────────────────────────────────────────────────

class _RingDecoration extends StatelessWidget {
  final double radius;
  final Animation<double> pulse;
  const _RingDecoration({required this.radius, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CustomPaint(
          painter: _DashedRingPainter(
            alpha: 0.08 + pulse.value * 0.05,
          ),
        ),
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  final double alpha;
  const _DashedRingPainter({required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.alpha != alpha;
}

// ── Domain Orb ────────────────────────────────────────────────────────────────

class _DomainOrb extends StatelessWidget {
  final _Module module;
  final VoidCallback onTap;

  const _DomainOrb({
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const orbSize = 64.0;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Decorative ring — no score, no fill implying "incomplete".
              SizedBox(
                width: orbSize,
                height: orbSize,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 3.5,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.22)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Container(
                width: orbSize - 10,
                height: orbSize - 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18), width: 1),
                ),
                child: Center(
                  child: Icon(module.icon, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            module.title,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 9,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MoreModuleTile extends StatelessWidget {
  final _Module module;
  final VoidCallback onTap;
  const _MoreModuleTile({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
              child: Icon(module.icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(module.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _Module {
  final String title;
  final IconData icon;
  const _Module(this.title, this.icon);
}
