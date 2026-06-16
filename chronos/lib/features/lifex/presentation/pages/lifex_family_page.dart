import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXFamilyPage extends StatefulWidget {
  const LifeXFamilyPage({super.key});

  @override
  State<LifeXFamilyPage> createState() => _LifeXFamilyPageState();
}

class _LifeXFamilyPageState extends State<LifeXFamilyPage> {
  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _pink = Color(0xFFEC4899);
  static const _pinkLight = Color(0xFFF472B6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(margin: const EdgeInsets.only(bottom: 30), child: const ChrisHomeFab()),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Family Group'),
              const SizedBox(height: 14),
              _buildFamilyGroup(),
              const SizedBox(height: 22),
              _sectionTitle('Shared Goals'),
              const SizedBox(height: 14),
              _buildSharedGoal('Family Vacation to Japan', 0.62, '\$3,720', '\$6,000', const Color(0xFFEC4899)),
              _buildSharedGoal('New Family Car', 0.35, '\$7,000', '\$20,000', const Color(0xFF6366F1)),
              _buildSharedGoal('Kids Education Fund', 0.48, '\$12,000', '\$25,000', const Color(0xFF10B981)),
              const SizedBox(height: 22),
              _sectionTitle('Shared Budget'),
              const SizedBox(height: 14),
              _buildSharedBudget(),
              const SizedBox(height: 22),
              _sectionTitle('Family Moments'),
              const SizedBox(height: 14),
              _buildMomentsFeed(),
            ]),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(height: 240, child: Stack(fit: StackFit.expand, children: [
      CachedNetworkImage(
        imageUrl: 'https://images.pexels.com/photos/1128318/pexels-photo-1128318.jpeg?auto=compress&cs=tinysrgb&w=900',
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: _pink.withValues(alpha: 0.1)),
        errorWidget: (_, __, ___) => Container(color: _pink.withValues(alpha: 0.1)),
      ),
      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.2), _bg.withValues(alpha: 0.97)]))),
      SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF3F4F6),
                  border: Border.all(color: _border, width: 1)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF374151), size: 16)),
        ),
      )),
      Positioned(bottom: 24, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: _pink.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _pink.withValues(alpha: 0.5), width: 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.people_rounded, color: _pinkLight, size: 12), const SizedBox(width: 6),
            Text('FAMILY & BONDS', style: TextStyle(color: _pinkLight, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ])),
        const SizedBox(height: 10),
        Text('Your People', style: TextStyles.displaySmall.copyWith(color: _textPrimary, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
      ])),
    ]));
  }

  Widget _buildFamilyGroup() {
    const members = [
      ('You', 'https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg?auto=compress&cs=tinysrgb&w=200'),
      ('Emma', 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=200'),
      ('Dad', 'https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=200'),
      ('Mom', 'https://images.pexels.com/photos/3184405/pexels-photo-3184405.jpeg?auto=compress&cs=tinysrgb&w=200'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _pink.withValues(alpha: 0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        ...members.map((m) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(children: [
            ClipOval(child: CachedNetworkImage(imageUrl: m.$2, width: 48, height: 48, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: _pink.withValues(alpha: 0.15), width: 48, height: 48,
                    child: const Icon(Icons.person_rounded, color: Color(0xFF9CA3AF), size: 24)),
                errorWidget: (_, __, ___) => Container(color: _pink.withValues(alpha: 0.15), width: 48, height: 48,
                    child: const Icon(Icons.person_rounded, color: Color(0xFF9CA3AF), size: 24)))),
            const SizedBox(height: 5),
            Text(m.$1, style: TextStyle(color: _textSecondary, fontSize: 11)),
          ]),
        )),
        GestureDetector(
          onTap: () {},
          child: Column(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle,
                color: _pink.withValues(alpha: 0.1), border: Border.all(color: _pink.withValues(alpha: 0.3), width: 1.5, style: BorderStyle.solid)),
                child: Icon(Icons.add_rounded, color: _pink, size: 22)),
            const SizedBox(height: 5),
            Text('Invite', style: TextStyle(color: _pink, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSharedGoal(String title, double progress, String current, String target, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: TextStyle(color: _textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600))),
          Text('${(progress * 100).round()}%', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFE8EAF0),
                valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 5)),
        const SizedBox(height: 6),
        Row(children: [
          Text(current, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(' of $target', style: TextStyle(color: _textSecondary, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _buildSharedBudget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        Row(children: [
          Text('Monthly Family Budget', style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('\$5,200', style: TextStyle(color: _pink, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        ...(['Groceries', 'Utilities', 'Kids Activities', 'Entertainment']).asMap().entries.map((e) {
          final colors = [const Color(0xFF14B8A6), const Color(0xFF6366F1), const Color(0xFFF59E0B), const Color(0xFFEF4444)];
          final vals = [0.78, 0.65, 0.40, 0.55];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              SizedBox(width: 100, child: Text(e.value, style: TextStyle(color: _textSecondary, fontSize: 12))),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(value: vals[e.key], backgroundColor: const Color(0xFFE8EAF0),
                      valueColor: AlwaysStoppedAnimation<Color>(colors[e.key]), minHeight: 5))),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildMomentsFeed() {
    const moments = [
      ('Weekend hike with the family 🏔️', 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400'),
      ('Game night at home 🎲', 'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=400'),
    ];
    return Column(children: moments.map((m) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      height: 140,
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Stack(fit: StackFit.expand, children: [
        CachedNetworkImage(imageUrl: m.$2, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: _pink.withValues(alpha: 0.1)),
            errorWidget: (_, __, ___) => Container(color: _pink.withValues(alpha: 0.1))),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)]))),
        Positioned(bottom: 12, left: 14, child: Text(m.$1,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
      ])),
    )).toList());
  }

  Widget _sectionTitle(String t) => Text(t, style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w700));
}
