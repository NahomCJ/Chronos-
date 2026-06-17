import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

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

  static const _modules = [
    _Module('Financial', Icons.account_balance_wallet_rounded, Color(0xFF10B981),
        'Wealth, budgets & debt',
        'https://images.pexels.com/photos/730547/pexels-photo-730547.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Health', Icons.monitor_heart_rounded, Color(0xFF14B8A6),
        'Fitness, vitals & wellness',
        'https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Social', Icons.people_rounded, Color(0xFFEF4444),
        'Groups, events & planning',
        'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Educational', Icons.menu_book_rounded, Color(0xFF6366F1),
        'Loans, learning & growth',
        'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Relationship', Icons.handshake_rounded, Color(0xFFEC4899),
        'Couples, family & bonds',
        'https://images.pexels.com/photos/1128318/pexels-photo-1128318.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Vision', Icons.rocket_launch_rounded, Color(0xFF3B82F6),
        'Goals, milestones & future',
        'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Spiritual', Icons.spa_rounded, Color(0xFF8B5CF6),
        'Values, purpose & routine',
        'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ];

  static const _domainScores = [0.79, 0.84, 0.60, 0.70, 0.64, 0.50, 0.50];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
    }
  }

  double get _overallScore {
    final sum = _domainScores.fold<double>(0, (a, b) => a + b);
    return sum / _domainScores.length;
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
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 200,
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
                      // Retake survey button
                      GestureDetector(
                        onTap: () => context
                            .push(RouteConstants.lifexOnboarding.toPath),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1),
                          ),
                          child: const Icon(Icons.mic_rounded,
                              color: Colors.white, size: 16),
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
                    'Seven domains. One life.',
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
                final score = _domainScores[i];
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: _DomainOrb(
                    module: m,
                    score: score,
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
    final overall = (_overallScore * 100).round();
    return Stack(
      alignment: Alignment.center,
      children: [
        // Score ring
        SizedBox(
          width: size + 16,
          height: size + 16,
          child: CircularProgressIndicator(
            value: _overallScore,
            strokeWidth: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation<Color>(_tealLight),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_rounded, color: Colors.white70, size: 28),
                const SizedBox(height: 2),
                Text('$overall%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Life Score card ───────────────────────────────────────────────────────────

  Widget _buildLifeScore() {
    final overall = (_overallScore * 100).round();
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
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: CircularProgressIndicator(
                            value: _overallScore,
                            strokeWidth: 6,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                _tealLight),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$overall',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            Text('%',
                                style: TextStyle(
                                    color: _tealLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Life Score',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            'Solid foundation. Vision & Spiritual\nneed some attention this week.',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
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
                    _scoreTag(Icons.trending_up_rounded, 'Financial',
                        '${(_domainScores[0] * 100).round()}%',
                        const Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    _scoreTag(Icons.favorite_rounded, 'Health',
                        '${(_domainScores[1] * 100).round()}%',
                        const Color(0xFF14B8A6)),
                    const SizedBox(width: 6),
                    _scoreTag(Icons.remove_red_eye_rounded, 'Vision',
                        '${(_domainScores[5] * 100).round()}%',
                        const Color(0xFF3B82F6)),
                    const SizedBox(width: 6),
                    _scoreTag(Icons.self_improvement_rounded, 'Spiritual',
                        '${(_domainScores[6] * 100).round()}%',
                        const Color(0xFF8B5CF6)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreTag(IconData icon, String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 10),
            const SizedBox(width: 4),
            Text(val,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
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
  final double score;
  final VoidCallback onTap;

  const _DomainOrb({
    required this.module,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const orbSize = 64.0;
    final pct = (score * 100).round();
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: orbSize,
                height: orbSize,
                child: CircularProgressIndicator(
                  value: score,
                  strokeWidth: 3.5,
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.45)),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(module.icon, color: Colors.white, size: 15),
                    const SizedBox(height: 1),
                    Text('$pct%',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ],
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

// ── Data classes ──────────────────────────────────────────────────────────────

class _Module {
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;
  final String imageUrl;
  const _Module(this.title, this.icon, this.color, this.subtitle, this.imageUrl);
}
