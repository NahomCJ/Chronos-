import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXHealthPage extends StatefulWidget {
  const LifeXHealthPage({super.key});

  @override
  State<LifeXHealthPage> createState() => _LifeXHealthPageState();
}

class _LifeXHealthPageState extends State<LifeXHealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _bg = Color(0xFF08080F);
  static const _card = Color(0xFF0F0F1C);
  static const _teal = Color(0xFF14B8A6);
  static const _tealDark = Color(0xFF0F766E);

  // Mock data — will be replaced by real API responses from /api/lifex/health
  final _metrics = [
    _Metric('Heart Rate', '72', 'bpm', Icons.favorite_rounded,
        Color(0xFFEF4444), 0.72),
    _Metric('Steps', '7,430', '/10k', Icons.directions_walk_rounded,
        Color(0xFF14B8A6), 0.74),
    _Metric('Sleep', '7.2', 'hrs', Icons.bedtime_rounded,
        Color(0xFF8B5CF6), 0.72),
    _Metric('Calories', '1,840', 'kcal', Icons.local_fire_department_rounded,
        Color(0xFFF59E0B), 0.61),
    _Metric('Water', '1.8', 'L/day', Icons.water_drop_rounded,
        Color(0xFF3B82F6), 0.60),
    _Metric('BMI', '22.4', 'score', Icons.monitor_weight_rounded,
        Color(0xFF10B981), 0.78),
  ];

  final _habits = [
    _Habit('Morning Run', true, Icons.directions_run_rounded),
    _Habit('Vitamins', true, Icons.medication_rounded),
    _Habit('Meditation', false, Icons.self_improvement_rounded),
    _Habit('8 glasses water', true, Icons.water_drop_rounded),
    _Habit('No sugar', false, Icons.no_food_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
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
            expandedHeight: 260,
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
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHero(),
            ),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Fitness'),
                Tab(text: 'Nutrition'),
              ],
              labelColor: _teal,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _teal,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildOverviewTab(),
            _buildFitnessTab(),
            _buildNutritionTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl:
              'https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: _teal.withValues(alpha: 0.2)),
          errorWidget: (_, __, ___) =>
              Container(color: _teal.withValues(alpha: 0.2)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                _bg.withValues(alpha: 0.95),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 56,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _teal.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, color: _teal, size: 12),
                    const SizedBox(width: 6),
                    Text('HEALTH & WELLNESS',
                        style: TextStyle(
                            color: _teal,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Your Health\nJourney',
                  style: TextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      height: 1.1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Health Score'),
          const SizedBox(height: 14),
          _buildHealthScore(),
          const SizedBox(height: 24),
          _sectionTitle('Today\'s Metrics'),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _metrics.length,
            itemBuilder: (_, i) => _MetricCard(metric: _metrics[i]),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Today\'s Habits'),
          const SizedBox(height: 14),
          ..._habits.map((h) => _HabitTile(habit: h)),
          const SizedBox(height: 24),
          _sectionTitle('Chris Health Insight'),
          const SizedBox(height: 14),
          _buildChrisInsight(),
          const SizedBox(height: 24),
          _sectionTitle('Featured Workout'),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'HIIT Morning Routine',
            duration: '22 min',
            imageUrl:
                'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=600',
            category: 'Full Body',
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyActivity(),
          const SizedBox(height: 24),
          _sectionTitle('Recent Sessions'),
          const SizedBox(height: 14),
          ...[
            _FitnessSession('Morning Run', '5.2 km', '32 min',
                Icons.directions_run_rounded, _teal),
            _FitnessSession('Yoga', '45 min', '280 kcal',
                Icons.self_improvement_rounded, const Color(0xFF8B5CF6)),
            _FitnessSession('Cycling', '18 km', '55 min',
                Icons.directions_bike_rounded, const Color(0xFFF59E0B)),
          ].map((s) => _FitnessSessionCard(session: s)),
          const SizedBox(height: 24),
          _sectionTitle('Workout Video'),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Strength Training Basics',
            duration: '35 min',
            imageUrl:
                'https://images.pexels.com/photos/3837757/pexels-photo-3837757.jpeg?auto=compress&cs=tinysrgb&w=600',
            category: 'Strength',
          ),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Flexibility & Stretching',
            duration: '18 min',
            imageUrl:
                'https://images.pexels.com/photos/2294354/pexels-photo-2294354.jpeg?auto=compress&cs=tinysrgb&w=600',
            category: 'Recovery',
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalorieRing(),
          const SizedBox(height: 24),
          _sectionTitle('Macros Today'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: macroCard('Protein', '142g', '/ 160g',
                      const Color(0xFF14B8A6), 0.89)),
              const SizedBox(width: 12),
              Expanded(
                  child: macroCard('Carbs', '180g', '/ 220g',
                      const Color(0xFF6366F1), 0.82)),
              const SizedBox(width: 12),
              Expanded(
                  child: macroCard(
                      'Fats', '48g', '/ 65g', const Color(0xFFF59E0B), 0.74)),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Meals Today'),
          const SizedBox(height: 14),
          ...[
            _Meal('Breakfast', '520 kcal', '7:30 AM', Icons.breakfast_dining_rounded),
            _Meal('Lunch', '680 kcal', '12:45 PM', Icons.lunch_dining_rounded),
            _Meal('Snack', '180 kcal', '3:30 PM', Icons.apple_rounded),
          ].map((m) => _MealTile(meal: m)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _teal.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: _teal.withValues(alpha: 0.06),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: _teal, size: 18),
                  const SizedBox(width: 8),
                  Text('Log a Meal',
                      style: TextStyle(
                          color: _teal,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScore() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _teal.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: _teal.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: 0.84,
                      strokeWidth: 7,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(_teal),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('84',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                      Text('/ 100',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health Score',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        'Great score! Focus on sleep and hydration to push past 90.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                            height: 1.45)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('View Full Report',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChrisInsight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _tealDark.withValues(alpha: 0.2),
              border: Border.all(color: _teal.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: _teal, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chris says',
                    style: TextStyle(
                        color: _teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    'Your step count dropped 23% this week. Based on your usual schedule, try a 10-minute walk after lunch — it fits your calendar.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity() {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const values = [0.7, 0.9, 0.5, 0.8, 0.4, 1.0, 0.6];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Weekly Activity',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('This week',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final isToday = i == 4;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300 + i * 80),
                          height: 60 * values[i],
                          decoration: BoxDecoration(
                            color: isToday
                                ? _teal
                                : _teal.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(days[i],
                            style: TextStyle(
                                color: isToday
                                    ? _teal
                                    : Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieRing() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.61,
                  strokeWidth: 9,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF59E0B)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: const Color(0xFFF59E0B), size: 20),
                  Text('1,840',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text('kcal',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calories Today',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('1,840 / 3,000 kcal consumed',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12)),
                const SizedBox(height: 12),
                _miniBar('Consumed', 1840, 3000, const Color(0xFFF59E0B)),
                const SizedBox(height: 6),
                _miniBar('Burned', 420, 600, const Color(0xFF14B8A6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBar(String label, int val, int max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10)),
            const Spacer(),
            Text('$val / $max',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val / max,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700));
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _Metric {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;
  const _Metric(
      this.label, this.value, this.unit, this.icon, this.color, this.progress);
}

class _MetricCard extends StatelessWidget {
  final _Metric metric;
  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: metric.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(metric.icon, color: metric.color, size: 16),
              const Spacer(),
              Text(metric.unit,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 10)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              Text(metric.label,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: metric.progress,
                  backgroundColor: metric.color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(metric.color),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Habit {
  final String name;
  final bool done;
  final IconData icon;
  const _Habit(this.name, this.done, this.icon);
}

class _HabitTile extends StatefulWidget {
  final _Habit habit;
  const _HabitTile({required this.habit});

  @override
  State<_HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<_HabitTile> {
  late bool _done;

  @override
  void initState() {
    super.initState();
    _done = widget.habit.done;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _done = !_done),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _done
                  ? const Color(0xFF14B8A6).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.06),
              width: 1),
        ),
        child: Row(
          children: [
            Icon(widget.habit.icon,
                color: _done
                    ? const Color(0xFF14B8A6)
                    : Colors.white.withValues(alpha: 0.3),
                size: 18),
            const SizedBox(width: 12),
            Text(widget.habit.name,
                style: TextStyle(
                    color: _done
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    decoration: _done ? TextDecoration.none : null)),
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _done
                    ? const Color(0xFF14B8A6)
                    : Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                    color: _done
                        ? const Color(0xFF14B8A6)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1),
              ),
              child: _done
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _FitnessSession {
  final String name;
  final String metric1;
  final String metric2;
  final IconData icon;
  final Color color;
  const _FitnessSession(
      this.name, this.metric1, this.metric2, this.icon, this.color);
}

class _FitnessSessionCard extends StatelessWidget {
  final _FitnessSession session;
  const _FitnessSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: session.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: session.color.withValues(alpha: 0.12),
            ),
            child: Icon(session.icon, color: session.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(session.metric1,
                        style: TextStyle(
                            color: session.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    Text('  ·  ${session.metric2}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2), size: 20),
        ],
      ),
    );
  }
}

class _Meal {
  final String name;
  final String calories;
  final String time;
  final IconData icon;
  const _Meal(this.name, this.calories, this.time, this.icon);
}

class _MealTile extends StatelessWidget {
  final _Meal meal;
  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Row(
        children: [
          Icon(meal.icon,
              color: const Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(meal.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          Text(meal.time,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12)),
          const SizedBox(width: 10),
          Text(meal.calories,
              style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

Widget macroCard(
    String label, String val, String target, Color color, double progress) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF0F0F1C),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11)),
        const SizedBox(height: 4),
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text(target,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
        ),
      ],
    ),
  );
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String imageUrl;
  final String category;

  const _VideoCard({
    required this.title,
    required this.duration,
    required this.imageUrl,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: wire up VideoPlayerController
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: const Color(0xFF111130)),
                errorWidget: (_, __, ___) =>
                    Container(color: const Color(0xFF111130)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('$category  ·  $duration',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_circle_rounded,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(duration,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
