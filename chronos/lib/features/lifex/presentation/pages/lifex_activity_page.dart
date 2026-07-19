import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXActivityPage extends StatefulWidget {
  const LifeXActivityPage({super.key});

  @override
  State<LifeXActivityPage> createState() => _LifeXActivityPageState();
}

class _LifeXActivityPageState extends State<LifeXActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _bg = Color(0xFF0D0D22);
  static const _card = Color(0xFF0F0F1C);
  static const _accent = Colors.white;

  static const _activities = [
    _ActivityLog('Morning Run', '5.4 km', '34 min', '385 kcal', Icons.directions_run_rounded, Colors.white),
    _ActivityLog('Weight Training', '45 min', '3 sets', '280 kcal', Icons.fitness_center_rounded, Colors.white),
    _ActivityLog('Cycling', '12 km', '38 min', '310 kcal', Icons.directions_bike_rounded, Colors.white),
    _ActivityLog('Yoga Flow', '30 min', 'Flexibility', '140 kcal', Icons.self_improvement_rounded, Colors.white),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: const ChrisHomeFab(),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero(context)),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Summary'),
                Tab(text: 'Log'),
                Tab(text: 'Videos'),
              ],
              labelColor: _accent,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _accent,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildOverviewTab(),
            _buildSummaryTab(),
            _buildLogTab(),
            _buildVideosTab(),
          ],
        ),
      ),
    );
  }

  // ── Overview Tab ──────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('7,430 steps today',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${_activities.length} activities logged this week — 74% of your daily goal so far.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Explore Activity'),
          const SizedBox(height: 12),
          _OverviewLink(
            icon: Icons.insights_rounded,
            title: 'Summary',
            subtitle: 'Today\'s rings & this week\'s bars',
            onTap: () => _tabs.animateTo(1),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.directions_run_rounded,
            title: 'Log',
            subtitle: '${_activities.length} recent activities',
            onTap: () => _tabs.animateTo(2),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.play_circle_outline_rounded,
            title: 'Videos',
            subtitle: 'Guided workout sessions',
            onTap: () => _tabs.animateTo(3),
          ),
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
          placeholder: (_, __) => Container(color: Colors.white.withValues(alpha: 0.06)),
          errorWidget: (_, __, ___) => Container(color: Colors.white.withValues(alpha: 0.06)),
        ),
        Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.2), _bg.withValues(alpha: 0.97)],
        ))),
        Positioned(bottom: 24, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Stay in\nMotion', style: TextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
        ])),
      ]),
    );
  }

  // ── Summary Tab ──────────────────────────────────────────────

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildTodayRings(),
        const SizedBox(height: 22),
        _sectionTitle('Weekly Summary'),
        const SizedBox(height: 14),
        _buildWeeklyBars(),
      ]),
    );
  }

  Widget _buildTodayRings() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
      ),
      child: Row(children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 90, height: 90,
            child: CircularProgressIndicator(value: 0.74, strokeWidth: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.07),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeCap: StrokeCap.round)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('74%', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            Text('goal', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
          ]),
        ]),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Today\'s Goal', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _activityStat(Icons.directions_walk_rounded, '7,430', '/ 10,000 steps'),
          const SizedBox(height: 6),
          _activityStat(Icons.local_fire_department_rounded, '742', '/ 600 kcal burned'),
          const SizedBox(height: 6),
          _activityStat(Icons.timer_rounded, '48', '/ 60 min active'),
        ])),
      ]),
    );
  }

  Widget _activityStat(IconData icon, String val, String label) {
    return Row(children: [
      Icon(icon, color: Colors.white, size: 13),
      const SizedBox(width: 6),
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
    ]);
  }

  Widget _buildWeeklyBars() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const values = [0.6, 0.85, 0.4, 0.9, 0.74, 1.0, 0.3];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i) {
        final isToday = i == 4;
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200 + i * 80),
              height: 70 * values[i],
              decoration: BoxDecoration(
                color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Text(days[i], style: TextStyle(color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.35), fontSize: 11, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
          ]),
        ));
      })),
    );
  }

  // ── Log Tab ──────────────────────────────────────────────

  Widget _buildLogTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _sectionTitle('Recent Activity'),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Text('Log Activity', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 14),
        ..._activities.map((a) => _ActivityCard(activity: a)),
      ]),
    );
  }

  // ── Videos Tab ──────────────────────────────────────────────

  Widget _buildVideosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Workout Videos'),
        const SizedBox(height: 14),
        const _VideoCard('30-Day HIIT Challenge', '28 min', 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600'),
        const SizedBox(height: 14),
        const _VideoCard('Beginner Strength Training', '35 min', 'https://images.pexels.com/photos/3837757/pexels-photo-3837757.jpeg?auto=compress&cs=tinysrgb&w=600'),
        const SizedBox(height: 14),
        const _VideoCard('Evening Yoga & Stretch', '20 min', 'https://images.pexels.com/photos/2294354/pexels-photo-2294354.jpeg?auto=compress&cs=tinysrgb&w=600'),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
}

class _OverviewLink extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _OverviewLink({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.35), size: 20),
          ],
        ),
      ),
    );
  }
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
      decoration: BoxDecoration(color: const Color(0xFF0F0F1C), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            child: Icon(activity.icon, color: Colors.white, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(activity.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Text(activity.metric1, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            Text('  ·  ${activity.metric2}  ·  ${activity.calories}', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
          ]),
        ])),
        Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2), size: 20),
      ]),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String imageUrl;
  const _VideoCard(this.title, this.duration, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        height: 155,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(fit: StackFit.expand, children: [
            CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFF0F0F1C)),
                errorWidget: (_, __, ___) => Container(color: const Color(0xFF0F0F1C))),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)]))),
            Center(child: Container(width: 46, height: 46,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.18),
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
