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
  bool _appleHealthConnected = false;
  bool _googleFitConnected = false;

  static const _bg = Color(0xFF0D0D22);
  static const _card = Color(0xFF0F0F1C);
  static const _teal = Color(0xFF14B8A6);
  static const _tealDark = Color(0xFF0F766E);

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

  static const _gyms = [
    _Gym('Planet Fitness', '\$24/mo', '0.4 mi', '4.1',
        Icons.fitness_center_rounded, Color(0xFF6366F1),
        'Basic cardio, open 24hrs. Best for habit-building on a budget.'),
    _Gym('LA Fitness', '\$32/mo', '0.9 mi', '4.3',
        Icons.pool_rounded, Color(0xFF14B8A6),
        'Pool, classes, basketball. Best value for mid-tier access.'),
    _Gym('Equinox', '\$185/mo', '1.2 mi', '4.8',
        Icons.spa_rounded, Color(0xFFF59E0B),
        'Premium: spa, sauna, elite trainers. Worth it only if you go 4x+/week.'),
  ];

  static const _trainers = [
    _Trainer('Marcus Webb', 'Strength & HIIT', '\$65/hr', '4.9',
        'https://images.pexels.com/photos/3768911/pexels-photo-3768911.jpeg?auto=compress&cs=tinysrgb&w=200'),
    _Trainer('Aisha Cole', 'Weight Loss & Mobility', '\$55/hr', '4.8',
        'https://images.pexels.com/photos/3822906/pexels-photo-3822906.jpeg?auto=compress&cs=tinysrgb&w=200'),
    _Trainer('Derek Kim', 'Bodybuilding & Nutrition', '\$80/hr', '4.9',
        'https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg?auto=compress&cs=tinysrgb&w=200'),
  ];

  static const _supplements = [
    _Supplement('Whey Protein', 'Build & recover faster', '\$38/mo',
        Icons.fitness_center_rounded, Color(0xFF14B8A6)),
    _Supplement('Creatine', 'Strength + endurance', '\$14/mo',
        Icons.bolt_rounded, Color(0xFF6366F1)),
    _Supplement('Omega-3', 'Heart + joint health', '\$18/mo',
        Icons.water_drop_rounded, Color(0xFF3B82F6)),
    _Supplement('Vitamin D3 + K2', 'Immunity + bones', '\$12/mo',
        Icons.wb_sunny_rounded, Color(0xFFF59E0B)),
  ];

  static const _healthApps = [
    _HealthApp('MyFitnessPal', 'Food & calorie logging', 'Free',
        Icons.restaurant_menu_rounded, Color(0xFF10B981)),
    _HealthApp('Strava', 'Run & ride tracking', 'Free',
        Icons.directions_run_rounded, Color(0xFFEF4444)),
    _HealthApp('Whoop', 'Recovery & HRV', '\$30/mo',
        Icons.monitor_heart_rounded, Color(0xFF8B5CF6)),
    _HealthApp('Noom', 'Behavioral weight loss', '\$59/mo',
        Icons.psychology_rounded, Color(0xFF6366F1)),
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
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Ecosystem'),
                Tab(text: 'Nutrition'),
              ],
              labelColor: _teal,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _teal,
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
            _buildEcosystemTab(),
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
          placeholder: (_, __) =>
              Container(color: _teal.withValues(alpha: 0.2)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              Text('Your Health\nEconomy',
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

  // ── Overview Tab ─────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthScore(),
          const SizedBox(height: 20),
          _buildHealthSpendingCard(),
          const SizedBox(height: 20),
          _buildDataIntegrationBanner(),
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
          _buildChrisInsight(),
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
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_teal),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('84',
                          style: TextStyle(
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
                    const Text('Health Score',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        'Hydration + sleep are your two unlocks. Fix those and you clear 90.',
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
                      child: const Text('Full Report',
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

  Widget _buildHealthSpendingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded,
                  color: _teal, size: 16),
              const SizedBox(width: 8),
              const Text('Health Spending — June',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              const Text('\$312/mo',
                  style: TextStyle(
                      color: _teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          _spendRow('Gym Membership', '\$32', 0.10, const Color(0xFF14B8A6)),
          const SizedBox(height: 8),
          _spendRow('Supplements', '\$82', 0.26, const Color(0xFF6366F1)),
          const SizedBox(height: 8),
          _spendRow(
              'Health Insurance', '\$145', 0.47, const Color(0xFF3B82F6)),
          const SizedBox(height: 8),
          _spendRow('Copays & Rx', '\$53', 0.17, const Color(0xFFF59E0B)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: _teal, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Your supplement spend is 2.4× the avg for your age group. Chris found a bundle that cuts this to \$54/mo.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11.5,
                          height: 1.4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _spendRow(String label, String amount, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
            const Spacer(),
            Text(amount,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildDataIntegrationBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connect Your Health Apps',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
              'Chris gets smarter with your real data — steps, sleep, heart rate.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  height: 1.4)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                      () => _appleHealthConnected = !_appleHealthConnected),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _appleHealthConnected
                          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _appleHealthConnected
                              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.1),
                          width: 1),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.favorite_rounded,
                            color: _appleHealthConnected
                                ? const Color(0xFFEF4444)
                                : Colors.white.withValues(alpha: 0.3),
                            size: 22),
                        const SizedBox(height: 6),
                        Text('Apple Health',
                            style: TextStyle(
                                color: _appleHealthConnected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        Text(
                            _appleHealthConnected ? 'Connected' : 'Tap to connect',
                            style: TextStyle(
                                color: _appleHealthConnected
                                    ? const Color(0xFFEF4444)
                                    : Colors.white.withValues(alpha: 0.3),
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                      () => _googleFitConnected = !_googleFitConnected),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _googleFitConnected
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _googleFitConnected
                              ? const Color(0xFF10B981).withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.1),
                          width: 1),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.directions_run_rounded,
                            color: _googleFitConnected
                                ? const Color(0xFF10B981)
                                : Colors.white.withValues(alpha: 0.3),
                            size: 22),
                        const SizedBox(height: 6),
                        Text('Google Fit',
                            style: TextStyle(
                                color: _googleFitConnected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        Text(
                            _googleFitConnected ? 'Connected' : 'Tap to connect',
                            style: TextStyle(
                                color: _googleFitConnected
                                    ? const Color(0xFF10B981)
                                    : Colors.white.withValues(alpha: 0.3),
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChrisInsight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
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
              border:
                  Border.all(color: _teal.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _teal, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chris says',
                    style: TextStyle(
                        color: _teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    'Your steps dropped 23% this week. A 10-min walk at 1PM fits your calendar gap. That alone would push your weekly average past the metabolic risk threshold of 8,000 steps.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.5)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Add Walk to Calendar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Ecosystem Tab ─────────────────────────────────────────────

  Widget _buildEcosystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Gyms Near You'),
          const SizedBox(height: 6),
          Text(
              'Ranked by value-to-cost ratio for your fitness goal.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._gyms.map((g) => _GymCard(gym: g)),
          const SizedBox(height: 24),
          _sectionTitle('Personal Trainers'),
          const SizedBox(height: 6),
          Text('Verified. Session packages bookable through Chronos.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._trainers.map((t) => _TrainerCard(trainer: t)),
          const SizedBox(height: 24),
          _sectionTitle('Supplement Stack'),
          const SizedBox(height: 6),
          Text('Personalized to your goal: build muscle, improve energy.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: _supplements.length,
            itemBuilder: (_, i) => _SupplementCard(supp: _supplements[i]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: _teal.withValues(alpha: 0.2), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart_rounded, color: _teal, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly stack total: \$82',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text(
                          'Subscribe through Chronos and save 15% — \$69.70/mo',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Bundle',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Health Apps'),
          const SizedBox(height: 6),
          Text(
              'Chris pulls data from these to personalize your plan.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._healthApps.map((a) => _HealthAppTile(app: a)),
        ],
      ),
    );
  }

  // ── Nutrition Tab ─────────────────────────────────────────────

  Widget _buildNutritionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFoodSpendCard(),
          const SizedBox(height: 24),
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
                  child: macroCard('Fats', '48g', '/ 65g',
                      const Color(0xFFF59E0B), 0.74)),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Meals Today'),
          const SizedBox(height: 14),
          ...[
            _Meal('Breakfast', '520 kcal', '7:30 AM',
                Icons.breakfast_dining_rounded),
            _Meal('Lunch', '680 kcal', '12:45 PM',
                Icons.lunch_dining_rounded),
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

  Widget _buildFoodSpendCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Food Spend — June',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              const Text('\$520',
                  style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('vs \$480 last month (+8.3%)',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          const SizedBox(height: 14),
          _spendRow('Groceries', '\$310', 0.60, const Color(0xFF14B8A6)),
          const SizedBox(height: 8),
          _spendRow('Dining Out', '\$165', 0.32, const Color(0xFFEF4444)),
          const SizedBox(height: 8),
          _spendRow('Delivery Apps', '\$45', 0.09, const Color(0xFFF59E0B)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
                'Cooking 2 more meals at home each week saves ~\$85/mo — that\'s \$1,020/yr toward your emergency fund.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    height: 1.4)),
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
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
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
                  const Icon(Icons.local_fire_department_rounded,
                      color: Color(0xFFF59E0B), size: 20),
                  const Text('1,840',
                      style: TextStyle(
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
                const Text('Calories Today',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('1,840 / 3,000 kcal',
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
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _Metric {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  final double progress;
  const _Metric(
      this.label, this.value, this.unit, this.icon, this.color, this.progress);
}

class _Habit {
  final String name;
  final bool done;
  final IconData icon;
  const _Habit(this.name, this.done, this.icon);
}

class _Gym {
  final String name, price, distance, rating, description;
  final IconData icon;
  final Color color;
  const _Gym(this.name, this.price, this.distance, this.rating, this.icon,
      this.color, this.description);
}

class _Trainer {
  final String name, specialty, rate, rating, imageUrl;
  const _Trainer(
      this.name, this.specialty, this.rate, this.rating, this.imageUrl);
}

class _Supplement {
  final String name, benefit, price;
  final IconData icon;
  final Color color;
  const _Supplement(
      this.name, this.benefit, this.price, this.icon, this.color);
}

class _HealthApp {
  final String name, description, price;
  final IconData icon;
  final Color color;
  const _HealthApp(
      this.name, this.description, this.price, this.icon, this.color);
}

class _Meal {
  final String name, calories, time;
  final IconData icon;
  const _Meal(this.name, this.calories, this.time, this.icon);
}

// ── Widgets ───────────────────────────────────────────────────────────────────

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
        border:
            Border.all(color: metric.color.withValues(alpha: 0.2), width: 1),
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
                    fontSize: 14)),
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

class _GymCard extends StatelessWidget {
  final _Gym gym;
  const _GymCard({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gym.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gym.color.withValues(alpha: 0.12),
                ),
                child: Icon(gym.icon, color: gym.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gym.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFF59E0B), size: 12),
                        const SizedBox(width: 3),
                        Text(gym.rating,
                            style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        Text('  ·  ${gym.distance}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(gym.price,
                      style: TextStyle(
                          color: gym.color,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: gym.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Join',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(gym.description,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  height: 1.4)),
        ],
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  final _Trainer trainer;
  const _TrainerCard({required this.trainer});

  static const _teal = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: trainer.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: _teal.withValues(alpha: 0.2)),
              errorWidget: (_, __, ___) => Container(
                color: _teal.withValues(alpha: 0.2),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white54, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(trainer.specialty,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF59E0B), size: 12),
                  const SizedBox(width: 2),
                  Text(trainer.rating,
                      style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Text(trainer.rate,
                  style: const TextStyle(
                      color: _teal,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Book',
                      style: TextStyle(
                          color: _teal,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupplementCard extends StatelessWidget {
  final _Supplement supp;
  const _SupplementCard({required this.supp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: supp.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(supp.icon, color: supp.color, size: 16),
              const Spacer(),
              Text(supp.price,
                  style: TextStyle(
                      color: supp.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(supp.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(supp.benefit,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthAppTile extends StatefulWidget {
  final _HealthApp app;
  const _HealthAppTile({required this.app});

  @override
  State<_HealthAppTile> createState() => _HealthAppTileState();
}

class _HealthAppTileState extends State<_HealthAppTile> {
  bool _connected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _connected
                ? widget.app.color.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.06),
            width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.app.color.withValues(alpha: 0.12),
            ),
            child: Icon(widget.app.icon, color: widget.app.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.app.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
                Text(
                    '${widget.app.description}  ·  ${widget.app.price}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _connected = !_connected),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _connected
                    ? widget.app.color.withValues(alpha: 0.15)
                    : widget.app.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                  _connected ? 'Connected' : 'Connect',
                  style: TextStyle(
                      color: _connected ? widget.app.color : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
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
          Icon(meal.icon, color: const Color(0xFFF59E0B), size: 20),
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
                  color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
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
                color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
        const SizedBox(height: 4),
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text(target,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 10)),
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
