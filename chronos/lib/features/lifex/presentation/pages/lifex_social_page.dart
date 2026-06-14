import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXSocialPage extends StatefulWidget {
  const LifeXSocialPage({super.key});

  @override
  State<LifeXSocialPage> createState() => _LifeXSocialPageState();
}

class _LifeXSocialPageState extends State<LifeXSocialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final Set<String> _joinedGroups = {};

  static const _bg = Color(0xFF0F0608);
  static const _card = Color(0xFF1A090C);
  static const _red = Color(0xFFEF4444);
  static const _redLight = Color(0xFFF87171);

  static const _interestCategories = [
    _InterestCat('Outdoor & Nature', Icons.terrain_rounded, Color(0xFF10B981),
        '2.4K members',
        'https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _InterestCat('Food & Dining', Icons.restaurant_rounded, Color(0xFFF59E0B),
        '5.1K members',
        'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _InterestCat('Sports & Fitness', Icons.sports_basketball_rounded,
        Color(0xFF3B82F6), '3.8K members',
        'https://images.pexels.com/photos/863988/pexels-photo-863988.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _InterestCat('Arts & Culture', Icons.palette_rounded, Color(0xFF8B5CF6),
        '1.9K members',
        'https://images.pexels.com/photos/1183992/pexels-photo-1183992.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _InterestCat('Gaming', Icons.sports_esports_rounded, Color(0xFF06B6D4),
        '4.2K members',
        'https://images.pexels.com/photos/442576/pexels-photo-442576.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _InterestCat('Volunteering', Icons.volunteer_activism_rounded,
        Color(0xFFEC4899), '890 members',
        'https://images.pexels.com/photos/6646918/pexels-photo-6646918.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _InterestCat('Networking', Icons.handshake_rounded, Color(0xFF14B8A6),
        '3.3K members',
        'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _InterestCat('Travel', Icons.flight_rounded, Color(0xFFF97316),
        '6.7K members',
        'https://images.pexels.com/photos/1285625/pexels-photo-1285625.jpeg?auto=compress&cs=tinysrgb&w=400'),
  ];

  static const _upcomingEvents = [
    _Event('Rooftop Dinner', 'Sat, Jun 21', '7:00 PM', 4,
        Color(0xFFF59E0B), Icons.restaurant_rounded, '\$35/person'),
    _Event('Hiking Trail Run', 'Sun, Jun 22', '8:00 AM', 6,
        Color(0xFF10B981), Icons.terrain_rounded, 'Free'),
    _Event('Game Night', 'Fri, Jun 27', '8:00 PM', 8,
        Color(0xFF06B6D4), Icons.sports_esports_rounded, 'Free'),
  ];

  static const _billSplits = [
    _BillSplit('Cabo Trip Expenses', '\$1,240', 5, Color(0xFFF97316),
        'In progress'),
    _BillSplit("Alex's Birthday Dinner", '\$312', 8, Color(0xFF10B981),
        'Settled'),
    _BillSplit('Airbnb – Memorial Weekend', '\$680', 4, Color(0xFF3B82F6),
        "You're owed \$170"),
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
                Tab(text: 'Group Planner'),
                Tab(text: 'Communities'),
                Tab(text: 'Bill Split'),
              ],
              labelColor: _red,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _red,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildGroupPlannerTab(),
            _buildCommunitiesTab(),
            _buildBillSplitTab(),
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
              'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: _red.withValues(alpha: 0.15)),
          errorWidget: (_, __, ___) =>
              Container(color: _red.withValues(alpha: 0.15)),
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
              _tag(Icons.group_rounded, 'SOCIAL DOMAIN', _red),
              const SizedBox(height: 10),
              Text('Your Social\nUniverse',
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

  // ── GROUP PLANNER TAB ────────────────────────────────────────────────────────

  Widget _buildGroupPlannerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreateEventCard(),
          const SizedBox(height: 22),
          _sectionTitle('Upcoming Events'),
          const SizedBox(height: 12),
          ..._upcomingEvents.map((e) => _EventCard(event: e)),
          const SizedBox(height: 20),
          _buildChrisNudge(
              "You've had 2 events this month. Staying socially active is one of the strongest predictors of long-term wellbeing."),
        ],
      ),
    );
  }

  Widget _buildCreateEventCard() {
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
                _red.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _red.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Plan Something Together',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                  'Create an event, invite your people, split costs seamlessly.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12.5,
                      height: 1.45)),
              const SizedBox(height: 16),
              Row(children: [
                _quickPlan('Dinner', Icons.restaurant_rounded,
                    const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _quickPlan(
                    'Trip', Icons.flight_rounded, const Color(0xFFF97316)),
                const SizedBox(width: 8),
                _quickPlan('Game Night', Icons.sports_esports_rounded,
                    const Color(0xFF06B6D4)),
                const SizedBox(width: 8),
                _quickPlan('Other', Icons.add_rounded, _red),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickPlan(String label, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
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
              color: _red.withValues(alpha: 0.12),
              border:
                  Border.all(color: _red.withValues(alpha: 0.4), width: 1)),
          child:
              const Icon(Icons.auto_awesome_rounded, color: _red, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Chris says',
                  style: TextStyle(
                      color: _redLight,
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

  // ── COMMUNITIES TAB ──────────────────────────────────────────────────────────

  Widget _buildCommunitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommunitiesHeader(),
          const SizedBox(height: 18),
          _sectionTitle('Browse by Interest'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: _interestCategories.length,
            itemBuilder: (ctx, i) {
              final cat = _interestCategories[i];
              final joined = _joinedGroups.contains(cat.name);
              return _InterestCard(
                cat: cat,
                joined: joined,
                onJoin: () => setState(() {
                  if (joined) {
                    _joinedGroups.remove(cat.name);
                  } else {
                    _joinedGroups.add(cat.name);
                  }
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitiesHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _red.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: _red.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Find Your People',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Text('Join groups that match your vibe',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12)),
            ]),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Explore',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ),
    );
  }

  // ── BILL SPLIT TAB ───────────────────────────────────────────────────────────

  Widget _buildBillSplitTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSplitSummaryCard(),
          const SizedBox(height: 22),
          _sectionTitle('Recent Splits'),
          const SizedBox(height: 12),
          ..._billSplits.map((s) => _BillSplitCard(split: s)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: _red.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: _red.withValues(alpha: 0.05),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: _red, size: 18),
                    const SizedBox(width: 8),
                    const Text('New Bill Split',
                        style: TextStyle(
                            color: _red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
          ),
          const SizedBox(height: 20),
          _buildChrisNudge(
              "You're owed \$170 from the Airbnb weekend. Settling through Chronos takes 10 seconds."),
        ],
      ),
    );
  }

  Widget _buildSplitSummaryCard() {
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
                _red.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _red.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(children: [
            Expanded(
                child: _splitStat(
                    "You're Owed", '\$170', const Color(0xFF10B981))),
            Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(child: _splitStat('You Owe', '\$0', Colors.white54)),
            Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(child: _splitStat('Active', '2', _red)),
          ]),
        ),
      ),
    );
  }

  Widget _splitStat(String label, String val, Color color) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: color, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
          textAlign: TextAlign.center),
    ]);
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
}

