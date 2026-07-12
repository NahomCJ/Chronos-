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
  static const _bg = Color(0xFF0D0D22);
  static const _card = Color(0xFF0F0F1C);
  static const _accent = Colors.white;
  static const _accentLight = Colors.white70;

  static const _insights = [
    _Insight(
      'Sleep Pattern Detected',
      'Your sleep quality dropped 18% this week. Going to bed 45 min earlier could recover your energy score by Thursday.',
      Icons.bedtime_rounded,
      Colors.white,
      'High Impact',
    ),
    _Insight(
      'Spending Anomaly',
      'You spent 2.4x more on food delivery this month. Cooking 3 nights per week saves ~\$180/month.',
      Icons.restaurant_rounded,
      Colors.white,
      'Financial',
    ),
    _Insight(
      'Learning Streak at Risk',
      'You haven\'t opened your Education module in 4 days. A 10-min session today keeps your streak alive.',
      Icons.school_rounded,
      Colors.white,
      'Education',
    ),
    _Insight(
      'Activity Goal Update',
      'You\'re 1,200 steps short of your weekly goal. A 12-min walk today completes it.',
      Icons.directions_run_rounded,
      Colors.white,
      'Fitness',
    ),
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
                _sectionTitle('Chris AI Summary'),
                const SizedBox(height: 14),
                _buildChrisSummary(),
                const SizedBox(height: 22),
                _sectionTitle('Recommended Actions'),
                const SizedBox(height: 14),
                ...[
                  _Action('Schedule a 30-min digital detox today', Icons.do_not_disturb_on_rounded),
                  _Action('Review your monthly budget vs actuals', Icons.account_balance_wallet_rounded),
                  _Action('Log yesterday\'s meals for nutrition tracking', Icons.set_meal_rounded),
                  _Action('Call a family member this week', Icons.call_rounded),
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
          placeholder: (_, __) => Container(color: Colors.white.withValues(alpha: 0.06)),
          errorWidget: (_, __, ___) => Container(color: Colors.white.withValues(alpha: 0.06)),
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 24, left: 20,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your Personal\nGuide', style: TextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30, height: 1.1)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildChrisSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _accent.withValues(alpha: 0.12),
            border: Border.all(color: _accent.withValues(alpha: 0.4), width: 1),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: _accent, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Chris says', style: TextStyle(color: _accentLight, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Finance is your biggest area of growth this week, while sleep dipped a little. I\'ve prioritised 4 actions below that will have the most impact.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.5, height: 1.5),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
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
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: insight.color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: insight.color.withValues(alpha: 0.08)),
          child: Icon(insight.icon, color: insight.color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(insight.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
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
            Text(insight.body, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.5, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

class _Action {
  final String text;
  final IconData icon;
  const _Action(this.text, this.icon);
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
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
          child: Icon(action.icon, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(action.text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
        Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2), size: 20),
      ]),
    );
  }
}
