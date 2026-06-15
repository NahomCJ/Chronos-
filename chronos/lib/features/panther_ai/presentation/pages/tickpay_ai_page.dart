import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/services/pexels_service.dart';
import '../../domain/entities/spending_summary.dart';
import '../bloc/spending_bloc.dart';
import '../bloc/spending_event.dart';
import '../bloc/spending_state.dart';

class TickPayAiPage extends StatefulWidget {
  const TickPayAiPage({super.key});

  @override
  State<TickPayAiPage> createState() => _TickPayAiPageState();
}

class _TickPayAiPageState extends State<TickPayAiPage>
    with SingleTickerProviderStateMixin {
  late final SpendingBloc _spendingBloc;
  late TabController _tabCtrl;
  bool _remindersOn = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    final now = DateTime.now();
    _spendingBloc = GetIt.I<SpendingBloc>()
      ..add(SpendingSummaryLoadRequested(month: now.month, year: now.year));
  }

  @override
  void dispose() {
    _spendingBloc.close();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _spendingBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildHomeTab(),
                    _buildPlansTab(),
                    _buildRewardsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3F4F6),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF374151), size: 14),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF20C55D), Color(0xFF0A8E42)]),
            ),
            child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TickPay', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 18, fontWeight: FontWeight.w700)),
                Text('Buy Now, Pay Later · 0% APR', style: TextStyle(color: Color(0xFF20C55D), fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          _chip(Icons.notifications_active_rounded, '1 due', const Color(0xFFF0B100)),
          const SizedBox(width: 8),
          _chip(Icons.account_balance_wallet_outlined, 'Wallet', Colors.white),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 0.6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: const Color(0xFF374151), fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(colors: [Color(0xFF20C55D), Color(0xFF0A8E42)]),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF6B7080),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'My Plans'),
            Tab(text: 'Rewards'),
          ],
        ),
      ),
    );
  }

  // ── HOME TAB ───────────────────────────────────────────────────────────────

  Widget _buildHomeTab() {
    return BlocBuilder<SpendingBloc, SpendingState>(
      builder: (context, state) {
        final summary = state is SpendingLoaded ? state.summary : null;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreditCard(),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildDueSoonAlert(),
              const SizedBox(height: 20),
              _sectionLabel('Active Plans'),
              const SizedBox(height: 12),
              _buildActivePlanCard('Nike Air Max 270', 'Afterpay', 3, 4, '\$262.50', '\$87.50', const Color(0xFF00D4FF), PexelsService.photoUrl(1598505, w: 120, h: 120)),
              const SizedBox(height: 10),
              _buildActivePlanCard('AirPods Pro', 'Klarna', 2, 3, '\$124.50', '\$62.25', const Color(0xFF20C55D), PexelsService.photoUrl(3394650, w: 120, h: 120)),
              const SizedBox(height: 10),
              _buildActivePlanCard('Zara Jacket', 'Afterpay', 2, 4, '\$89.75', '\$44.88', const Color(0xFFDC8F4A), PexelsService.photoUrl(1536619, w: 120, h: 120)),
              const SizedBox(height: 20),
              _buildChrisInsight(summary),
              const SizedBox(height: 20),
              _buildRemindersToggle(),
              const SizedBox(height: 20),
              _buildDiscover(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreditCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              PexelsService.photoUrl(3769747, w: 800, h: 360),
              fit: BoxFit.cover,
              loadingBuilder: (_, child, p) => p == null ? child : Container(color: const Color(0xFF1A3D2B)),
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A3D2B)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A8E42).withValues(alpha: 0.80),
                    const Color(0xFF064022).withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF20C55D).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF20C55D).withValues(alpha: 0.5), width: 0.6),
                        ),
                        child: const Text('TICKPAY CREDIT', style: TextStyle(color: Color(0xFF20C55D), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      ),
                      const Text('0% APR', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Spacer(),
                  const Text('\$2,500.00', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
                  const SizedBox(height: 2),
                  Text('Available credit · Pay over time, interest-free', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _miniStat('First Payment', 'Jun 15'),
                      const SizedBox(width: 20),
                      _miniStat('Next Payment', 'Jul 15'),
                      const SizedBox(width: 20),
                      _miniStat('3 payments', 'remaining'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 9)),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.shopping_bag_outlined, 'Shop', const Color(0xFF20C55D), () => context.push(RouteConstants.productDiscovery.toPath)),
      (Icons.payment_outlined, 'Pay', const Color(0xFF00D4FF), null),
      (Icons.receipt_long_outlined, 'Orders', const Color(0xFFDC8F4A), null),
      (Icons.replay_outlined, 'Repay', const Color(0xFFE879F9), null),
      (Icons.card_giftcard_outlined, 'Rewards', const Color(0xFFF0B100), () => _tabCtrl.animateTo(2)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) => GestureDetector(
        onTap: a.$4,
        child: Column(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: a.$3.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: a.$3.withValues(alpha: 0.3), width: 0.7),
            ),
            child: Icon(a.$1, color: a.$3, size: 22),
          ),
          const SizedBox(height: 6),
          Text(a.$2, style: const TextStyle(color: Color(0xFF374151), fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      )).toList(),
    );
  }

  Widget _buildDueSoonAlert() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0B100).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0B100).withValues(alpha: 0.3), width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF0B100).withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.access_time_rounded, color: Color(0xFFF0B100), size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Payment Due Soon', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 13, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('Nike payment of \$87.50 is due on Jun 15', style: TextStyle(color: Color(0xFF6B7080), fontSize: 11)),
            ]),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0B100).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF0B100).withValues(alpha: 0.4), width: 0.5),
              ),
              child: const Text('Pay Now', style: TextStyle(color: Color(0xFFF0B100), fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(String name, String provider, int paid, int total, String totalAmt, String nextAmt, Color accent, String imageUrl) {
    final progress = paid / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56, height: 56,
              child: Image.network(imageUrl, fit: BoxFit.cover,
                loadingBuilder: (_, child, p) => p == null ? child : Container(color: const Color(0xFFE8EAF0)),
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE8EAF0)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(totalAmt, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$provider · $paid of $total payments made', style: const TextStyle(color: Color(0xFF6B7080), fontSize: 10)),
                    Text('Next: $nextAmt', style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 5,
                    color: const Color(0xFFE8EAF0),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: ColoredBox(color: accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 18),
        ],
      ),
    );
  }

  Widget _buildChrisInsight(SpendingSummary? summary) {
    final totalSpent = summary != null ? '\$${summary.totalSpent.toStringAsFixed(0)}' : '\$1,240';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7C6EF0).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6EF0).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF9B59F5), Color(0xFF4A00E0)]),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Chris's Take", style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  "You spent $totalSpent this month. You have 3 active plans. Stacking more could hurt your score. Consider paying off the Zara plan first.",
                  style: const TextStyle(color: Color(0xFF6B7080), fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.push(RouteConstants.affordabilityCheck.toPath),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C6EF0).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF7C6EF0).withValues(alpha: 0.25), width: 0.6),
                    ),
                    child: const Text('Check Affordability', style: TextStyle(color: Color(0xFF7C6EF0), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        const Icon(Icons.notifications_outlined, color: Color(0xFF6B7080), size: 18),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Payment Reminders", style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 13, fontWeight: FontWeight.w600)),
            Text("We'll remind you before each payment is due", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
          ]),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: _remindersOn,
            onChanged: (v) => setState(() => _remindersOn = v),
            activeColor: const Color(0xFF20C55D),
            activeTrackColor: const Color(0xFF20C55D).withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFF9CA3AF),
            inactiveTrackColor: const Color(0xFFE8EAF0),
          ),
        ),
      ]),
    );
  }

  Widget _buildDiscover(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _sectionLabel('Discover'),
          GestureDetector(
            onTap: () => context.push(RouteConstants.productDiscovery.toPath),
            child: const Text('See all', style: TextStyle(color: Color(0xFF20C55D), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _discoverCard('Nike', PexelsService.photoUrl(1598505, w: 240, h: 260), const Color(0xFF00D4FF), context),
              const SizedBox(width: 10),
              _discoverCard('Apple', PexelsService.photoUrl(3394650, w: 240, h: 260), const Color(0xFFE879F9), context),
              const SizedBox(width: 10),
              _discoverCard('Luxury', PexelsService.photoUrl(2220316, w: 240, h: 260), const Color(0xFFDC8F4A), context),
              const SizedBox(width: 10),
              _discoverCard('Fashion', PexelsService.photoUrl(1536619, w: 240, h: 260), const Color(0xFF20C55D), context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _discoverCard(String name, String url, Color accent, BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.productDiscovery.toPath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 110,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(url, fit: BoxFit.cover,
              loadingBuilder: (_, child, p) => p == null ? child : Container(color: const Color(0xFF1A1A2E)),
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1A2E)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)]),
              ),
            ),
            Positioned(bottom: 8, left: 8, right: 8, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                Text('0% APR', style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w600)),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  // ── PLANS TAB ──────────────────────────────────────────────────────────────

  Widget _buildPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanSummaryRow(),
          const SizedBox(height: 20),
          _sectionLabel('Active Plans'),
          const SizedBox(height: 12),
          _buildDetailedPlan('Nike Air Max 270', 'Afterpay', 3, 4, 262.50, 87.50, 'Jun 15', PexelsService.photoUrl(1598505, w: 120, h: 120), const Color(0xFF00D4FF)),
          const SizedBox(height: 12),
          _buildDetailedPlan('AirPods Pro', 'Klarna', 2, 3, 124.50, 62.25, 'Jun 22', PexelsService.photoUrl(3394650, w: 120, h: 120), const Color(0xFF20C55D)),
          const SizedBox(height: 12),
          _buildDetailedPlan('Zara Jacket', 'Afterpay', 2, 4, 89.75, 44.88, 'Jun 28', PexelsService.photoUrl(1536619, w: 120, h: 120), const Color(0xFFDC8F4A)),
          const SizedBox(height: 20),
          _sectionLabel('Payment History'),
          const SizedBox(height: 12),
          _buildHistoryItem('Nike Air Max 270 · Payment 1 of 4', 'May 15', '\$87.50', true),
          _buildHistoryItem('AirPods Pro · Payment 1 of 3', 'May 22', '\$62.25', true),
          _buildHistoryItem('Zara Jacket · Payment 1 of 4', 'May 28', '\$44.88', true),
          const SizedBox(height: 20),
          _buildOnTimeBonus(),
        ],
      ),
    );
  }

  Widget _buildPlanSummaryRow() {
    return Row(
      children: [
        Expanded(child: _summaryBox('Total Owed', '\$476.75', const Color(0xFFF0B100))),
        const SizedBox(width: 10),
        Expanded(child: _summaryBox('Active Plans', '3', const Color(0xFF00D4FF))),
        const SizedBox(width: 10),
        Expanded(child: _summaryBox('On-time', '100%', const Color(0xFF20C55D))),
      ],
    );
  }

  Widget _summaryBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF6B7080), fontSize: 9, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildDetailedPlan(String name, String provider, int paid, int total, double totalAmt, double nextAmt, String dueDate, String imageUrl, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 56, height: 56,
                child: Image.network(imageUrl, fit: BoxFit.cover,
                  loadingBuilder: (_, c, p) => p == null ? c : Container(color: const Color(0xFFE8EAF0)),
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE8EAF0)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w600)),
              Text('$provider · $paid of $total payments made', style: const TextStyle(color: Color(0xFF6B7080), fontSize: 11)),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: Container(height: 5, color: const Color(0xFFE8EAF0),
                  child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: paid / total,
                    child: ColoredBox(color: accent)),
                ),
              ),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${totalAmt.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w700)),
              const Text('total', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9)),
            ]),
          ]),
        ),
        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE8EAF0)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 5),
              Text('Due $dueDate', style: const TextStyle(color: Color(0xFF6B7080), fontSize: 11)),
            ]),
            Text('Next: \$${nextAmt.toStringAsFixed(2)}', style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Text('Pay Now', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildHistoryItem(String name, String date, String amount, bool success) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF20C55D).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Color(0xFF20C55D), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 12, fontWeight: FontWeight.w500)),
          Text(date, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
        ])),
        Text(amount, style: const TextStyle(color: Color(0xFF20C55D), fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildOnTimeBonus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFDC8F4A).withValues(alpha: 0.15), const Color(0xFFF0B100).withValues(alpha: 0.08)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDC8F4A).withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFDC8F4A).withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFDC8F4A), size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('On-time Payment Bonus', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 13, fontWeight: FontWeight.w700)),
          SizedBox(height: 3),
          Text('Make 5 on-time payments for bonus cashback', style: TextStyle(color: Color(0xFF6B7080), fontSize: 11)),
          SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.all(Radius.circular(4)),
            child: LinearProgressIndicator(
              value: 0.6, minHeight: 5,
              backgroundColor: Color(0xFFE8EAF0),
              valueColor: AlwaysStoppedAnimation(Color(0xFFDC8F4A)),
            ),
          ),
          SizedBox(height: 4),
          Text('3 of 5 payments completed', style: TextStyle(color: Color(0xFFDC8F4A), fontSize: 10, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }

  // ── REWARDS TAB ────────────────────────────────────────────────────────────

  Widget _buildRewardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRewardsHero(),
          const SizedBox(height: 20),
          _sectionLabel('How to Earn'),
          const SizedBox(height: 12),
          _rewardTile(Icons.check_circle_outline_rounded, 'On-time Payments', '50 pts per payment', const Color(0xFF20C55D)),
          const SizedBox(height: 8),
          _rewardTile(Icons.shopping_bag_outlined, 'Shop via TickPay', '2x pts on purchases', const Color(0xFF00D4FF)),
          const SizedBox(height: 8),
          _rewardTile(Icons.people_outline_rounded, 'Refer a Friend', '500 pts per referral', const Color(0xFFE879F9)),
          const SizedBox(height: 8),
          _rewardTile(Icons.star_outline_rounded, 'Full Repayment', '200 pts bonus', const Color(0xFFDC8F4A)),
          const SizedBox(height: 20),
          _sectionLabel('Redeem Points'),
          const SizedBox(height: 12),
          _redeemOption('Cashback', '\$12.40', '1,240 pts', const Color(0xFF20C55D)),
          const SizedBox(height: 8),
          _redeemOption('Fee Waiver', '1 month free', '2,000 pts', const Color(0xFF00D4FF)),
          const SizedBox(height: 8),
          _redeemOption('Shop Credit', '\$25.00', '2,500 pts', const Color(0xFFDC8F4A)),
        ],
      ),
    );
  }

  Widget _buildRewardsHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(PexelsService.photoUrl(1536619, w: 800, h: 360), fit: BoxFit.cover,
            loadingBuilder: (_, c, p) => p == null ? c : Container(color: const Color(0xFF6B3A1F)),
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF6B3A1F)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFDC8F4A).withValues(alpha: 0.75), const Color(0xFF3D1F00).withValues(alpha: 0.82)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFDC8F4A).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFDC8F4A).withValues(alpha: 0.5), width: 0.5)),
                child: const Text('TICKPAY REWARDS', style: TextStyle(color: Color(0xFFDC8F4A), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              ),
              const Spacer(),
              const Text('1,240', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1)),
              const Text('points available · ≈ \$12.40 cashback', style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Redeem Now', style: TextStyle(color: Color(0xFFDC8F4A), fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _rewardTile(IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13, fontWeight: FontWeight.w600)),
          Text(desc, style: const TextStyle(color: Color(0xFF6B7080), fontSize: 11)),
        ])),
        Text('+pts', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _redeemOption(String title, String value, String cost, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(cost, style: const TextStyle(color: Color(0xFF6B7080), fontSize: 11)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Redeem', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(label, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.w700));
  }
}
