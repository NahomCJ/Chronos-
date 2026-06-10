import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXVisionPage extends StatefulWidget {
  const LifeXVisionPage({super.key});

  @override
  State<LifeXVisionPage> createState() => _LifeXVisionPageState();
}

class _LifeXVisionPageState extends State<LifeXVisionPage> {
  static const _bg = Color(0xFF060810);
  static const _card = Color(0xFF0C0F1C);
  static const _blue = Color(0xFF3B82F6);
  static const _blueLight = Color(0xFF60A5FA);

  static const _goals = [
    _VisionGoal('Launch my own business', Icons.rocket_launch_rounded, Color(0xFF6366F1), 0.45,
        'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _VisionGoal('Buy a home', Icons.home_rounded, Color(0xFF10B981), 0.55,
        'https://images.pexels.com/photos/1128318/pexels-photo-1128318.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _VisionGoal('Run a marathon', Icons.directions_run_rounded, Color(0xFFF59E0B), 0.30,
        'https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _VisionGoal('Speak 2 languages', Icons.language_rounded, Color(0xFFEC4899), 0.25,
        'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=400'),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Vision Board'),
              const SizedBox(height: 14),
            ]),
          )),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _VisionBoardCard(goal: _goals[i]),
                childCount: _goals.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: _blue.withValues(alpha: 0.3), width: 1),
                  borderRadius: BorderRadius.circular(16),
                  color: _blue.withValues(alpha: 0.05),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_rounded, color: _blueLight, size: 18),
                  const SizedBox(width: 8),
                  Text('Add Vision Goal', style: TextStyle(color: _blueLight, fontSize: 14, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Milestones This Month'),
              const SizedBox(height: 14),
              ...[
                _Milestone('Saved \$500 towards house fund', true, const Color(0xFF10B981)),
                _Milestone('Completed business model canvas', true, const Color(0xFF6366F1)),
                _Milestone('Run 20km this week', false, const Color(0xFFF59E0B)),
                _Milestone('Practice Spanish 5 days', false, const Color(0xFFEC4899)),
              ].map((m) => _MilestoneTile(milestone: m)),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Chris Vision Coach'),
              const SizedBox(height: 14),
              _buildChrisCoach(),
              const SizedBox(height: 20),
              _sectionTitle('Inspiration'),
              const SizedBox(height: 14),
              _VideoCard('How to Build Your Vision Board', '15 min', 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=600'),
            ]),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(height: 250, child: Stack(fit: StackFit.expand, children: [
      CachedNetworkImage(
        imageUrl: 'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=900',
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: _blue.withValues(alpha: 0.15)),
        errorWidget: (_, __, ___) => Container(color: _blue.withValues(alpha: 0.15)),
      ),
      Container(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.black.withValues(alpha: 0.2), _bg.withValues(alpha: 0.97)],
      ))),
      SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
        ),
      )),
      Positioned(bottom: 24, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: _blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _blue.withValues(alpha: 0.5), width: 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.remove_red_eye_rounded, color: _blueLight, size: 12), const SizedBox(width: 6),
            Text('GOALS & VISION', style: TextStyle(color: _blueLight, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ]),
        ),
        const SizedBox(height: 10),
        Text('Your Future\nSelf', style: TextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
      ])),
    ]));
  }

  Widget _buildChrisCoach() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _blue.withValues(alpha: 0.2), width: 1)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: _blue.withValues(alpha: 0.12),
            border: Border.all(color: _blue.withValues(alpha: 0.4), width: 1)),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF3B82F6), size: 15)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Chris says', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Your business goal is progressing well. I noticed you\'ve been researching online businesses — I can help you create a 90-day action plan. Want me to draft one?',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.5, height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
}

class _VisionGoal {
  final String title;
  final IconData icon;
  final Color color;
  final double progress;
  final String imageUrl;
  const _VisionGoal(this.title, this.icon, this.color, this.progress, this.imageUrl);
}

class _VisionBoardCard extends StatelessWidget {
  final _VisionGoal goal;
  const _VisionBoardCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(fit: StackFit.expand, children: [
        CachedNetworkImage(imageUrl: goal.imageUrl, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: goal.color.withValues(alpha: 0.15)),
            errorWidget: (_, __, ___) => Container(color: goal.color.withValues(alpha: 0.15))),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [goal.color.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.8)]))),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: goal.color.withValues(alpha: 0.2),
              border: Border.all(color: goal.color.withValues(alpha: 0.5), width: 1)),
              child: Icon(goal.icon, color: goal.color, size: 16)),
          const Spacer(),
          Text(goal.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: goal.progress, backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(goal.color), minHeight: 3)),
          const SizedBox(height: 4),
          Text('${(goal.progress * 100).round()}% complete',
              style: TextStyle(color: goal.color, fontSize: 10, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}

class _Milestone {
  final String text;
  final bool done;
  final Color color;
  const _Milestone(this.text, this.done, this.color);
}

class _MilestoneTile extends StatelessWidget {
  final _Milestone milestone;
  const _MilestoneTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF0C0F1C), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: milestone.done ? milestone.color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06), width: 1)),
      child: Row(children: [
        Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle,
            color: milestone.done ? milestone.color : Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: milestone.done ? milestone.color : Colors.white.withValues(alpha: 0.12), width: 1)),
            child: milestone.done ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null),
        const SizedBox(width: 12),
        Expanded(child: Text(milestone.text, style: TextStyle(color: milestone.done ? Colors.white : Colors.white.withValues(alpha: 0.5), fontSize: 13))),
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
      child: Container(
        height: 155,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(fit: StackFit.expand, children: [
            CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFF0C0F1C)),
                errorWidget: (_, __, ___) => Container(color: const Color(0xFF0C0F1C))),
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