// ── Event card ────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final _Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A090C),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: event.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: event.color.withValues(alpha: 0.15),
            border: Border.all(
                color: event.color.withValues(alpha: 0.4), width: 1),
          ),
          child: Icon(event.icon, color: event.color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(event.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text('${event.date} · ${event.time}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.group_rounded,
                  color: Colors.white.withValues(alpha: 0.35), size: 13),
              const SizedBox(width: 4),
              Text('${event.people} people',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11)),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(event.cost,
                    style: TextStyle(
                        color: event.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: event.color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('Join',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ── Interest category card ────────────────────────────────────────────────────

class _InterestCard extends StatelessWidget {
  final _InterestCat cat;
  final bool joined;
  final VoidCallback onJoin;

  const _InterestCard({
    required this.cat,
    required this.joined,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onJoin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: cat.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: cat.color.withValues(alpha: 0.2)),
              errorWidget: (_, __, ___) =>
                  Container(color: cat.color.withValues(alpha: 0.2)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cat.color.withValues(alpha: 0.1),
                    const Color(0xFF0F0608).withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cat.color.withValues(alpha: 0.2),
                        border: Border.all(
                            color: cat.color.withValues(alpha: 0.5), width: 1),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 15),
                    ),
                    const Spacer(),
                    if (joined)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Joined',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                  ]),
                  const Spacer(),
                  Text(cat.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                      maxLines: 2),
                  const SizedBox(height: 2),
                  Text(cat.members,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bill split card ───────────────────────────────────────────────────────────

class _BillSplitCard extends StatelessWidget {
  final _BillSplit split;
  const _BillSplitCard({required this.split});

  @override
  Widget build(BuildContext context) {
    final settled = split.status == 'Settled';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A090C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: split.color.withValues(alpha: settled ? 0.1 : 0.25),
            width: 1),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: split.color.withValues(alpha: 0.12),
          ),
          child: Icon(Icons.receipt_long_rounded, color: split.color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(split.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.group_rounded,
                  color: Colors.white.withValues(alpha: 0.35), size: 12),
              const SizedBox(width: 4),
              Text('${split.people} people',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(split.total,
              style: TextStyle(
                  color: split.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: settled
                  ? Colors.white.withValues(alpha: 0.05)
                  : split.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(split.status,
                style: TextStyle(
                    color: settled ? Colors.white38 : split.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _InterestCat {
  final String name;
  final IconData icon;
  final Color color;
  final String members;
  final String imageUrl;
  const _InterestCat(
      this.name, this.icon, this.color, this.members, this.imageUrl);
}

class _Event {
  final String title;
  final String date;
  final String time;
  final int people;
  final Color color;
  final IconData icon;
  final String cost;
  const _Event(this.title, this.date, this.time, this.people, this.color,
      this.icon, this.cost);
}

class _BillSplit {
  final String title;
  final String total;
  final int people;
  final Color color;
  final String status;
  const _BillSplit(
      this.title, this.total, this.people, this.color, this.status);
}
