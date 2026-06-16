import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXSpiritualPage extends StatefulWidget {
  const LifeXSpiritualPage({super.key});

  @override
  State<LifeXSpiritualPage> createState() => _LifeXSpiritualPageState();
}

class _LifeXSpiritualPageState extends State<LifeXSpiritualPage>
    with TickerProviderStateMixin {
  late TabController _tabs;
  late AnimationController _breathCtrl;
  bool _isBreathing = false;
  int _selectedMeditation = 0;
  bool _dailyReminderOn = true;
  bool _reflectionExpanded = false;

  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _purple = Color(0xFF8B5CF6);
  static const _purpleLight = Color(0xFFA78BFA);

  static const _meditations = [
    _Meditation('Morning Calm', '10 min', 'Guided',
        'https://images.pexels.com/photos/1761279/pexels-photo-1761279.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF8B5CF6)),
    _Meditation('Stress Relief', '15 min', 'Breathing',
        'https://images.pexels.com/photos/355465/pexels-photo-355465.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF6366F1)),
    _Meditation('Sleep Well', '20 min', 'Body Scan',
        'https://images.pexels.com/photos/1252890/pexels-photo-1252890.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF3B82F6)),
    _Meditation('Focus Flow', '8 min', 'Breath Work',
        'https://images.pexels.com/photos/2775196/pexels-photo-2775196.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFFEC4899)),
  ];

  static const _gratitudes = [
    'I\'m grateful for my health and energy today',
    'The people in my life who support me unconditionally',
    'New opportunities that are appearing in my path',
  ];

  static const _goals = [
    _SpiritualGoal('Meditate 21 days straight', 14, 21, Color(0xFF8B5CF6)),
    _SpiritualGoal('Daily gratitude for 30 days', 22, 30, Color(0xFF10B981)),
    _SpiritualGoal('Read spiritual text weekly', 3, 4, Color(0xFFF59E0B)),
  ];

  static const _givingHistory = [
    _GivingRecord('May 2025', '\$200', 'Tithes & Offerings', '4 donations'),
    _GivingRecord('April 2025', '\$185', 'Tithes & Offerings', '3 donations'),
    _GivingRecord('March 2025', '\$210', 'Tithes & Offerings', '4 donations'),
  ];

  static const _charities = [
    _Charity('Local Food Bank', 'Community', '\$25/mo',
        Icons.restaurant_rounded, Color(0xFF10B981)),
    _Charity('Child Education Fund', 'Education', '\$30/mo',
        Icons.school_rounded, Color(0xFF3B82F6)),
    _Charity('Disaster Relief', 'Emergency Aid', '\$15/mo',
        Icons.volunteer_activism_rounded, Color(0xFFEF4444)),
  ];

  static const _mindfulnessApps = [
    _MindApp('Calm', 'Sleep & meditation', '\$14.99/mo',
        Icons.nightlight_rounded, Color(0xFF3B82F6)),
    _MindApp('Headspace', 'Guided meditation', '\$12.99/mo',
        Icons.self_improvement_rounded, Color(0xFFEF4444)),
    _MindApp('Insight Timer', 'Free meditation library', 'Free',
        Icons.timer_rounded, Color(0xFF10B981)),
    _MindApp('Balance', 'Personalized plans', 'Free (1yr)',
        Icons.balance_rounded, Color(0xFF8B5CF6)),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() => _isBreathing = !_isBreathing);
    if (_isBreathing) {
      _breathCtrl.repeat(reverse: true);
    } else {
      _breathCtrl.stop();
      _breathCtrl.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: const ChrisHomeFab(),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A1A2E),
            surfaceTintColor: Colors.transparent,
            shadowColor: const Color(0xFFE8EAF0),
            elevation: 1,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3F4F6),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF374151), size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'Practice'),
                Tab(text: 'Giving'),
                Tab(text: 'Anchor'),
              ],
              labelColor: _purple,
              unselectedLabelColor: Color(0xFF6B7080),
              indicatorColor: _purple,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildPracticeTab(),
            _buildGivingTab(),
            _buildAnchorTab(),
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
              'https://images.pexels.com/photos/994605/pexels-photo-994605.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: const Color(0xFFE8EAF0)),
          errorWidget: (_, __, ___) =>
              Container(color: const Color(0xFFE8EAF0)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                _bg.withValues(alpha: 0.97),
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
                  color: _purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _purple.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.spa_rounded,
                        color: _purpleLight, size: 12),
                    const SizedBox(width: 6),
                    Text('MIND, BODY & SPIRIT',
                        style: TextStyle(
                            color: _purpleLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Your Inner\nSanctuary',
                  style: TextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      height: 1.1)),
              const SizedBox(height: 6),
              Text('Silence is the loudest form of clarity.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Practice Tab ──────────────────────────────────────────────

  Widget _buildPracticeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStreakCard(),
          const SizedBox(height: 22),
          _sectionTitle('Breath & Meditation'),
          const SizedBox(height: 14),
          _buildBreathingExercise(),
          const SizedBox(height: 22),
          _sectionTitle('Meditation Library'),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _meditations.length,
              itemBuilder: (_, i) => _MeditationCard(
                meditation: _meditations[i],
                isSelected: _selectedMeditation == i,
                onTap: () => setState(() => _selectedMeditation = i),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _sectionTitle('Gratitude Journal'),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddGratitudeSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _purple.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: _purpleLight, size: 14),
                      const SizedBox(width: 4),
                      Text('Add',
                          style: TextStyle(
                              color: _purpleLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._gratitudes.map((g) => _GratitudeCard(text: g)),
          const SizedBox(height: 22),
          _sectionTitle('Spiritual Goals'),
          const SizedBox(height: 14),
          ..._goals.map((g) => _GoalCard(goal: g)),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _purple.withValues(alpha: 0.2),
                const Color(0xFF4F46E5).withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: _purple.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  const Text('🕊️',
                      style: TextStyle(fontSize: 30)),
                  const SizedBox(height: 4),
                  const Text('21',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  Text('day streak',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profound Peace',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        '3 weeks of consecutive spiritual practice. Consistency is building real inner strength.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                            height: 1.45)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _chip('48 sessions', _purple),
                        const SizedBox(width: 8),
                        _chip('360 mins', const Color(0xFF6366F1)),
                      ],
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

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildBreathingExercise() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('4-7-8 Breathing',
                        style: TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const Text('Inhale 4 · Hold 7 · Exhale 8',
                        style: TextStyle(
                            color: Color(0xFF6B7080),
                            fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggleBreathing,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: _isBreathing
                        ? _purple.withValues(alpha: 0.3)
                        : _purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          _isBreathing
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16),
                      const SizedBox(width: 4),
                      Text(_isBreathing ? 'Stop' : 'Start',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isBreathing) ...[
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _breathCtrl,
              builder: (_, __) {
                final val = _breathCtrl.value;
                final size = 80.0 + val * 40;
                final opacity = 0.3 + val * 0.4;
                return Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: size + 30,
                        height: size + 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _purple.withValues(alpha: opacity * 0.3),
                        ),
                      ),
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _purple.withValues(alpha: opacity),
                          boxShadow: [
                            BoxShadow(
                                color: _purple.withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 5),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            val < 0.21
                                ? 'Inhale'
                                : val < 0.58
                                    ? 'Hold'
                                    : 'Exhale',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  void _showAddGratitudeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddGratitudeSheet(),
    );
  }

  // ── Giving Tab ────────────────────────────────────────────────

  Widget _buildGivingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGivingSummary(),
          const SizedBox(height: 24),
          _sectionTitle('Organizations'),
          const SizedBox(height: 6),
          const Text('Recurring giving set up through your Chronos wallet.',
              style: TextStyle(
                  color: Color(0xFF6B7080), fontSize: 12)),
          const SizedBox(height: 14),
          ..._charities.map((c) => _CharityTile(charity: c)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _purple.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: _purple.withValues(alpha: 0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: _purpleLight, size: 18),
                  const SizedBox(width: 8),
                  Text('Add Organization',
                      style: TextStyle(
                          color: _purpleLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Giving History'),
          const SizedBox(height: 14),
          ..._givingHistory.map((g) => _GivingHistoryCard(record: g)),
          const SizedBox(height: 24),
          _buildAutoTitheCard(),
        ],
      ),
    );
  }

  Widget _buildGivingSummary() {
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
                _purple.withValues(alpha: 0.18),
                const Color(0xFFF5F6FA).withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _purple.withValues(alpha: 0.25), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Giving This Year',
                      style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Tax Deductible',
                        style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _givingStat('\$1,195', 'Total Given', const Color(0xFF10B981)),
                  _givingDivider(),
                  _givingStat('\$70/mo', 'Recurring', _purple),
                  _givingDivider(),
                  _givingStat('6.3%', 'of Income', const Color(0xFF3B82F6)),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.63,
                  backgroundColor: const Color(0xFFE8EAF0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Goal: 10% of income — \$433/mo needed, \$70/mo current',
                  style: TextStyle(
                      color: Color(0xFF6B7080),
                      fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _givingStat(String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF6B7080), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _givingDivider() {
    return const SizedBox(
        width: 1, height: 28,
        child: ColoredBox(color: Color(0xFFE8EAF0)));
  }

  Widget _buildAutoTitheCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_mode_rounded, color: _purple, size: 18),
              const SizedBox(width: 8),
              const Text('Auto-Tithe',
                  style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Set Up',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
              'Set a percentage of every deposit to auto-give to your chosen organizations the moment money arrives. No friction, no forgetting.',
              style: TextStyle(
                  color: Color(0xFF6B7080),
                  fontSize: 12,
                  height: 1.5)),
        ],
      ),
    );
  }

  // ── Anchor Tab ────────────────────────────────────────────────

  Widget _buildAnchorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyAnchorCard(),
          const SizedBox(height: 22),
          _buildWeeklyReflection(),
          const SizedBox(height: 24),
          _sectionTitle('Mindfulness Apps'),
          const SizedBox(height: 6),
          const Text(
              'Curated. Chris tracks your usage to see what helps your recovery score.',
              style: TextStyle(
                  color: Color(0xFF6B7080), fontSize: 12)),
          const SizedBox(height: 14),
          ..._mindfulnessApps.map((a) => _MindAppTile(app: a)),
          const SizedBox(height: 22),
          _buildDailyReminderToggle(),
        ],
      ),
    );
  }

  Widget _buildDailyAnchorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _purple.withValues(alpha: 0.2),
            const Color(0xFF4F46E5).withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _purple.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple.withValues(alpha: 0.2),
                  border: Border.all(
                      color: _purple.withValues(alpha: 0.5), width: 1),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: _purple, size: 16),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Anchor',
                      style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  Text('Chris · Sunday, June 14',
                      style: TextStyle(
                          color: _purpleLight,
                          fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _purple.withValues(alpha: 0.15), width: 1),
            ),
            child: const Text(
                '"The secret of getting ahead is getting started." — Mark Twain\n\nToday: Before you open your first app, spend 5 minutes in silence. No phone. Just you.',
                style: TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 13,
                    height: 1.6,
                    fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('Done for today',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('Refresh',
                      style: TextStyle(
                          color: Color(0xFF6B7080),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReflection() {
    return GestureDetector(
      onTap: () => setState(() => _reflectionExpanded = !_reflectionExpanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, color: _purpleLight, size: 18),
                const SizedBox(width: 10),
                const Text('Weekly Reflection',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                Icon(
                    _reflectionExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6B7080),
                    size: 20),
              ],
            ),
            if (_reflectionExpanded) ...[
              const SizedBox(height: 14),
              const Text('What went well this week? What would you do differently?',
                  style: TextStyle(
                      color: Color(0xFF6B7080),
                      fontSize: 12)),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Write your reflection...',
                  hintStyle: const TextStyle(
                      color: Color(0xFF6B7080),
                      fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _reflectionExpanded = false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Save Reflection',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyReminderToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_none_rounded,
              color: _purpleLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Anchor Reminder',
                    style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const Text('7:00 AM every morning',
                    style: TextStyle(
                        color: Color(0xFF6B7080),
                        fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _dailyReminderOn,
            onChanged: (v) => setState(() => _dailyReminderOn = v),
            activeColor: _purple,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.w700));
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _Meditation {
  final String title, duration, type, imageUrl;
  final Color color;
  const _Meditation(
      this.title, this.duration, this.type, this.imageUrl, this.color);
}

class _SpiritualGoal {
  final String name;
  final int progress, total;
  final Color color;
  const _SpiritualGoal(this.name, this.progress, this.total, this.color);
}

class _Charity {
  final String name, category, amount;
  final IconData icon;
  final Color color;
  const _Charity(this.name, this.category, this.amount, this.icon, this.color);
}

class _GivingRecord {
  final String month, total, description, count;
  const _GivingRecord(this.month, this.total, this.description, this.count);
}

class _MindApp {
  final String name, description, price;
  final IconData icon;
  final Color color;
  const _MindApp(
      this.name, this.description, this.price, this.icon, this.color);
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _MeditationCard extends StatelessWidget {
  final _Meditation meditation;
  final bool isSelected;
  final VoidCallback onTap;

  const _MeditationCard(
      {required this.meditation,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected
                  ? meditation.color
                  : const Color(0xFFE8EAF0),
              width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: meditation.color.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: meditation.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    color: const Color(0xFFE8EAF0)),
                errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFE8EAF0)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meditation.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Text(meditation.type,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 10)),
                        const Text(' · ',
                            style: TextStyle(color: Colors.white38)),
                        Text(meditation.duration,
                            style: TextStyle(
                                color: meditation.color, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: meditation.color,
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 13),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final _SpiritualGoal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final pct = goal.progress / goal.total;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: goal.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(goal.name,
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
              ),
              Text('${goal.progress}/${goal.total}',
                  style: TextStyle(
                      color: goal.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: goal.color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text('${(pct * 100).round()}% complete',
              style: const TextStyle(
                  color: Color(0xFF6B7080), fontSize: 10)),
        ],
      ),
    );
  }
}

class _GratitudeCard extends StatelessWidget {
  final String text;
  const _GratitudeCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Text('🙏', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 13,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _CharityTile extends StatefulWidget {
  final _Charity charity;
  const _CharityTile({required this.charity});

  @override
  State<_CharityTile> createState() => _CharityTileState();
}

class _CharityTileState extends State<_CharityTile> {
  bool _giving = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _giving
                ? widget.charity.color.withValues(alpha: 0.3)
                : const Color(0xFFE8EAF0),
            width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.charity.color.withValues(alpha: 0.12),
            ),
            child: Icon(widget.charity.icon,
                color: widget.charity.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.charity.name,
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
                Text(
                    '${widget.charity.category}  ·  ${widget.charity.amount}',
                    style: const TextStyle(
                        color: Color(0xFF6B7080),
                        fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _giving = !_giving),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _giving
                    ? widget.charity.color.withValues(alpha: 0.15)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _giving
                        ? widget.charity.color.withValues(alpha: 0.4)
                        : const Color(0xFFE8EAF0),
                    width: 1),
              ),
              child: Text(_giving ? 'Active' : 'Paused',
                  style: TextStyle(
                      color: _giving
                          ? widget.charity.color
                          : const Color(0xFF6B7080),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GivingHistoryCard extends StatelessWidget {
  final _GivingRecord record;
  const _GivingHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.volunteer_activism_rounded,
                color: Color(0xFF8B5CF6), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.month,
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
                Text('${record.description}  ·  ${record.count}',
                    style: const TextStyle(
                        color: Color(0xFF6B7080),
                        fontSize: 11)),
              ],
            ),
          ),
          Text(record.total,
              style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _MindAppTile extends StatelessWidget {
  final _MindApp app;
  const _MindAppTile({required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFE8EAF0), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: app.color.withValues(alpha: 0.12),
              ),
              child: Icon(app.icon, color: app.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.name,
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600)),
                  Text(app.description,
                      style: const TextStyle(
                          color: Color(0xFF6B7080),
                          fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: app.price == 'Free' || app.price.contains('Free')
                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                    : app.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(app.price,
                  style: TextStyle(
                      color: app.price == 'Free' ||
                              app.price.contains('Free')
                          ? const Color(0xFF10B981)
                          : app.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddGratitudeSheet extends StatefulWidget {
  @override
  State<_AddGratitudeSheet> createState() => _AddGratitudeSheetState();
}

class _AddGratitudeSheetState extends State<_AddGratitudeSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Add Gratitude',
                style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 15),
              decoration: InputDecoration(
                hintText: 'What are you grateful for today?',
                hintStyle: const TextStyle(
                    color: Color(0xFF6B7080), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
