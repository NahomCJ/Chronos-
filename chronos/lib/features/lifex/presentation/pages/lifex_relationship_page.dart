import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXRelationshipPage extends StatefulWidget {
  const LifeXRelationshipPage({super.key});

  @override
  State<LifeXRelationshipPage> createState() => _LifeXRelationshipPageState();
}

class _LifeXRelationshipPageState extends State<LifeXRelationshipPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _bg = Color(0xFF0D0D22);
  static const _card = Color(0xFF0F0F1C);

  static const _sharedGoals = [
    _SharedGoal('Italy Trip 2025', '\$3,200', '\$5,000', 0.64),
    _SharedGoal('Joint Emergency Fund', '\$6,500', '\$10,000', 0.65),
    _SharedGoal('New Apartment Deposit', '\$1,800', '\$4,000', 0.45),
  ];

  static const _subscriptions = [
    _SharedSub('Netflix', '\$15.99'),
    _SharedSub('Spotify', '\$9.99'),
    _SharedSub('Amazon Prime', '\$14.99'),
    _SharedSub('Hulu', '\$17.99'),
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
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Shared Finance'),
                Tab(text: 'Dates & Plans'),
                Tab(text: 'Subscriptions'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
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
            _buildSharedFinanceTab(),
            _buildDatesTab(),
            _buildSubscriptionsTab(),
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
              'https://images.pexels.com/photos/1128318/pexels-photo-1128318.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: Colors.white.withValues(alpha: 0.06)),
          errorWidget: (_, __, ___) =>
              Container(color: Colors.white.withValues(alpha: 0.06)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                _bg.withValues(alpha: 0.97),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 54,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your\nRelationships',
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

  // ── OVERVIEW TAB ─────────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSharedOverview(),
          const SizedBox(height: 20),
          _sectionTitle('Explore Relationships'),
          const SizedBox(height: 12),
          _OverviewLink(
            icon: Icons.savings_rounded,
            title: 'Shared Finance',
            subtitle: '${_sharedGoals.length} joint goals in progress',
            onTap: () => _tabs.animateTo(1),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.event_rounded,
            title: 'Dates & Plans',
            subtitle: 'Plan a date night, track upcoming occasions',
            onTap: () => _tabs.animateTo(2),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.subscriptions_rounded,
            title: 'Subscriptions',
            subtitle: '${_subscriptions.length} shared subscriptions',
            onTap: () => _tabs.animateTo(3),
          ),
        ],
      ),
    );
  }

  // ── SHARED FINANCE TAB ───────────────────────────────────────────────────────

  Widget _buildSharedFinanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSharedOverview(),
          const SizedBox(height: 22),
          _sectionTitle('Shared Goals'),
          const SizedBox(height: 12),
          ..._sharedGoals.map((g) => _SharedGoalCard(goal: g)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Text('Add Shared Goal',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
          ),
          const SizedBox(height: 20),
          _buildChrisNudge(
              "You and your partner are 64% of the way to your Italy trip fund. At your current pace, you'll hit it by March 2025."),
        ],
      ),
    );
  }

  Widget _buildSharedOverview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.10),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1),
          ),
          child: Row(children: [
            Expanded(
                child: _overviewStat(
                    'Shared Saved', '\$11,500', const Color(0xFF22C55E))),
            Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
                child: _overviewStat(
                    'Joint Goals', '3', Colors.white)),
            Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
                child: _overviewStat(
                    'Subs Overlap', '\$58/mo', const Color(0xFFF59E0B))),
          ]),
        ),
      ),
    );
  }

  Widget _overviewStat(String label, String val, Color color) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
          textAlign: TextAlign.center),
    ]);
  }

  // ── DATES TAB ────────────────────────────────────────────────────────────────

  Widget _buildDatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateIdeaCard(),
          const SizedBox(height: 22),
          _sectionTitle('Upcoming Dates'),
          const SizedBox(height: 12),
          _buildUpcomingDate('Anniversary Dinner', 'Jun 28', '\$120 budget',
              Icons.dinner_dining_rounded),
          _buildUpcomingDate("Partner's Birthday", 'Jul 4', '\$200 budget',
              Icons.cake_rounded),
          const SizedBox(height: 20),
          _sectionTitle('Gift Budget Planner'),
          const SizedBox(height: 12),
          _buildGiftBudget(),
        ],
      ),
    );
  }

  Widget _buildDateIdeaCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Plan a Date Night",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Text('Chris suggests ideas in your budget',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12)),
              const SizedBox(height: 14),
              Row(children: [
                _dateBudget('Under \$50'),
                const SizedBox(width: 8),
                _dateBudget('\$50 – \$100'),
                const SizedBox(width: 8),
                _dateBudget('\$100+'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateBudget(String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildUpcomingDate(String title, String date, String budget,
      IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600)),
            Text('$date · $budget',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('Plan',
              style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildGiftBudget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      child: Column(children: [
        Row(children: [
          const Text('Monthly Gift Budget',
              style: TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Text('\$200',
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.60,
            backgroundColor: Colors.white.withValues(alpha: 0.10),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Text('\$120 used',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
          const Spacer(),
          const Text('\$80 remaining',
              style: TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }

  // ── SUBSCRIPTIONS TAB ────────────────────────────────────────────────────────

  Widget _buildSubscriptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubsOverview(),
          const SizedBox(height: 22),
          _sectionTitle('Shared Subscriptions'),
          const SizedBox(height: 12),
          ..._subscriptions.map((s) => _SubCard(sub: s)),
          const SizedBox(height: 20),
          _buildChrisNudge(
              "You and your partner both pay for Spotify separately — that's \$10/mo wasted. Switch to Spotify Duo and save \$120/year."),
        ],
      ),
    );
  }

  Widget _buildSubsOverview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1),
          ),
          child: Row(children: [
            Expanded(
                child: _overviewStat(
                    'Joint Subs', '\$58.96/mo', Colors.white)),
            Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
                child: _overviewStat('Overlap Waste', '\$9.99/mo',
                    const Color(0xFFEF4444))),
            Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
                child: _overviewStat('Yearly',
                    '\$707.52', const Color(0xFFF59E0B))),
          ]),
        ),
      ),
    );
  }

  Widget _buildChrisNudge(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1)),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Chris says',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(text,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12.5,
                      height: 1.5)),
            ])),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
}

// ── Overview link card ────────────────────────────────────────────────────────

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

// ── Shared goal card ──────────────────────────────────────────────────────────

class _SharedGoalCard extends StatelessWidget {
  final _SharedGoal goal;
  const _SharedGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08)),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 17)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(goal.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600))),
          Text('${(goal.progress * 100).round()}%',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: Colors.white.withValues(alpha: 0.10),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Text(goal.current,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          Text(' of ${goal.target}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        ]),
      ]),
    );
  }
}

// ── Subscription card ─────────────────────────────────────────────────────────

class _SubCard extends StatelessWidget {
  final _SharedSub sub;
  const _SubCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child:
              const Icon(Icons.subscriptions_rounded, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(sub.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600))),
        Text(sub.price,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(width: 6),
        Text('/mo',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
      ]),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _SharedGoal {
  final String title;
  final String current;
  final String target;
  final double progress;
  const _SharedGoal(this.title, this.current, this.target, this.progress);
}

class _SharedSub {
  final String name;
  final String price;
  const _SharedSub(this.name, this.price);
}
