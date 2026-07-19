import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXFamilyPage extends StatefulWidget {
  const LifeXFamilyPage({super.key});

  @override
  State<LifeXFamilyPage> createState() => _LifeXFamilyPageState();
}

class _LifeXFamilyPageState extends State<LifeXFamilyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _bg = Color(0xFF0D0D22);
  static const _card = Color(0xFF0F0F1C);
  static const _accent = Colors.white;

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
      floatingActionButton: Container(margin: const EdgeInsets.only(bottom: 30), child: const ChrisHomeFab()),
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero(context)),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Group'),
                Tab(text: 'Goals & Budget'),
                Tab(text: 'Moments'),
              ],
              labelColor: _accent,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _accent,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildOverviewTab(),
            _buildGroupTab(),
            _buildGoalsBudgetTab(),
            _buildMomentsTab(),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('4 people in your family group',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('3 shared goals in progress · \$5,200/mo shared budget',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Explore Family'),
          const SizedBox(height: 12),
          _OverviewLink(
            icon: Icons.people_alt_rounded,
            title: 'Group',
            subtitle: 'Members, invites & who\'s connected',
            onTap: () => _tabs.animateTo(1),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.savings_rounded,
            title: 'Goals & Budget',
            subtitle: 'Shared savings goals and the monthly budget',
            onTap: () => _tabs.animateTo(2),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.photo_library_rounded,
            title: 'Moments',
            subtitle: 'Recent family photos & updates',
            onTap: () => _tabs.animateTo(3),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(height: 240, child: Stack(fit: StackFit.expand, children: [
      CachedNetworkImage(
        imageUrl: 'https://images.pexels.com/photos/1128318/pexels-photo-1128318.jpeg?auto=compress&cs=tinysrgb&w=900',
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.white.withValues(alpha: 0.06)),
        errorWidget: (_, __, ___) => Container(color: Colors.white.withValues(alpha: 0.06)),
      ),
      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.2), _bg.withValues(alpha: 0.97)]))),
      Positioned(bottom: 24, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your People', style: TextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
      ])),
    ]));
  }

  // ── Group Tab ──────────────────────────────────────────────

  Widget _buildGroupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Family Group'),
        const SizedBox(height: 14),
        _buildFamilyGroup(),
      ]),
    );
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1)),
      child: Row(children: [
        ...members.map((m) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(children: [
            ClipOval(child: CachedNetworkImage(imageUrl: m.$2, width: 48, height: 48, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.white.withValues(alpha: 0.10), width: 48, height: 48,
                    child: const Icon(Icons.person_rounded, color: Colors.white38, size: 24)),
                errorWidget: (_, __, ___) => Container(color: Colors.white.withValues(alpha: 0.10), width: 48, height: 48,
                    child: const Icon(Icons.person_rounded, color: Colors.white38, size: 24)))),
            const SizedBox(height: 5),
            Text(m.$1, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
          ]),
        )),
        GestureDetector(
          onTap: () {},
          child: Column(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08), border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5, style: BorderStyle.solid)),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 22)),
            const SizedBox(height: 5),
            const Text('Invite', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  // ── Goals & Budget Tab ──────────────────────────────────────────────

  Widget _buildGoalsBudgetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Shared Goals'),
        const SizedBox(height: 14),
        _buildSharedGoal('Family Vacation to Japan', 0.62, '\$3,720', '\$6,000'),
        _buildSharedGoal('New Family Car', 0.35, '\$7,000', '\$20,000'),
        _buildSharedGoal('Kids Education Fund', 0.48, '\$12,000', '\$25,000'),
        const SizedBox(height: 22),
        _sectionTitle('Shared Budget'),
        const SizedBox(height: 14),
        _buildSharedBudget(),
      ]),
    );
  }

  Widget _buildSharedGoal(String title, double progress, String current, String target) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600))),
          Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 5)),
        const SizedBox(height: 6),
        Row(children: [
          Text(current, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(' of $target', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _buildSharedBudget() {
    const neutral = Color(0xFFC7CAD3);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1)),
      child: Column(children: [
        Row(children: [
          const Text('Monthly Family Budget', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Text('\$5,200', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        ...(['Groceries', 'Utilities', 'Kids Activities', 'Entertainment']).asMap().entries.map((e) {
          final vals = [0.78, 0.65, 0.40, 0.55];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              SizedBox(width: 100, child: Text(e.value, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12))),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(value: vals[e.key], backgroundColor: neutral.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(neutral), minHeight: 5))),
            ]),
          );
        }),
      ]),
    );
  }

  // ── Moments Tab ──────────────────────────────────────────────

  Widget _buildMomentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Family Moments'),
        const SizedBox(height: 14),
        _buildMomentsFeed(),
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
            placeholder: (_, __) => Container(color: Colors.white.withValues(alpha: 0.06)),
            errorWidget: (_, __, ___) => Container(color: Colors.white.withValues(alpha: 0.06))),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)]))),
        Positioned(bottom: 12, left: 14, child: Text(m.$1,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
      ])),
    )).toList());
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
