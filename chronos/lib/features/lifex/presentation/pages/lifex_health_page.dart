import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/services/pexels_service.dart';
import '../../data/lifex_service.dart';

final NumberFormat _moneyFormat = NumberFormat('#,##0.00');
final NumberFormat _moneyFormatWhole = NumberFormat('#,##0');
String _money(double value) => '\$${_moneyFormat.format(value)}';
String _moneyWhole(double value) => '\$${_moneyFormatWhole.format(value)}';

class LifeXHealthPage extends StatefulWidget {
  const LifeXHealthPage({super.key});

  @override
  State<LifeXHealthPage> createState() => _LifeXHealthPageState();
}

class _LifeXHealthPageState extends State<LifeXHealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late final LifeXService _api;
  bool _busy = false;

  Map<String, dynamic>? _hsa;
  List<dynamic> _insights = [];
  List<dynamic> _myInsurance = [];
  List<dynamic> _myNutrition = [];
  List<dynamic> _myWearables = [];

  List<PexelsPhoto> _gymPhotos = [];
  List<PexelsPhoto> _techPhotos = [];

  // Neutral palette — one primary (white) and one secondary (light gray)
  // accent used everywhere on this page, instead of a different color per
  // item (gym/insurer/wearable brand colors, a page-wide green/teal theme).
  static const _bg = Color(0xFF0D0D22);
  static const _card = Color(0xFF0F0F1C);
  static const _accent = Colors.white;

  static const _metrics = [
    _Metric('Steps', '7,430', '/10k', Icons.directions_walk_rounded),
    _Metric('Heart Rate', '72', 'bpm', Icons.favorite_rounded),
    _Metric('Sleep', '7.2', 'hrs', Icons.bedtime_rounded),
  ];

  static const _insurancePlans = [
    _InsurancePlan('Chronos Basic Health', 'UnitedHealth', 'health', 145, '\$1,500 deductible · PPO', Icons.local_hospital_rounded),
    _InsurancePlan('Chronos Family Plus', 'Blue Cross', 'health', 320, '\$500 deductible · Family PPO', Icons.family_restroom_rounded),
    _InsurancePlan('SmileCare Dental', 'Delta Dental', 'dental', 28, 'Preventive + major coverage', Icons.sentiment_satisfied_rounded),
    _InsurancePlan('ClearView Vision', 'VSP', 'vision', 12, 'Annual exam + frames allowance', Icons.visibility_rounded),
  ];

  static const _gyms = [
    _Gym('Equinox Flatiron', 'New York', '15% partner discount', 4.8, Icons.fitness_center_rounded),
    _Gym('Chelsea Piers Fitness', 'New York', '10% partner discount', 4.5, Icons.pool_rounded),
    _Gym('Equinox SoMa', 'San Francisco', '15% partner discount', 4.7, Icons.fitness_center_rounded),
    _Gym('Crunch Fitness Castro', 'San Francisco', '20% partner discount', 4.3, Icons.sports_rounded),
  ];

  static const _nutritionPartners = [
    _NutritionPartner('MyFitnessPal', 'Food & calorie logging', 'calorie-tracking', Icons.restaurant_menu_rounded),
    _NutritionPartner('Noom', 'Behavioral weight loss coaching', 'coaching', Icons.psychology_rounded),
    _NutritionPartner('Lose It!', 'Meal planning & tracking', 'meal-planning', Icons.local_dining_rounded),
  ];

  static const _wearableProviders = [
    _WearableProvider('apple_health', 'Apple Health', Icons.watch_rounded),
    _WearableProvider('fitbit', 'Fitbit', Icons.monitor_heart_rounded),
    _WearableProvider('garmin', 'Garmin', Icons.timer_rounded),
    _WearableProvider('google_fit', 'Google Fit', Icons.directions_run_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _api = GetIt.I<LifeXService>();
    _tabs = TabController(length: 4, vsync: this);
    _loadAll();
    _loadPhotos();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    final results = await Future.wait([
      PexelsService.searchPhotos('modern gym interior', perPage: 6),
      PexelsService.searchPhotos('fitness tracker smartwatch', perPage: 4),
    ]);
    if (!mounted) return;
    setState(() {
      _gymPhotos = results[0];
      _techPhotos = results[1];
    });
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        _api.getHsa(),
        _api.healthInsights(),
        _api.myInsurance(),
        _api.myNutritionConnections(),
        _api.myWearableConnections(),
      ]);
      if (!mounted) return;
      setState(() {
        _hsa = results[0] as Map<String, dynamic>?;
        _insights = results[1] as List<dynamic>;
        _myInsurance = results[2] as List<dynamic>;
        _myNutrition = results[3] as List<dynamic>;
        _myWearables = results[4] as List<dynamic>;
      });
    } catch (_) {
      // Degrade gracefully — page still works with mock catalogs if the
      // backend is unreachable.
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF1C1C2E),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _runAction(Future<void> Function() action, String successMessage) async {
    setState(() => _busy = true);
    try {
      await action();
      _showSnack(successMessage);
      await _loadAll();
    } catch (e) {
      _showSnack('That didn\'t go through: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showHsaSheet({required bool isDeposit}) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            color: _card,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isDeposit ? 'Deposit to HSA' : 'Withdraw from HSA',
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(ctrl.text);
                      if (amount == null || amount <= 0) return;
                      Navigator.pop(context);
                      _runAction(
                        () => isDeposit ? _api.depositHsa(amount) : _api.withdrawHsa(amount),
                        isDeposit ? 'Deposited \$${amount.toStringAsFixed(0)} to your HSA.' : 'Withdrew \$${amount.toStringAsFixed(0)} from your HSA.',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            expandedHeight: 140,
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
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Insurance'),
                Tab(text: 'Gyms'),
                Tab(text: 'Connected Apps'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildOverviewTab(),
            _buildInsuranceTab(),
            _buildGymsTab(),
            _buildConnectedAppsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.06), _bg],
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Your Health\nAccount',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    height: 1.1)),
          ],
        ),
      ),
    );
  }

  // ── Overview: HSA + guidance + vitals + an invitation into every other
  // section on this page, so Overview is a real summary of everything Health
  // has to offer, not just the account balance. ─────────────────────────

  Widget _buildOverviewTab() {
    final balance = (_hsa?['balance'] as num?)?.toDouble() ?? 0.0;
    final contributions = (_hsa?['contributions'] as num?)?.toDouble() ?? 0.0;

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHsaCard(balance, contributions),
            const SizedBox(height: 18),
            if (_insights.isNotEmpty) ...[
              _sectionTitle('Chris\'s Guidance'),
              const SizedBox(height: 12),
              ..._insights.map((i) => _InsightCard(insight: i as Map<String, dynamic>)),
              const SizedBox(height: 18),
            ],
            _sectionTitle('Today\'s Vitals'),
            const SizedBox(height: 5),
            Text('A quick glance — full tracking lives in Connected Apps.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
            const SizedBox(height: 12),
            Row(
              children: _metrics
                  .map((m) => Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _MetricChip(metric: m),
                      )))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Explore Health'),
            const SizedBox(height: 12),
            _OverviewLink(
              icon: Icons.local_hospital_rounded,
              title: 'Insurance',
              subtitle: '${_insurancePlans.length} plans available · ${_myInsurance.length} enrolled',
              onTap: () => _tabs.animateTo(1),
            ),
            const SizedBox(height: 10),
            _OverviewLink(
              icon: Icons.fitness_center_rounded,
              title: 'Gyms',
              subtitle: '${_gyms.length} partner gyms with member discounts',
              onTap: () => _tabs.animateTo(2),
            ),
            const SizedBox(height: 10),
            _OverviewLink(
              icon: Icons.watch_rounded,
              title: 'Connected Apps',
              subtitle: '${_wearableProviders.length + _nutritionPartners.length} trackers & nutrition partners',
              onTap: () => _tabs.animateTo(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHsaCard(double balance, double contributions) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.02)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.savings_rounded, color: _accent, size: 18),
                  const SizedBox(width: 8),
                  const Text('Health Savings Account',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              Text(_money(balance),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              Text('${_money(contributions)} contributed all-time',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : () => _showHsaSheet(isDeposit: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Deposit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => _showHsaSheet(isDeposit: false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Insurance Marketplace ─────────────────────────────────────

  Widget _buildInsuranceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Insurance Marketplace'),
          const SizedBox(height: 6),
          Text('Compare plans and enroll — Chris tailors picks to your profile over time.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._insurancePlans.map((p) => _InsurancePlanCard(
                plan: p,
                enrolled: _myInsurance.any((e) => e['planName'] == p.name),
                busy: _busy,
                onEnroll: () => _runAction(
                  () => _api.enrollInsurance({
                    'provider': p.provider,
                    'planName': p.name,
                    'coverageType': p.coverageType,
                    'monthlyPremium': p.monthlyPremium,
                  }),
                  'Enrolled in ${p.name}.',
                ),
              )),
        ],
      ),
    );
  }

  // ── Gym Partnerships ──────────────────────────────────────────

  Widget _buildGymsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Gym Partnerships'),
          const SizedBox(height: 6),
          Text('New York & San Francisco partner gyms with a Chronos discount.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._gyms.asMap().entries.map((e) => _GymCard(
                gym: e.value,
                imageUrl: _gymPhotos.isNotEmpty
                    ? _gymPhotos[e.key % _gymPhotos.length].large
                    : null,
                onRefer: () => _showSnack('Referral applied — show this at ${e.value.name} front desk for ${e.value.discount}.'),
                onMap: () => _showSnack('Opening ${e.value.name} in Maps — coming soon.'),
              )),
        ],
      ),
    );
  }

  // ── Connected Apps: wearables + nutrition partners ────────────

  Widget _buildConnectedAppsTab() {
    final heroImage = _techPhotos.isNotEmpty ? _techPhotos.first.large : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heroImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(heroImage, height: 110, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 14),
          ],
          _sectionTitle('Fitness Trackers & Smartwatches'),
          const SizedBox(height: 6),
          Text('Connect once — Chris pulls your metrics automatically after that.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._wearableProviders.map((w) {
            final connection = _myWearables.firstWhere(
              (c) => c['provider'] == w.id,
              orElse: () => null,
            );
            return _WearableTile(
              provider: w,
              connected: connection != null,
              busy: _busy,
              onConnect: () => _runAction(() => _api.connectWearable(w.id), '${w.name} connected.'),
              onSync: connection == null
                  ? null
                  : () => _runAction(
                      () => _syncSampleMetrics(w.id),
                      'Synced the latest metrics from ${w.name}.',
                    ),
            );
          }),
          const SizedBox(height: 24),
          _sectionTitle('Nutrition & Diet Partners'),
          const SizedBox(height: 6),
          Text('Follow a diet plan through a partner app — we track your progress here too.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          const SizedBox(height: 14),
          ..._nutritionPartners.map((p) => _NutritionPartnerTile(
                partner: p,
                connected: _myNutrition.any((c) => c['partnerName'] == p.name),
                busy: _busy,
                onConnect: () => _runAction(
                  () => _api.connectNutritionPartner({'partnerName': p.name, 'category': p.category}),
                  'Connected to ${p.name}.',
                ),
              )),
        ],
      ),
    );
  }

  // No live device SDK integration yet — pushes a realistic-looking sample
  // reading through the same sync endpoint a real device integration would
  // use, so the rest of the pipeline (HealthMetric storage, insights) is
  // exercised end-to-end.
  Future<void> _syncSampleMetrics(String provider) async {
    final now = DateTime.now().toIso8601String();
    await _api.syncWearableMetrics({
      'provider': provider,
      'metrics': [
        {'metricType': 'steps', 'value': 6200 + (DateTime.now().millisecond % 3000), 'unit': 'count', 'recordedAt': now},
        {'metricType': 'heart_rate', 'value': 68 + (DateTime.now().second % 12), 'unit': 'bpm', 'recordedAt': now},
        {'metricType': 'sleep', 'value': 6.5 + (DateTime.now().second % 3), 'unit': 'hrs', 'recordedAt': now},
      ],
    });
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700));
  }
}

