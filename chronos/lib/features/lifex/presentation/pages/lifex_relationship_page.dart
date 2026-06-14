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

  static const _bg = Color(0xFF0F060A);
  static const _card = Color(0xFF1A0C14);
  static const _pink = Color(0xFFEC4899);
  static const _pinkLight = Color(0xFFF472B6);

  static const _sharedGoals = [
    _SharedGoal('Italy Trip 2025', '\$3,200', '\$5,000', Color(0xFFF97316), 0.64),
    _SharedGoal('Joint Emergency Fund', '\$6,500', '\$10,000', Color(0xFF10B981), 0.65),
    _SharedGoal('New Apartment Deposit', '\$1,800', '\$4,000', Color(0xFF3B82F6), 0.45),
  ];

  static const _subscriptions = [
    _SharedSub('Netflix', '\$15.99', Color(0xFFEF4444)),
    _SharedSub('Spotify', '\$9.99', Color(0xFF10B981)),
    _SharedSub('Amazon Prime', '\$14.99', Color(0xFFF59E0B)),
    _SharedSub('Hulu', '\$17.99', Color(0xFF8B5CF6)),
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
            expandedHeight: 230,
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
              tabs: const [
                Tab(text: 'Shared Finance'),
                Tab(text: 'Dates & Plans'),
                Tab(text: 'Subscriptions'),
              ],
              labelColor: _pink,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _pink,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
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
              Container(color: _pink.withValues(alpha: 0.15)),
          errorWidget: (_, __, ___) =>
              Container(color: _pink.withValues(alpha: 0.15)),
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
              _tag(Icons.favorite_border_rounded, 'RELATIONSHIP DOMAIN', _pink),
              const SizedBox(height: 10),
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

  Widget _tag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
      ]),
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
                    color: _pink.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: _pink.withValues(alpha: 0.05),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: _pink, size: 18),
                    const SizedBox(width: 8),
                    const Text('Add Shared Goal',
                        style: TextStyle(
                            color: _pink,
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
                _pink.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _pink.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(children: [
            Expanded(
                child: _overviewStat(
                    'Shared Saved', '\$11,500', const Color(0xFF10B981))),
            Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
                child: _overviewStat(
                    'Joint Goals', '3', _pink)),
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
              Icons.dinner_dining_rounded, const Color(0xFFF59E0B)),
          _buildUpcomingDate("Partner's Birthday", 'Jul 4', '\$200 budget',
              Icons.cake_rounded, const Color(0xFFEC4899)),
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
                _pink.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _pink.withValues(alpha: 0.25), width: 1),
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
            color: _pink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: _pink.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: _pinkLight, fontSize: 11, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildUpcomingDate(String title, String date, String budget,
      IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: color, size: 18),
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
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Plan',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
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
        border: Border.all(color: _pink.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(children: [
        Row(children: [
          const Text('Monthly Gift Budget',
              style: TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Text('\$200',
              style: TextStyle(
                  color: _pinkLight, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.60,
            backgroundColor: _pink.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(_pink),
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
                  color: _pinkLight, fontSize: 11, fontWeight: FontWeight.w600)),
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
                _pink.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _pink.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(children: [
            Expanded(
                child: _overviewStat(
                    'Joint Subs', '\$58.96/mo', _pink)),
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
              color: _pink.withValues(alpha: 0.12),
              border:
                  Border.all(color: _pink.withValues(alpha: 0.4), width: 1)),
          child: const Icon(Icons.auto_awesome_rounded, color: _pink, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Chris says',
                  style: TextStyle(
                      color: _pinkLight,
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
        color: const Color(0xFF1A0C14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goal.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goal.color.withValues(alpha: 0.12)),
              child: Icon(Icons.flag_rounded, color: goal.color, size: 17)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(goal.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600))),
          Text('${(goal.progress * 100).round()}%',
              style: TextStyle(
                  color: goal.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: goal.color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(goal.color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Text(goal.current,
              style: TextStyle(
                  color: goal.color,
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
        color: const Color(0xFF1A0C14),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: sub.color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: sub.color.withValues(alpha: 0.12),
          ),
          child:
              Icon(Icons.subscriptions_rounded, color: sub.color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(sub.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600))),
        Text(sub.price,
            style: TextStyle(
                color: sub.color, fontSize: 14, fontWeight: FontWeight.w800)),
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
  final Color color;
  final double progress;
  const _SharedGoal(
      this.title, this.current, this.target, this.color, this.progress);
}

class _SharedSub {
  final String name;
  final String price;
  final Color color;
  const _SharedSub(this.name, this.price, this.color);
}
