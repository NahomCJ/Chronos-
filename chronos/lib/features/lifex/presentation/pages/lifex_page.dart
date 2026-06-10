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

  static const _bg = Color(0xFF08080F);
  static const _card = Color(0xFF0F0F1C);
  static const _teal = Color(0xFF0F766E);
  static const _tealLight = Color(0xFF14B8A6);

  static const _modules = [
    _Module('Health', Icons.favorite_rounded, Color(0xFF14B8A6),
        'Track vitals & wellness',
        'https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Education', Icons.school_rounded, Color(0xFF6366F1),
        'Learn & grow daily',
        'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Spiritual', Icons.self_improvement_rounded, Color(0xFF8B5CF6),
        'Mind, body & spirit',
        'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Finance', Icons.trending_up_rounded, Color(0xFF10B981),
        'Wealth & money goals',
        'https://images.pexels.com/photos/730547/pexels-photo-730547.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Activity', Icons.directions_run_rounded, Color(0xFFF59E0B),
        'Fitness & movement',
        'https://images.pexels.com/photos/863988/pexels-photo-863988.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Vision', Icons.remove_red_eye_rounded, Color(0xFF3B82F6),
        'Goals & milestones',
        'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Family', Icons.people_rounded, Color(0xFFEC4899),
        'Relationships & bonds',
        'https://images.pexels.com/photos/1128318/pexels-photo-1128318.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Social', Icons.public_rounded, Color(0xFFEF4444),
        'Community & impact',
        'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('AI Insights', Icons.auto_awesome_rounded, Color(0xFF06B6D4),
        'Personalised guidance',
        'https://images.pexels.com/photos/8439093/pexels-photo-8439093.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Social Feed', Icons.feed_rounded, Color(0xFFF97316),
        'Lifestyle & stories',
        'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Module('Export', Icons.download_rounded, Color(0xFF84CC16),
        'Reports & data export',
        'https://images.pexels.com/photos/669619/pexels-photo-669619.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ];

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
      case 'Health':
        context.push(RouteConstants.lifexHealth.toPath);
        break;
      case 'Education':
        context.push(RouteConstants.lifexEducation.toPath);
        break;
      case 'Spiritual':
        context.push(RouteConstants.lifexSpiritual.toPath);
        break;
      case 'Finance':
        context.push(RouteConstants.lifexFinance.toPath);
        break;
      case 'Activity':
        context.push(RouteConstants.lifexActivity.toPath);
        break;
      case 'Vision':
        context.push(RouteConstants.lifexVision.toPath);
        break;
      case 'Family':
        context.push(RouteConstants.lifexFamily.toPath);
        break;
      case 'Social':
        context.push(RouteConstants.lifexSocial.toPath);
        break;
      case 'Social Feed':
        context.push(RouteConstants.lifexFeed.toPath);
        break;
      case 'AI Insights':
        context.push(RouteConstants.lifexAiInsights.toPath);
        break;
      case 'Export':
        context.push(RouteConstants.lifexExport.toPath);
        break;
      default:
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
          SliverToBoxAdapter(child: _buildLifeScore()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Row(
                children: [
                  Text('Your Life Modules',
                      style: TextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      )),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        context.push(RouteConstants.lifexOnboarding.toPath),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _teal.withValues(alpha: 0.4), width: 1),
                      ),
                      child: Text('Tour',
                          style: TextStyle(
                              color: _tealLight, fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _ModuleCard(
                  module: _modules[i],
                  onTap: () => _onModuleTap(_modules[i]),
                ),
                childCount: _modules.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 280,
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
                  Colors.black.withValues(alpha: 0.35),
                  _bg.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                      GestureDetector(
                        onTap: () =>
                            context.push(RouteConstants.lifexOnboarding.toPath),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1),
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text('Your LifeX',
                      style: TextStyles.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        height: 1.1,
                      )),
                  const SizedBox(height: 6),
                  Text(
                      'Everything that makes you — health, mind,\nwealth and soul — in one place.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13.5,
                        height: 1.5,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeScore() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
              border: Border.all(
                  color: _teal.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: 0.74,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_tealLight),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('74',
                            style: TextStyle(
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
                      Text('Life Score',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                          'You\'re doing great. Spiritual & Vision\nneed a little attention this week.',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 12,
                              height: 1.5)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _scoreTag(Icons.favorite_rounded, '84%',
                              const Color(0xFF14B8A6)),
                          const SizedBox(width: 8),
                          _scoreTag(Icons.self_improvement_rounded, '61%',
                              const Color(0xFF8B5CF6)),
                          const SizedBox(width: 8),
                          _scoreTag(Icons.trending_up_rounded, '79%',
                              const Color(0xFF10B981)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreTag(IconData icon, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Module card ───────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final _Module module;
  final VoidCallback onTap;

  const _ModuleCard({required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: module.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: module.color.withValues(alpha: 0.2)),
              errorWidget: (_, __, ___) =>
                  Container(color: module.color.withValues(alpha: 0.2)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    module.color.withValues(alpha: 0.15),
                    const Color(0xFF08080F).withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: module.color.withValues(alpha: 0.2),
                      border: Border.all(
                          color: module.color.withValues(alpha: 0.5),
                          width: 1),
                    ),
                    child: Icon(module.icon, color: module.color, size: 18),
                  ),
                  const Spacer(),
                  Text(module.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(module.subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                          height: 1.3)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: module.color.withValues(alpha: 0.35),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: 0.7,
                          heightFactor: 1,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: module.color,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: module.color, size: 12),
                    ],
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

class _Module {
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;
  final String imageUrl;

  const _Module(
      this.title, this.icon, this.color, this.subtitle, this.imageUrl);
}
