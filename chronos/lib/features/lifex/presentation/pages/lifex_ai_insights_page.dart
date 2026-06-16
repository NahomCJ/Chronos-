import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXAiInsightsPage extends StatefulWidget {
  const LifeXAiInsightsPage({super.key});

  @override
  State<LifeXAiInsightsPage> createState() => _LifeXAiInsightsPageState();
}

class _LifeXAiInsightsPageState extends State<LifeXAiInsightsPage> {
  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _cyan = Color(0xFF06B6D4);
  static const _cyanLight = Color(0xFF22D3EE);

  static const _insights = [
    _Insight(
      'Sleep Pattern Detected',
      'Your sleep quality dropped 18% this week. Going to bed 45 min earlier could recover your energy score by Thursday.',
      Icons.bedtime_rounded,
      Color(0xFF6366F1),
      'High Impact',
    ),
    _Insight(
      'Spending Anomaly',
      'You spent 2.4x more on food delivery this month. Cooking 3 nights per week saves ~\$180/month.',
      Icons.restaurant_rounded,
      Color(0xFFF59E0B),
      'Financial',
    ),
    _Insight(
      'Learning Streak at Risk',
      'You haven\'t opened your Education module in 4 days. A 10-min session today keeps your streak alive.',
      Icons.school_rounded,
      Color(0xFF8B5CF6),
      'Education',
    ),
    _Insight(
      'Activity Goal Update',
      'You\'re 1,200 steps short of your weekly goal. A 12-min walk today completes it.',
      Icons.directions_run_rounded,
      Color(0xFF10B981),
      'Fitness',
    ),
  ];

  static const _trends = [
    _Trend('Wellbeing', 0.82, Color(0xFF14B8A6)),
    _Trend('Finance', 0.65, Color(0xFF10B981)),
    _Trend('Education', 0.55, Color(0xFF6366F1)),
    _Trend('Activity', 0.74, Color(0xFFF59E0B)),
    _Trend('Social', 0.48, Color(0xFFEC4899)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: const ChrisHomeFab(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('This Week\'s Insights'),
                const SizedBox(height: 14),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: _InsightCard(insight: _insights[i]),
              ),
              childCount: _insights.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Life Score Breakdown'),
                const SizedBox(height: 14),
                _buildTrendsCard(),
                const SizedBox(height: 22),
                _sectionTitle('Chris AI Summary'),
                const SizedBox(height: 14),
                _buildChrisSummary(),
                const SizedBox(height: 22),
                _sectionTitle('Recommended Actions'),
                const SizedBox(height: 14),
                ...[
                  _Action('Schedule a 30-min digital detox today', Icons.do_not_disturb_on_rounded, _cyan),
                  _Action('Review your monthly budget vs actuals', Icons.account_balance_wallet_rounded, const Color(0xFF10B981)),
                  _Action('Log yesterday\'s meals for nutrition tracking', Icons.set_meal_rounded, const Color(0xFFF59E0B)),
                  _Action('Call a family member this week', Icons.call_rounded, const Color(0xFFEC4899)),
                ].map((a) => _ActionTile(action: a)),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(fit: StackFit.expand, children: [
        CachedNetworkImage(
          imageUrl: 'https://images.pexels.com/photos/8439093/pexels-photo-8439093.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: _cyan.withValues(alpha: 0.15)),
          errorWidget: (_, __, ___) => Container(color: _cyan.withValues(alpha: 0.15)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.2), _bg.withValues(alpha: 0.97)],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF3F4F6),
                    border: Border.all(color: _border, width: 1)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF374151), size: 16),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24, left: 20,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _cyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _cyan.withValues(alpha: 0.5), width: 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.auto_awesome_rounded, color: _cyanLight, size: 12),
                const SizedBox(width: 6),
                Text('AI INSIGHTS', style: TextStyle(color: _cyanLight, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ]),
            ),
            const SizedBox(height: 10),
            Text('Your Personal\nGuide', style: TextStyles.displaySmall.copyWith(color: _textPrimary, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cyan.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: _trends.map((t) => _TrendRow(trend: t)).toList()),
    );
  }

  Widget _buildChrisSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cyan.withValues(alpha: 0.25), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _cyan.withValues(alpha: 0.12),
            border: Border.all(color: _cyan.withValues(alpha: 0.4), width: 1),
          ),
          child: Icon(Icons.auto_awesome_rounded, color: _cyan, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Chris says', style: TextStyle(color: _cyanLight, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Your overall life score is 74 this week — up 6 points from last week. Your biggest growth area is Finance (+12%). Your wellbeing dipped slightly due to sleep. I\'ve prioritised 4 actions that will have the most impact this week.',
              style: TextStyle(color: _textSecondary, fontSize: 12.5, height: 1.5),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w700));
}

class _Insight {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final String tag;
  const _Insight(this.title, this.body, this.icon, this.color, this.tag);
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: insight.color.withValues(alpha: 0.25), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: insight.color.withValues(alpha: 0.12)),
          child: Icon(insight.icon, color: insight.color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(insight.title, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: insight.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(insight.tag, style: TextStyle(color: insight.color, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(insight.body, style: const TextStyle(color: Color(0xFF6B7080), fontSize: 12.5, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

class _Trend {
  final String label;
  final double value;
  final Color color;
  const _Trend(this.label, this.value, this.color);
}

class _TrendRow extends StatelessWidget {
  final _Trend trend;
  const _TrendRow({required this.trend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(
          width: 80,
          child: Text(trend.label, style: const TextStyle(color: Color(0xFF6B7080), fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: trend.value,
              backgroundColor: const Color(0xFFE8EAF0),
              valueColor: AlwaysStoppedAnimation<Color>(trend.color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('${(trend.value * 100).round()}%',
            style: TextStyle(color: trend.color, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Action {
  final String text;
  final IconData icon;
  final Color color;
  const _Action(this.text, this.icon, this.color);
}

class _ActionTile extends StatelessWidget {
  final _Action action;
  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: action.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: action.color.withValues(alpha: 0.1)),
          child: Icon(action.icon, color: action.color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(action.text, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13, fontWeight: FontWeight.w500))),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 20),
      ]),
    );
  }
}
