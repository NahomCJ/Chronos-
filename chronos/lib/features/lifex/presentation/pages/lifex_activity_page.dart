import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXActivityPage extends StatefulWidget {
  const LifeXActivityPage({super.key});

  @override
  State<LifeXActivityPage> createState() => _LifeXActivityPageState();
}

class _LifeXActivityPageState extends State<LifeXActivityPage> {
  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _amber = Color(0xFFF59E0B);
  static const _amberLight = Color(0xFFFBBF24);

  static const _activities = [
    _ActivityLog('Morning Run', '5.4 km', '34 min', '385 kcal', Icons.directions_run_rounded, Color(0xFF14B8A6)),
    _ActivityLog('Weight Training', '45 min', '3 sets', '280 kcal', Icons.fitness_center_rounded, Color(0xFFEF4444)),
    _ActivityLog('Cycling', '12 km', '38 min', '310 kcal', Icons.directions_bike_rounded, Color(0xFF6366F1)),
    _ActivityLog('Yoga Flow', '30 min', 'Flexibility', '140 kcal', Icons.self_improvement_rounded, Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: const ChrisHomeFab(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
            child: _buildTodayRings(),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Weekly Summary'),
              const SizedBox(height: 14),
              _buildWeeklyBars(),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _sectionTitle('Recent Activity'),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text('Log Activity', style: TextStyle(color: _amber, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 14),
              ..._activities.map((a) => _ActivityCard(activity: a)),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Workout Videos'),
              const SizedBox(height: 14),
              _VideoCard('30-Day HIIT Challenge', '28 min', 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600', _amber),
              const SizedBox(height: 14),
              _VideoCard('Beginner Strength Training', '35 min', 'https://images.pexels.com/photos/3837757/pexels-photo-3837757.jpeg?auto=compress&cs=tinysrgb&w=600', const Color(0xFFEF4444)),
              const SizedBox(height: 14),
              _VideoCard('Evening Yoga & Stretch', '20 min', 'https://images.pexels.com/photos/2294354/pexels-photo-2294354.jpeg?auto=compress&cs=tinysrgb&w=600', const Color(0xFF8B5CF6)),
            ]),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(fit: StackFit.expand, children: [
        CachedNetworkImage(
          imageUrl: 'https://images.pexels.com/photos/863988/pexels-photo-863988.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: _amber.withValues(alpha: 0.15)),
          errorWidget: (_, __, ___) => Container(color: _amber.withValues(alpha: 0.15)),
        ),
        Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.2), _bg.withValues(alpha: 0.97)],
        ))),
        SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF3F4F6),
                  border: Border.all(color: _border, width: 1)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF374151), size: 16),
            ),
          ),
        )),
        Positioned(bottom: 24, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _tag(Icons.directions_run_rounded, 'ACTIVITY & FITNESS', _amber),
          const SizedBox(height: 10),
          Text('Stay in\nMotion', style: TextStyles.displaySmall.copyWith(color: _textPrimary, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
        ])),
      ]),
    );
  }

  Widget _tag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12), const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      ]),
    );
  }

  Widget _buildTodayRings() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _amber.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 90, height: 90,
            child: CircularProgressIndicator(value: 0.74, strokeWidth: 8,
                backgroundColor: const Color(0xFFE8EAF0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                strokeCap: StrokeCap.round)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('74%', style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
            Text('goal', style: TextStyle(color: _textSecondary, fontSize: 10)),
          ]),
        ]),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today\'s Goal', style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _activityStat(Icons.directions_walk_rounded, '7,430', '/ 10,000 steps', _amber),
          const SizedBox(height: 6),
          _activityStat(Icons.local_fire_department_rounded, '742', '/ 600 kcal burned', const Color(0xFFEF4444)),
          const SizedBox(height: 6),
          _activityStat(Icons.timer_rounded, '48', '/ 60 min active', const Color(0xFF14B8A6)),
        ])),
      ]),
    );
  }

  Widget _activityStat(IconData icon, String val, String label, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 13),
      const SizedBox(width: 6),
      Text(val, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      Text(label, style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 11)),
    ]);
  }

  Widget _buildWeeklyBars() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const values = [0.6, 0.85, 0.4, 0.9, 0.74, 1.0, 0.3];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i) {
        final isToday = i == 4;
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200 + i * 80),
              height: 70 * values[i],
              decoration: BoxDecoration(
                color: isToday ? _amber : _amber.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Text(days[i], style: TextStyle(color: isToday ? _amber : const Color(0xFF9CA3AF), fontSize: 11, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
          ]),
        ));
      })),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w700));
}

class _ActivityLog {
  final String name;
  final String metric1;
  final String metric2;
  final String calories;
  final IconData icon;
  final Color color;
  const _ActivityLog(this.name, this.metric1, this.metric2, this.calories, this.icon, this.color);
}

class _ActivityCard extends StatelessWidget {
  final _ActivityLog activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: activity.color.withValues(alpha: 0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: activity.color.withValues(alpha: 0.12)),
            child: Icon(activity.icon, color: activity.color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(activity.name, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Text(activity.metric1, style: TextStyle(color: activity.color, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('  ·  ${activity.metric2}  ·  ${activity.calories}', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
          ]),
        ])),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 20),
      ]),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String imageUrl;
  final Color accentColor;
  const _VideoCard(this.title, this.duration, this.imageUrl, this.accentColor);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 155,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(fit: StackFit.expand, children: [
            CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFFE8EAF0)),
                errorWidget: (_, __, ___) => Container(color: const Color(0xFFE8EAF0))),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)]))),
            Center(child: Container(width: 46, height: 46,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withValues(alpha: 0.25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5)),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24))),
            Positioned(bottom: 12, left: 14, right: 14, child: Row(children: [
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700))),
              Text(duration, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
            ])),
          ]),
        ),
      ),
    );
  }
}