// ── Data models ────────────────────────────────────────────────────

class _Metric {
  final String label, value, unit;
  final IconData icon;
  const _Metric(this.label, this.value, this.unit, this.icon);
}

class _InsurancePlan {
  final String name, provider, coverageType, description;
  final double monthlyPremium;
  final IconData icon;
  const _InsurancePlan(this.name, this.provider, this.coverageType, this.monthlyPremium, this.description, this.icon);
}

class _Gym {
  final String name, city, discount;
  final double rating;
  final IconData icon;
  const _Gym(this.name, this.city, this.discount, this.rating, this.icon);
}

class _NutritionPartner {
  final String name, description, category;
  final IconData icon;
  const _NutritionPartner(this.name, this.description, this.category, this.icon);
}

class _WearableProvider {
  final String id, name;
  final IconData icon;
  const _WearableProvider(this.id, this.name, this.icon);
}

// ── Widgets ────────────────────────────────────────────────────────

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

class _InsightCard extends StatelessWidget {
  final Map<String, dynamic> insight;
  const _InsightCard({required this.insight});

  Color get _color {
    switch (insight['severity']) {
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'good':
        return const Color(0xFF10B981);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: _color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(insight['message'] as String? ?? '',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final _Metric metric;
  const _MetricChip({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      child: Column(
        children: [
          Icon(metric.icon, color: Colors.white, size: 18),
          const SizedBox(height: 6),
          Text(metric.value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          Text('${metric.label} ${metric.unit}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 9), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _InsurancePlanCard extends StatelessWidget {
  final _InsurancePlan plan;
  final bool enrolled;
  final bool busy;
  final VoidCallback onEnroll;
  const _InsurancePlanCard({required this.plan, required this.enrolled, required this.busy, required this.onEnroll});

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            child: Icon(plan.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                Text('${plan.provider} · ${plan.description}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_moneyWhole(plan.monthlyPremium)}/mo',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              GestureDetector(
                onTap: (busy || enrolled) ? null : onEnroll,
                child: Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: enrolled ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(enrolled ? 'Enrolled' : 'Enroll',
                      style: TextStyle(
                          color: enrolled ? Colors.white70 : Colors.black, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GymCard extends StatelessWidget {
  final _Gym gym;
  final String? imageUrl;
  final VoidCallback onRefer;
  final VoidCallback onMap;
  const _GymCard({required this.gym, required this.imageUrl, required this.onRefer, required this.onMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: imageUrl != null
                ? Image.network(imageUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _gymImageFallback())
                : _gymImageFallback(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gym.name, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.white70, size: 13),
                    const SizedBox(width: 3),
                    Text('${gym.rating}', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                    Text('  ·  ${gym.city}', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                  ],
                ),
                Text(gym.discount, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onRefer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Get Referral', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onMap,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                        ),
                        child: const Icon(Icons.map_outlined, color: Colors.white, size: 18),
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

  Widget _gymImageFallback() {
    return Container(
      color: Colors.white.withValues(alpha: 0.06),
      child: Center(child: Icon(gym.icon, color: Colors.white38, size: 32)),
    );
  }
}

class _WearableTile extends StatelessWidget {
  final _WearableProvider provider;
  final bool connected;
  final bool busy;
  final VoidCallback onConnect;
  final VoidCallback? onSync;
  const _WearableTile({required this.provider, required this.connected, required this.busy, required this.onConnect, required this.onSync});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: connected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            child: Icon(provider.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(provider.name, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
          ),
          if (connected && onSync != null)
            GestureDetector(
              onTap: busy ? null : onSync,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.sync_rounded, color: Colors.white70, size: 18),
              ),
            ),
          GestureDetector(
            onTap: (busy || connected) ? null : onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: connected ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(connected ? 'Connected' : 'Connect',
                  style: TextStyle(color: connected ? Colors.white70 : Colors.black, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionPartnerTile extends StatelessWidget {
  final _NutritionPartner partner;
  final bool connected;
  final bool busy;
  final VoidCallback onConnect;
  const _NutritionPartnerTile({required this.partner, required this.connected, required this.busy, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: connected ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
            child: Icon(partner.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner.name, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
                Text(partner.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: (busy || connected) ? null : onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: connected ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(connected ? 'Connected' : 'Connect',
                  style: TextStyle(color: connected ? Colors.white70 : Colors.black, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
