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
    with SingleTickerProviderStateMixin {
  late AnimationController _breathCtrl;
  bool _isBreathing = false;
  int _selectedMeditation = 0;

  static const _bg = Color(0xFF06040E);
  static const _card = Color(0xFF0E0B1A);
  static const _purple = Color(0xFF8B5CF6);
  static const _purpleLight = Color(0xFFA78BFA);

  static const _meditations = [
    _Meditation('Morning Calm', '10 min', 'Guided',
        'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF8B5CF6)),
    _Meditation('Stress Relief', '15 min', 'Breathing',
        'https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF6366F1)),
    _Meditation('Sleep Well', '20 min', 'Body Scan',
        'https://images.pexels.com/photos/3759089/pexels-photo-3759089.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF3B82F6)),
    _Meditation('Focus Flow', '8 min', 'Breath Work',
        'https://images.pexels.com/photos/775201/pexels-photo-775201.jpeg?auto=compress&cs=tinysrgb&w=600',
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

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
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
      backgroundColor: _bg,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: const ChrisHomeFab(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: _buildStreakCard(),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Breath & Meditation'),
                const SizedBox(height: 14),
              ],
            ),
          )),
          SliverToBoxAdapter(child: _buildBreathingExercise()),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: _sectionTitle('Meditation Library'),
          )),
          SliverToBoxAdapter(
              child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              itemCount: _meditations.length,
              itemBuilder: (_, i) => _MeditationCard(
                  meditation: _meditations[i],
                  isSelected: _selectedMeditation == i,
                  onTap: () => setState(() => _selectedMeditation = i)),
            ),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Featured Video'),
                const SizedBox(height: 14),
                _VideoCard(
                  title: 'Introduction to Mindfulness',
                  duration: '18 min',
                  imageUrl:
                      'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=600',
                ),
                const SizedBox(height: 14),
                _VideoCard(
                  title: 'Gratitude Meditation',
                  duration: '12 min',
                  imageUrl:
                      'https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg?auto=compress&cs=tinysrgb&w=600',
                ),
              ],
            ),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _sectionTitle('Gratitude Journal'),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showAddGratitudeSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _purple.withValues(alpha: 0.4),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                color: _purpleLight, size: 14),
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
              ],
            ),
          )),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Spiritual Goals'),
                const SizedBox(height: 14),
                ..._goals.map((g) => _GoalCard(goal: g)),
              ],
            ),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl:
                'https://images.pexels.com/photos/3759089/pexels-photo-3759089.jpeg?auto=compress&cs=tinysrgb&w=900',
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: _purple.withValues(alpha: 0.15)),
            errorWidget: (_, __, ___) =>
                Container(color: _purple.withValues(alpha: 0.15)),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _purple.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.self_improvement_rounded,
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
            border: Border.all(color: _purple.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text('🕊️', style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 4),
                  Text('21',
                      style: const TextStyle(
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
                    Text('Profound Peace',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        'You\'ve completed 3 weeks of consecutive spiritual practice. Your consistency is building real inner strength.',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _purple.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('4-7-8 Breathing',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      Text('Inhale 4 · Hold 7 · Exhale 8',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
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

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
}

class _Meditation {
  final String title;
  final String duration;
  final String type;
  final String imageUrl;
  final Color color;

  const _Meditation(
      this.title, this.duration, this.type, this.imageUrl, this.color);
}

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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected
                  ? meditation.color
                  : meditation.color.withValues(alpha: 0.2),
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
                    color: meditation.color.withValues(alpha: 0.15)),
                errorWidget: (_, __, ___) => Container(
                    color: meditation.color.withValues(alpha: 0.15)),
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
                                color:
                                    Colors.white.withValues(alpha: 0.55),
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

class _SpiritualGoal {
  final String name;
  final int progress;
  final int total;
  final Color color;

  const _SpiritualGoal(this.name, this.progress, this.total, this.color);
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
        color: const Color(0xFF0E0B1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: goal.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(goal.name,
                    style: const TextStyle(
                        color: Colors.white,
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
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35), fontSize: 10)),
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
        color: const Color(0xFF0E0B1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          Text('🙏', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String imageUrl;

  const _VideoCard({
    required this.title,
    required this.duration,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 160,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: const Color(0xFF0E0B1A)),
                errorWidget: (_, __, ___) =>
                    Container(color: const Color(0xFF0E0B1A)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(duration,
                          style: const TextStyle(
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
        color: const Color(0xFF0E0B1A),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Add Gratitude',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'What are you grateful for today?',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
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
