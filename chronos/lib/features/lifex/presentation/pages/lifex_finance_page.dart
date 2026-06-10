import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXFinancePage extends StatefulWidget {
  const LifeXFinancePage({super.key});

  @override
  State<LifeXFinancePage> createState() => _LifeXFinancePageState();
}

class _LifeXFinancePageState extends State<LifeXFinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _bg = Color(0xFF06100A);
  static const _card = Color(0xFF0C1A10);
  static const _green = Color(0xFF10B981);
  static const _greenLight = Color(0xFF34D399);

  static const _budgets = [
    _Budget('Groceries', 340, 500, Color(0xFF10B981)),
    _Budget('Entertainment', 180, 200, Color(0xFFF59E0B)),
    _Budget('Transport', 95, 150, Color(0xFF3B82F6)),
    _Budget('Health', 120, 200, Color(0xFF14B8A6)),
    _Budget('Dining Out', 220, 250, Color(0xFFEF4444)),
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
              tabs: const [Tab(text: 'Budgets'), Tab(text: 'Plans'), Tab(text: 'Insights')],
              labelColor: _green,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _green,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [_buildBudgetsTab(), _buildPlansTab(), _buildInsightsTab()],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: 'https://images.pexels.com/photos/730547/pexels-photo-730547.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: _green.withValues(alpha: 0.15)),
          errorWidget: (_, __, ___) => Container(color: _green.withValues(alpha: 0.15)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.3), _bg.withValues(alpha: 0.97)],
            ),
          ),
        ),
        Positioned(
          bottom: 54,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tag(Icons.trending_up_rounded, 'WEALTH & FINANCE', _green),
              const SizedBox(height: 10),
              Text('Financial\nFreedom', style: TextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
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
        Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      ]),
    );
  }

  Widget _buildBudgetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthOverview(),
          const SizedBox(height: 22),
          _sectionTitle('Budget Categories'),
          const SizedBox(height: 14),
          ..._budgets.map((b) => _BudgetBar(budget: b)),
          const SizedBox(height: 18),
          _buildChrisInsight('You\'re on track this month. Dining Out is at 88% — consider cooking at home twice this week to stay under budget.'),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Financial Plans'),
          const SizedBox(height: 14),
          ...[
            _PlanCard('Emergency Fund', '\$8,500', '\$10,000', Color(0xFF10B981), 0.85),
            _PlanCard('House Down Payment', '\$22,000', '\$40,000', Color(0xFF3B82F6), 0.55),
            _PlanCard('Investment Portfolio', '\$15,200', '\$50,000', Color(0xFF8B5CF6), 0.30),
            _PlanCard('Vacation Fund', '\$1,800', '\$3,000', Color(0xFFF59E0B), 0.60),
          ].map((p) => Padding(padding: const EdgeInsets.only(bottom: 12), child: p)),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: _green.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: _green.withValues(alpha: 0.05),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_rounded, color: _green, size: 18),
                const SizedBox(width: 8),
                Text('Create New Plan', style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChrisInsight('Based on your last 3 months of transactions, you\'re saving 18% of your income. Increasing to 20% would accelerate your house down payment by 6 months.'),
          const SizedBox(height: 20),
          _sectionTitle('Spending Trends'),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Building a Personal Budget',
            duration: '25 min',
            imageUrl: 'https://images.pexels.com/photos/669619/pexels-photo-669619.jpeg?auto=compress&cs=tinysrgb&w=600',
          ),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Investing for Beginners',
            duration: '38 min',
            imageUrl: 'https://images.pexels.com/photos/4386373/pexels-photo-4386373.jpeg?auto=compress&cs=tinysrgb&w=600',
          ),
          const SizedBox(height: 20),
          _buildFinanceTip(),
        ],
      ),
    );
  }

  Widget _buildMonthOverview() {
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
              colors: [_green.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0.02)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: _overviewStat('Spent', '\$2,485', const Color(0xFFEF4444))),
                Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.08)),
                Expanded(child: _overviewStat('Budget', '\$3,200', _green)),
                Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.08)),
                Expanded(child: _overviewStat('Saved', '\$1,215', const Color(0xFF3B82F6))),
              ]),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 2485 / 3200,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(children: [
                Text('77.7% of monthly budget used',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
                const Spacer(),
                Text('11 days left', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewStat(String label, String val, Color color) {
    return Column(children: [
      Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
    ]);
  }

  Widget _buildChrisInsight(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _green.withValues(alpha: 0.12), border: Border.all(color: _green.withValues(alpha: 0.4), width: 1)),
          child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF10B981), size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Chris says', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.5, height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _buildFinanceTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(children: [
        Text('💡', style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Finance Tip', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Pay yourself first. Automate your savings the moment you receive income — before spending anything.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, height: 1.45)),
        ])),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
}

class _Budget {
  final String name;
  final double spent;
  final double limit;
  final Color color;
  const _Budget(this.name, this.spent, this.limit, this.color);
}

class _BudgetBar extends StatelessWidget {
  final _Budget budget;
  const _BudgetBar({required this.budget});

  @override
  Widget build(BuildContext context) {
    final ratio = budget.spent / budget.limit;
    final warning = ratio > 0.85;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1A10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: budget.color.withValues(alpha: warning ? 0.4 : 0.15), width: 1),
      ),
      child: Column(children: [
        Row(children: [
          Text(budget.name, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('\$${budget.spent.toInt()} / \$${budget.limit.toInt()}',
              style: TextStyle(color: warning ? const Color(0xFFEF4444) : Colors.white.withValues(alpha: 0.55), fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(warning ? const Color(0xFFEF4444) : budget.color),
            minHeight: 5,
          ),
        ),
      ]),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String current;
  final String target;
  final Color color;
  final double progress;
  const _PlanCard(this.title, this.current, this.target, this.color, this.progress);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1A10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
              child: Icon(Icons.flag_rounded, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
          Text('${(progress * 100).round()}%', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Text(current, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          Text(' of $target', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        ]),
      ]),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String imageUrl;
  const _VideoCard({required this.title, required this.duration, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 160,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(fit: StackFit.expand, children: [
            CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFF0C1A10)),
                errorWidget: (_, __, ___) => Container(color: const Color(0xFF0C1A10))),
            Container(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)]))),
            Center(child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5)),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
            )),
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
