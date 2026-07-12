import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';
import '../../data/lifex_service.dart';

final NumberFormat _moneyFormat = NumberFormat('#,##0.00');
final NumberFormat _moneyFormatWhole = NumberFormat('#,##0');
String _money(double value) => '\$${_moneyFormat.format(value)}';
String _moneyWhole(double value) => '\$${_moneyFormatWhole.format(value)}';

class LifeXSpiritualPage extends StatefulWidget {
  const LifeXSpiritualPage({super.key});

  @override
  State<LifeXSpiritualPage> createState() => _LifeXSpiritualPageState();
}

class _LifeXSpiritualPageState extends State<LifeXSpiritualPage>
    with TickerProviderStateMixin {
  late TabController _tabs;
  late AnimationController _breathCtrl;
  late final LifeXService _api;
  bool _isBreathing = false;
  int _selectedMeditation = 0;
  bool _isProcessingPayment = false;
  final Map<String, int> _cart = {};

  static const _bg = Color(0xFF0D0D22);
  static const _card = Color(0xFF0F0F1C);
  static const _purple = Colors.white;
  static const _purpleLight = Colors.white70;

  static const _meditations = [
    _Meditation('Morning Calm', '10 min', 'Guided',
        'https://images.pexels.com/photos/1761279/pexels-photo-1761279.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFFFFFFFF)),
    _Meditation('Stress Relief', '15 min', 'Breathing',
        'https://images.pexels.com/photos/355465/pexels-photo-355465.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFFFFFFFF)),
    _Meditation('Sleep Well', '20 min', 'Body Scan',
        'https://images.pexels.com/photos/1252890/pexels-photo-1252890.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFFFFFFFF)),
    _Meditation('Focus Flow', '8 min', 'Breath Work',
        'https://images.pexels.com/photos/2775196/pexels-photo-2775196.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFFFFFFFF)),
  ];

  static const _gratitudes = [
    'I\'m grateful for my health and energy today',
    'The people in my life who support me unconditionally',
    'New opportunities that are appearing in my path',
  ];

  static const _goals = [
    _SpiritualGoal('Meditate 21 days straight', 14, 21, Color(0xFFFFFFFF)),
    _SpiritualGoal('Daily gratitude for 30 days', 22, 30, Color(0xFFFFFFFF)),
    _SpiritualGoal('Read spiritual text weekly', 3, 4, Color(0xFFFFFFFF)),
  ];

  static const _charities = [
    _Charity('Local Food Bank', 'Community', 25,
        Icons.restaurant_rounded, Color(0xFFFFFFFF)),
    _Charity('Child Education Fund', 'Education', 30,
        Icons.school_rounded, Color(0xFFFFFFFF)),
    _Charity('Disaster Relief', 'Emergency Aid', 15,
        Icons.volunteer_activism_rounded, Color(0xFFFFFFFF)),
  ];

  static const _campaigns = [
    _Campaign('Rebuild Grace Chapel Roof', 'Community', 45000, 28900,
        'https://images.pexels.com/photos/208283/pexels-photo-208283.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Campaign('Ramadan Food Drive', 'Relief', 20000, 14200,
        'https://images.pexels.com/photos/6994982/pexels-photo-6994982.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Campaign('Youth Mission Trip Fund', 'Youth', 12000, 5400,
        'https://images.pexels.com/photos/8617779/pexels-photo-8617779.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ];

  static const _trips = [
    _Trip('Holy Land Pilgrimage', 'Jerusalem, Israel', 'Christian · Jewish', 2450,
        'https://images.pexels.com/photos/3225531/pexels-photo-3225531.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Trip('Hajj Support Journey', 'Mecca, Saudi Arabia', 'Islam', 3800,
        'https://images.pexels.com/photos/1537086/pexels-photo-1537086.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Trip('Buddhist Silent Retreat', 'Kyoto, Japan', 'Buddhism', 1690,
        'https://images.pexels.com/photos/161401/pexels-photo-161401.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Trip('Camino de Santiago Walk', 'Northern Spain', 'Any faith', 2100,
        'https://images.pexels.com/photos/2422915/pexels-photo-2422915.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ];

  static const _products = [
    _Product('Study Bible (NIV)', 'Books', 34.99,
        'https://images.pexels.com/photos/207662/pexels-photo-207662.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Product('Quran with Translation', 'Books', 29.99,
        'https://images.pexels.com/photos/8154671/pexels-photo-8154671.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Product('Prayer Beads', 'Accessories', 14.99,
        'https://images.pexels.com/photos/6787202/pexels-photo-6787202.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _Product('Devotional Candle Set', 'Home', 22.50,
        'https://images.pexels.com/photos/6957091/pexels-photo-6957091.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ];

  static const _events = [
    _SpiritEvent('Sunday Worship Service', 'Christian', 'Every Sunday · 10:00 AM',
        'https://images.pexels.com/photos/208216/pexels-photo-208216.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _SpiritEvent('Friday Jumu\'ah Prayer', 'Islam', 'Every Friday · 1:00 PM',
        'https://images.pexels.com/photos/1537086/pexels-photo-1537086.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _SpiritEvent('Shabbat Dinner Gathering', 'Judaism', 'Every Friday · Sunset',
        'https://images.pexels.com/photos/6994982/pexels-photo-6994982.jpeg?auto=compress&cs=tinysrgb&w=600'),
    _SpiritEvent('Community Meditation Circle', 'All faiths', 'Wednesdays · 7:00 PM',
        'https://images.pexels.com/photos/1051838/pexels-photo-1051838.jpeg?auto=compress&cs=tinysrgb&w=600'),
  ];

  @override
  void initState() {
    super.initState();
    _api = GetIt.I<LifeXService>();
    _tabs = TabController(length: 6, vsync: this);
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

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? const Color(0xFFEF4444) : _purple,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _runPayment(Future<void> Function() action, String successMessage) async {
    setState(() => _isProcessingPayment = true);
    try {
      await action();
      _showSnack(successMessage);
    } catch (e) {
      _showSnack('That didn\'t go through: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  void _showAmountSheet({
    required String title,
    required List<double> presets,
    required Future<void> Function(double amount) onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AmountSheet(title: title, presets: presets, onConfirm: onConfirm),
    );
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
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Practice'),
                Tab(text: 'Giving'),
                Tab(text: 'Trips'),
                Tab(text: 'Shop'),
                Tab(text: 'Events'),
              ],
              labelColor: _purple,
              unselectedLabelColor: Colors.white54,
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
            _buildOverviewTab(),
            _buildPracticeTab(),
            _buildGivingTab(),
            _buildTripsTab(),
            _buildShopTab(),
            _buildEventsTab(),
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
        Positioned(
          bottom: 56,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('21-day streak',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${_goals.length} goals in progress · ${_charities.length} causes you support',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Explore Spiritual'),
          const SizedBox(height: 12),
          _OverviewLink(
            icon: Icons.self_improvement_rounded,
            title: 'Practice',
            subtitle: 'Meditation, breathing & gratitude journal',
            onTap: () => _tabs.animateTo(1),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.volunteer_activism_rounded,
            title: 'Giving',
            subtitle: '${_charities.length} causes you can support',
            onTap: () => _tabs.animateTo(2),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.flight_takeoff_rounded,
            title: 'Trips',
            subtitle: 'Retreats & spiritual travel',
            onTap: () => _tabs.animateTo(3),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.shopping_bag_rounded,
            title: 'Shop',
            subtitle: 'Books, journals & mindfulness tools',
            onTap: () => _tabs.animateTo(4),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.event_rounded,
            title: 'Events',
            subtitle: 'Upcoming gatherings near you',
            onTap: () => _tabs.animateTo(5),
          ),
        ],
      ),
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
                const Color(0xFFFFFFFF).withValues(alpha: 0.06),
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
                        _chip('360 mins', const Color(0xFFFFFFFF)),
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
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: _purple.withValues(alpha: 0.2), width: 1),
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

  // ── Giving Tab (charities + crowdfunding campaigns) ─────────────

  Widget _buildGivingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Give to a Charity'),
          const SizedBox(height: 6),
          Text('Real transfer from your Chronos wallet, processed instantly.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._charities.map((c) => _CharityTile(
                charity: c,
                busy: _isProcessingPayment,
                onGive: () => _showAmountSheet(
                  title: 'Give to ${c.name}',
                  presets: [c.suggested, c.suggested * 2, c.suggested * 4],
                  onConfirm: (amount) => _runPayment(
                    () => _api.donate({
                      'charityName': c.name,
                      'category': c.category,
                      'amount': amount,
                    }),
                    'Thank you! \$${amount.toStringAsFixed(0)} sent to ${c.name}.',
                  ),
                ),
              )),
          const SizedBox(height: 24),
          _sectionTitle('Crowdfunding Campaigns'),
          const SizedBox(height: 6),
          Text('Community causes raising money right now.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._campaigns.map((c) => _CampaignCard(
                campaign: c,
                busy: _isProcessingPayment,
                onContribute: () => _showAmountSheet(
                  title: 'Contribute to ${c.title}',
                  presets: const [25, 50, 100],
                  onConfirm: (amount) => _runPayment(
                    () => _api.contributeToCampaign({
                      'campaignTitle': c.title,
                      'campaignCategory': c.category,
                      'amount': amount,
                    }),
                    'Contributed \$${amount.toStringAsFixed(0)} to ${c.title}.',
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ── Trips Tab ─────────────────────────────────────────────────

  Widget _buildTripsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Spiritual Trips'),
          const SizedBox(height: 6),
          Text('Pilgrimages and retreats booked through Chronos.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._trips.map((t) => _TripCard(
                trip: t,
                busy: _isProcessingPayment,
                onBook: () => _showAmountSheet(
                  title: 'Book ${t.title}',
                  presets: [t.price],
                  onConfirm: (amount) => _runPayment(
                    () => _api.bookTrip({
                      'tripTitle': t.title,
                      'destination': t.destination,
                      'travelers': 1,
                      'totalAmount': amount,
                    }),
                    'Trip booked: ${t.title}. Safe travels!',
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ── Shop Tab (ecommerce) ──────────────────────────────────────

  Widget _buildShopTab() {
    final cartTotal = _cart.entries.fold<double>(0, (sum, e) {
      final p = _products.firstWhere((p) => p.name == e.key);
      return sum + p.price * e.value;
    });

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Spiritual Shop'),
              const SizedBox(height: 6),
              Text('Books and devotional goods, checked out through your wallet.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemCount: _products.length,
                itemBuilder: (_, i) {
                  final p = _products[i];
                  return _ProductCard(
                    product: p,
                    qty: _cart[p.name] ?? 0,
                    onAdd: () => setState(() => _cart[p.name] = (_cart[p.name] ?? 0) + 1),
                    onRemove: () => setState(() {
                      final qty = (_cart[p.name] ?? 0) - 1;
                      if (qty <= 0) {
                        _cart.remove(p.name);
                      } else {
                        _cart[p.name] = qty;
                      }
                    }),
                  );
                },
              ),
            ],
          ),
        ),
        if (_cart.isNotEmpty)
          Positioned(
            left: 18,
            right: 18,
            bottom: 24,
            child: GestureDetector(
              onTap: _isProcessingPayment
                  ? null
                  : () => _runPayment(() async {
                        final items = _cart.entries.map((e) {
                          final p = _products.firstWhere((p) => p.name == e.key);
                          return {'name': p.name, 'price': p.price, 'qty': e.value};
                        }).toList();
                        await _api.checkoutSpiritualShop({'items': items});
                        setState(() => _cart.clear());
                      }, 'Order placed!'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: _purple.withValues(alpha: 0.4), blurRadius: 20),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Checkout · ${_cart.values.fold(0, (a, b) => a + b)} items',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    if (_isProcessingPayment)
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    else
                      Text(_money(cartTotal),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Events Tab (informational calendar) ──────────────────────

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Upcoming Events'),
          const SizedBox(height: 6),
          Text('Filtered to your faith once you set it in Profile.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._events.map((e) => _EventCard(event: e)),
        ],
      ),
    );
  }

  // ── Anchor helpers kept for future use by Practice/devotional widgets ──

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
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
  final String name, category;
  final double suggested;
  final IconData icon;
  final Color color;
  const _Charity(this.name, this.category, this.suggested, this.icon, this.color);
}

class _Campaign {
  final String title, category, imageUrl;
  final double goal, raised;
  const _Campaign(this.title, this.category, this.goal, this.raised, this.imageUrl);
}

class _Trip {
  final String title, destination, faithTag, imageUrl;
  final double price;
  const _Trip(this.title, this.destination, this.faithTag, this.price, this.imageUrl);
}

class _Product {
  final String name, category, imageUrl;
  final double price;
  const _Product(this.name, this.category, this.price, this.imageUrl);
}

class _SpiritEvent {
  final String title, faithTag, schedule, imageUrl;
  const _SpiritEvent(this.title, this.faithTag, this.schedule, this.imageUrl);
}

// ── Widgets ───────────────────────────────────────────────────────────────────

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
        color: const Color(0xFF0F0F1C),
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
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          const Text('🙏', style: TextStyle(fontSize: 18)),
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

class _CharityTile extends StatelessWidget {
  final _Charity charity;
  final bool busy;
  final VoidCallback onGive;
  const _CharityTile({required this.charity, required this.busy, required this.onGive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: charity.color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: charity.color.withValues(alpha: 0.12),
            ),
            child: Icon(charity.icon, color: charity.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(charity.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
                Text(charity.category,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: busy ? null : onGive,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: charity.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: charity.color.withValues(alpha: 0.4), width: 1),
              ),
              child: Text('Give',
                  style: TextStyle(
                      color: charity.color, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final _Campaign campaign;
  final bool busy;
  final VoidCallback onContribute;
  const _CampaignCard({required this.campaign, required this.busy, required this.onContribute});

  @override
  Widget build(BuildContext context) {
    final pct = (campaign.raised / campaign.goal).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: campaign.imageUrl,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 110, color: const Color(0xFF0F0F1C)),
              errorWidget: (_, __, ___) => Container(height: 110, color: const Color(0xFF0F0F1C)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(campaign.title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_moneyWhole(campaign.raised)} raised of ${_moneyWhole(campaign.goal)}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
                    GestureDetector(
                      onTap: busy ? null : onContribute,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Contribute',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final _Trip trip;
  final bool busy;
  final VoidCallback onBook;
  const _TripCard({required this.trip, required this.busy, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: trip.imageUrl,
              width: 100,
              height: 110,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(width: 100, height: 110, color: const Color(0xFF0F0F1C)),
              errorWidget: (_, __, ___) => Container(width: 100, height: 110, color: const Color(0xFF0F0F1C)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(trip.destination,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
                  Text(trip.faithTag,
                      style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${trip.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      GestureDetector(
                        onTap: busy ? null : onBook,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Book',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _Product product;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _ProductCard({required this.product, required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFF0F0F1C)),
                errorWidget: (_, __, ___) => Container(color: const Color(0xFF0F0F1C)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 12, fontWeight: FontWeight.w700)),
                    qty == 0
                        ? GestureDetector(
                            onTap: onAdd,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(color: Color(0xFFFFFFFF), shape: BoxShape.circle),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                            ),
                          )
                        : Row(
                            children: [
                              GestureDetector(
                                onTap: onRemove,
                                child: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 18),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              GestureDetector(
                                onTap: onAdd,
                                child: const Icon(Icons.add_circle, color: Color(0xFFFFFFFF), size: 18),
                              ),
                            ],
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final _SpiritEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: CachedNetworkImage(
              imageUrl: event.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(width: 72, height: 72, color: const Color(0xFF0F0F1C)),
              errorWidget: (_, __, ___) => Container(width: 72, height: 72, color: const Color(0xFF0F0F1C)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(event.schedule,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
                  const SizedBox(height: 3),
                  Text(event.faithTag,
                      style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountSheet extends StatefulWidget {
  final String title;
  final List<double> presets;
  final Future<void> Function(double amount) onConfirm;
  const _AmountSheet({required this.title, required this.presets, required this.onConfirm});

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late double _selected;
  final _customCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.presets.first;
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        color: const Color(0xFF0F0F1C),
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 30),
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
            Text(widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              children: widget.presets.map((p) {
                final isSelected = _selected == p && _customCtrl.text.isEmpty;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selected = p;
                    _customCtrl.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFFFFF) : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('\$${p.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Colors.white, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _customCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Custom amount',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                prefixText: '\$ ',
                prefixStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _submitting
                  ? null
                  : () async {
                      final custom = double.tryParse(_customCtrl.text);
                      final amount = custom ?? _selected;
                      if (amount <= 0) return;
                      setState(() => _submitting = true);
                      await widget.onConfirm(amount);
                      if (context.mounted) Navigator.pop(context);
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: _submitting
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirm',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
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
        color: const Color(0xFF0F0F1C),
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
                  color: const Color(0xFFFFFFFF),
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
