import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';

class LifeXSocialPage extends StatefulWidget {
  const LifeXSocialPage({super.key});

  @override
  State<LifeXSocialPage> createState() => _LifeXSocialPageState();
}

class _LifeXSocialPageState extends State<LifeXSocialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final Set<String> _joinedGroups = {};
  final Set<String> _invitedFriends = {};

  static const _friendSuggestions = [
    _Friend('Marcus Webb', '@marcusw', 'Sports & Fitness',
        'https://images.pexels.com/photos/3768911/pexels-photo-3768911.jpeg?auto=compress&cs=tinysrgb&w=100'),
    _Friend('Aisha Cole', '@aishac', 'Food & Dining',
        'https://images.pexels.com/photos/3822906/pexels-photo-3822906.jpeg?auto=compress&cs=tinysrgb&w=100'),
    _Friend('Derek Kim', '@derekk', 'Outdoor & Nature',
        'https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg?auto=compress&cs=tinysrgb&w=100'),
    _Friend('Sofia Reyes', '@sofiar', 'Arts & Culture',
        'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=100'),
    _Friend('James Okonkwo', '@jameso', 'Gaming',
        'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=100'),
  ];

  static const _bg = Color(0xFF0A0608);
  static const _card = Color(0xFF130910);
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
  ];

  static const _upcomingEvents = [
    _Event('Rooftop Dinner', 'Sat, Jun 21', '7:00 PM', 4,
        Color(0xFFF59E0B), Icons.restaurant_rounded, r'$35/person',
        'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _Event('Hiking Trail Run', 'Sun, Jun 22', '8:00 AM', 6,
        Color(0xFF10B981), Icons.terrain_rounded, 'Free',
        'https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&w=400'),
    _Event('Game Night', 'Fri, Jun 27', '8:00 PM', 8,
        Color(0xFF06B6D4), Icons.sports_esports_rounded, 'Free',
        'https://images.pexels.com/photos/442576/pexels-photo-442576.jpeg?auto=compress&cs=tinysrgb&w=400'),
  ];

  static const _billSplits = [
    _BillSplit('Cabo Trip Expenses', r'$1,240', 5, Color(0xFFF97316), 'In progress'),
    _BillSplit("Alex's Birthday Dinner", r'$312', 8, Color(0xFF10B981), 'Settled'),
    _BillSplit('Airbnb – Memorial Weekend', r'$680', 4, Color(0xFF3B82F6), "You're owed \$170"),
  ];

  static const _activityFeed = [
    _Activity('Marcus W.', 'created "Cabo Trip" · 5 members joining',
        Icons.flight_rounded, Color(0xFFF97316), '2h ago'),
    _Activity('You', 'joined Rooftop Dinner · Jun 21',
        Icons.restaurant_rounded, Color(0xFFF59E0B), '5h ago'),
    _Activity('Aisha C.', 'split \$312 dinner bill · settled',
        Icons.receipt_long_rounded, Color(0xFF10B981), 'Yesterday'),
    _Activity('Derek K.', 'posted in Sports & Fitness group',
        Icons.sports_basketball_rounded, Color(0xFF3B82F6), 'Yesterday'),
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
            expandedHeight: 240,
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: _bg,
                child: TabBar(
                  controller: _tabs,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Events'),
                    Tab(text: 'Bills'),
                  ],
                  labelColor: _red,
                  unselectedLabelColor: Colors.white38,
                  indicatorColor: _red,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildOverviewTab(),
            _buildEventsTab(),
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
                Colors.black.withValues(alpha: 0.4),
                _bg.withValues(alpha: 0.98),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tag(Icons.group_rounded, 'SOCIAL DOMAIN', _red),
              const SizedBox(height: 10),
              const Text('Your Social\nUniverse',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      height: 1.1)),
              const SizedBox(height: 6),
              Row(children: [
                _pillStat('60', 'Score', _red),
                const SizedBox(width: 10),
                _pillStat('3', 'Groups', const Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                _pillStat('2', 'Events', const Color(0xFF10B981)),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pillStat(String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(val,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.75),
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ]),
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

  // ── OVERVIEW TAB ─────────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpendingCard(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 22),
          _sectionTitle('Next Up'),
          const SizedBox(height: 12),
          _buildNextEventCard(_upcomingEvents[0]),
          const SizedBox(height: 22),
          _sectionTitle('Friend Activity'),
          const SizedBox(height: 12),
          ..._activityFeed.map((a) => _ActivityTile(activity: a)),
          const SizedBox(height: 22),
          _sectionTitle('Discover Groups'),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _interestCategories.length,
              itemBuilder: (_, i) {
                final cat = _interestCategories[i];
                final joined = _joinedGroups.contains(cat.name);
                return _GroupChip(
                  cat: cat,
                  joined: joined,
                  onTap: () => setState(() {
                    if (joined) {
                      _joinedGroups.remove(cat.name);
                    } else {
                      _joinedGroups.add(cat.name);
                    }
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          _buildChrisNudge(
              "You've had 2 social events this month. Your most active friends are Marcus and Aisha — consider planning something this weekend."),
        ],
      ),
    );
  }

  Widget _buildSpendingCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _red.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _red.withValues(alpha: 0.28), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Social Spending',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                _tag(Icons.calendar_month_rounded, 'THIS MONTH', _red),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _spendStat(r'$165', 'Dining out',
                        const Color(0xFFF59E0B))),
                _vDivider(),
                Expanded(
                    child: _spendStat(r'$85', 'Entertainment',
                        const Color(0xFF8B5CF6))),
                _vDivider(),
                Expanded(
                    child: _spendStat(r'$210', 'Travel/trips',
                        const Color(0xFF3B82F6))),
              ]),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total social spend',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12)),
                  const Text(r'$460 / mo',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spendStat(String val, String label, Color color) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              height: 1.3)),
    ]);
  }

  Widget _vDivider() => Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.07));

  void _showInviteFriendsSheet() {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF130910),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final filtered = _friendSuggestions
              .where((f) =>
                  searchQuery.isEmpty ||
                  f.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  f.handle.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Invite Friends',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Friends on Chronos can join your plans & split bills.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search by name or @handle',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.white.withValues(alpha: 0.3), size: 18),
                    ),
                    onChanged: (v) => setSheetState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(height: 14),
                ...filtered.map((f) {
                  final sent = _invitedFriends.contains(f.handle);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: f.avatarUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                color: _red.withValues(alpha: 0.2),
                                child: const Icon(Icons.person_rounded,
                                    color: Colors.white54, size: 22)),
                            errorWidget: (_, __, ___) => Container(
                                color: _red.withValues(alpha: 0.2),
                                child: const Icon(Icons.person_rounded,
                                    color: Colors.white54, size: 22)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text(f.handle,
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (sent) {
                                _invitedFriends.remove(f.handle);
                              } else {
                                _invitedFriends.add(f.handle);
                              }
                            });
                            setSheetState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: sent
                                  ? _red.withValues(alpha: 0.12)
                                  : _red,
                              borderRadius: BorderRadius.circular(12),
                              border: sent
                                  ? Border.all(
                                      color: _red.withValues(alpha: 0.4))
                                  : null,
                            ),
                            child: Text(
                              sent ? 'Invited ✓' : 'Invite',
                              style: TextStyle(
                                  color: sent ? _red : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _red.withValues(alpha: 0.3), width: 1),
                      borderRadius: BorderRadius.circular(14),
                      color: _red.withValues(alpha: 0.06),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded, color: _red, size: 16),
                        SizedBox(width: 8),
                        Text('Share Invite Link',
                            style: TextStyle(
                                color: _red,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      ('Plan Event', Icons.event_rounded, const Color(0xFFF59E0B), null),
      ('Split Bill', Icons.receipt_long_rounded, const Color(0xFF10B981), null),
      ('Find Group', Icons.group_add_rounded, const Color(0xFF3B82F6), null),
      ('Invite', Icons.person_add_rounded, _red, _showInviteFriendsSheet),
    ];
    return Row(
      children: actions.map((a) {
        final (label, icon, color, onTap) = a;
        return Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(
                  right: a == actions.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: color.withValues(alpha: 0.22), width: 1),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNextEventCard(_Event event) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: event.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: event.color.withValues(alpha: 0.2)),
              errorWidget: (_, __, ___) =>
                  Container(color: event.color.withValues(alpha: 0.2)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: event.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(event.cost,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 6),
                      Text(event.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                          '${event.date} · ${event.time} · ${event.people} going',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Join',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
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
            Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _red.withValues(alpha: 0.12),
              border:
                  Border.all(color: _red.withValues(alpha: 0.4), width: 1)),
          child: const Icon(Icons.auto_awesome_rounded, color: _red, size: 15),
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

  // ── EVENTS TAB ───────────────────────────────────────────────────────────────

  Widget _buildEventsTab() {
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
                child: _splitStat("You're Owed", r'$170',
                    const Color(0xFF10B981))),
            _vDivider(),
            Expanded(child: _splitStat('You Owe', r'$0', Colors.white54)),
            _vDivider(),
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

// ── Activity tile ─────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  final _Activity activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF130910),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activity.color.withValues(alpha: 0.14),
            border: Border.all(
                color: activity.color.withValues(alpha: 0.35), width: 1),
          ),
          child: Icon(activity.icon, color: activity.color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${activity.name} ',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: activity.action,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(activity.time,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 11)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Group chip (horizontal) ───────────────────────────────────────────────────

class _GroupChip extends StatelessWidget {
  final _InterestCat cat;
  final bool joined;
  final VoidCallback onTap;
  const _GroupChip(
      {required this.cat, required this.joined, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: cat.color.withValues(alpha: 0.1),
          border: Border.all(
              color: cat.color.withValues(alpha: joined ? 0.6 : 0.2),
              width: joined ? 1.5 : 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: cat.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: cat.color.withValues(alpha: 0.15)),
                errorWidget: (_, __, ___) =>
                    Container(color: cat.color.withValues(alpha: 0.15)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(cat.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(cat.members,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 9)),
                    if (joined)
                      const SizedBox(height: 4),
                    if (joined)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cat.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Joined',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700)),
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

// ── Event card ────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final _Event event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF130910),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: event.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(children: [
        // Left color bar
        Container(
          width: 4,
          height: 80,
          decoration: BoxDecoration(
            color: event.color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(event.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${event.date} · ${event.time}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12)),
              const SizedBox(height: 5),
              Row(children: [
                Icon(Icons.group_rounded,
                    color: Colors.white.withValues(alpha: 0.35), size: 13),
                const SizedBox(width: 4),
                Text('${event.people} going',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11)),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.14),
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
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        ),
      ]),
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
        color: const Color(0xFF130910),
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
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11)),
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
          Text(split.status,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
              textAlign: TextAlign.end),
        ]),
      ]),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _InterestCat {
  final String name;
  final IconData icon;
  final Color color;
  final String members;
  final String imageUrl;
  const _InterestCat(this.name, this.icon, this.color, this.members, this.imageUrl);
}

class _Event {
  final String title;
  final String date;
  final String time;
  final int people;
  final Color color;
  final IconData icon;
  final String cost;
  final String imageUrl;
  const _Event(this.title, this.date, this.time, this.people, this.color,
      this.icon, this.cost, this.imageUrl);
}

class _BillSplit {
  final String title;
  final String total;
  final int people;
  final Color color;
  final String status;
  const _BillSplit(this.title, this.total, this.people, this.color, this.status);
}

class _Activity {
  final String name;
  final String action;
  final IconData icon;
  final Color color;
  final String time;
  const _Activity(this.name, this.action, this.icon, this.color, this.time);
}

class _Friend {
  final String name;
  final String handle;
  final String interest;
  final String avatarUrl;
  const _Friend(this.name, this.handle, this.interest, this.avatarUrl);
}
