import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXVisionPage extends StatefulWidget {
  const LifeXVisionPage({super.key});

  @override
  State<LifeXVisionPage> createState() => _LifeXVisionPageState();
}

class _LifeXVisionPageState extends State<LifeXVisionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _blue = Color(0xFF3B82F6);
  static const _blueLight = Color(0xFF60A5FA);
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);

  static const _goals = [
    _VisionGoal(
      'Launch my Business',
      Icons.rocket_launch_rounded,
      Color(0xFF6366F1),
      0.45,
      '\$25,000',
      '18 months',
      'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    _VisionGoal(
      'Buy a Home',
      Icons.home_rounded,
      Color(0xFF10B981),
      0.55,
      '\$180,000',
      '3 years',
      'https://images.pexels.com/photos/1128318/pexels-photo-1128318.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    _VisionGoal(
      'Run a Marathon',
      Icons.directions_run_rounded,
      Color(0xFFF59E0B),
      0.30,
      '\$450',
      '8 months',
      'https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    _VisionGoal(
      'Speak 2 Languages',
      Icons.language_rounded,
      Color(0xFFEC4899),
      0.25,
      '\$200',
      '2 years',
      'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
  ];

  static const _financialPlans = [
    _FinancialPlan(
      'Launch my Business',
      '\$25,000 needed',
      '\$11,250 saved',
      0.45,
      '\$1,389/mo',
      '\$640/mo short',
      18,
      Color(0xFF6366F1),
    ),
    _FinancialPlan(
      'Buy a Home',
      '\$36,000 down payment',
      '\$19,800 saved',
      0.55,
      '\$1,200/mo',
      '\$650/mo short',
      36,
      Color(0xFF10B981),
    ),
    _FinancialPlan(
      'Run a Marathon',
      '\$450 total (shoes + entry)',
      '\$450 saved',
      1.0,
      'Funded',
      'Ready to spend',
      0,
      Color(0xFFF59E0B),
    ),
  ];

  static const _milestones = [
    _Month('July 2025', [
      _Task('Open business LLC', true),
      _Task('Save \$1,389 toward business', false),
      _Task('Schedule marathon training plan', false),
    ]),
    _Month('August 2025', [
      _Task('Build MVP / first prototype', false),
      _Task('Save \$2,778 total (business fund)', false),
      _Task('Run 10K training race', false),
    ]),
    _Month('September 2025', [
      _Task('First 3 beta users or clients', false),
      _Task('\$4,167 in business fund', false),
      _Task('Register for fall marathon', false),
    ]),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3F4F6),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF374151), size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'Vision Board'),
                Tab(text: 'Financial Plan'),
                Tab(text: '90-Day'),
              ],
              labelColor: _blue,
              unselectedLabelColor: Color(0xFF6B7080),
              indicatorColor: _blue,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildBoardTab(),
            _buildFinancialPlanTab(),
            _buildNinetyDayTab(),
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
              'https://images.pexels.com/photos/3769021/pexels-photo-3769021.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: _blue.withValues(alpha: 0.15)),
          errorWidget: (_, __, ___) =>
              Container(color: _blue.withValues(alpha: 0.15)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _blue.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_red_eye_rounded,
                        color: _blueLight, size: 12),
                    const SizedBox(width: 6),
                    Text('GOALS & VISION',
                        style: TextStyle(
                            color: _blueLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Your Future\nSelf',
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

  // ── Vision Board Tab ──────────────────────────────────────────

  Widget _buildBoardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChrisCoach(),
          const SizedBox(height: 24),
          _sectionTitle('Vision Board'),
          const SizedBox(height: 6),
          Text('Each goal has a cost. Chris tracks the money side automatically.',
              style: TextStyle(
                  color: _textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _goals.length,
            itemBuilder: (_, i) => _VisionBoardCard(goal: _goals[i]),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _blue.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: _blue.withValues(alpha: 0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: _blueLight, size: 18),
                  const SizedBox(width: 8),
                  Text('Add Vision Goal',
                      style: TextStyle(
                          color: _blueLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChrisCoach() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue.withValues(alpha: 0.12),
              border: Border.all(color: _blue.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _blue, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chris says',
                    style: TextStyle(
                        color: _blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    'Your business launch is on track at 45%. To hit the 18-month target, you need \$1,389/mo — you\'re currently saving \$640. Close that gap and this goal stays on schedule.',
                    style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12.5,
                        height: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('See Financial Plan',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
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

  // ── Financial Plan Tab ────────────────────────────────────────

  Widget _buildFinancialPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuarterlyCheckIn(),
          const SizedBox(height: 24),
          _sectionTitle('Goal Financial Breakdown'),
          const SizedBox(height: 6),
          Text('What each goal actually costs and where you stand.',
              style: TextStyle(
                  color: _textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          ..._financialPlans.map((p) => _FinancialPlanCard(plan: p)),
          const SizedBox(height: 24),
          _buildSavingsGapCard(),
        ],
      ),
    );
  }

  Widget _buildQuarterlyCheckIn() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _blue.withValues(alpha: 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _blue.withValues(alpha: 0.25), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Q3 2025',
                    style: TextStyle(
                        color: _blueLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              const Text('Vision Check-in',
                  style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
              'You set 4 goals this year. 3 are on track, 1 needs attention. Your savings rate is your biggest lever right now — everything else is on schedule.',
              style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13,
                  height: 1.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              _checkInStat('3/4', 'On Track', const Color(0xFF10B981)),
              _checkInStat('1', 'At Risk', const Color(0xFFEF4444)),
              _checkInStat('45%', 'Avg Progress', _blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _checkInStat(String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          Text(label,
              style: const TextStyle(
                  color: _textSecondary, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSavingsGapCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Savings Required',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('To hit all goals on time.',
              style: TextStyle(
                  color: _textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          _gapRow('Business Launch', '\$1,389/mo', '\$640/mo', const Color(0xFF6366F1)),
          const SizedBox(height: 10),
          _gapRow('Home Down Payment', '\$1,200/mo', '\$650/mo', const Color(0xFF10B981)),
          const SizedBox(height: 10),
          _gapRow('Marathon Entry', '\$0/mo', 'Funded', const Color(0xFFF59E0B)),
          const Divider(color: _border, height: 24),
          Row(
            children: [
              const Text('Total needed',
                  style: TextStyle(
                      color: _textPrimary, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Text('\$2,589/mo',
                  style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          Row(
            children: [
              const Text('Currently saving',
                  style: TextStyle(
                      color: _textSecondary,
                      fontSize: 12)),
              const Spacer(),
              const Text('\$1,290/mo',
                  style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
                'Gap: \$1,299/mo. Cutting dining spend (\$165/mo) and pausing Hulu + YouTube Premium (\$27/mo) closes \$192. Ask Chris for a personalized plan.',
                style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _gapRow(String label, String target, String current, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: _textSecondary, fontSize: 12)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(target,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            Text('saving $current',
                style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 10)),
          ],
        ),
      ],
    );
  }

  // ── 90-Day Tab ────────────────────────────────────────────────

  Widget _buildNinetyDayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressSummary(),
          const SizedBox(height: 24),
          _sectionTitle('90-Day Milestone Map'),
          const SizedBox(height: 6),
          Text('3 months. One step at a time.',
              style: const TextStyle(
                  color: _textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          ..._milestones.map((m) => _MonthCard(month: m)),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _blue.withValues(alpha: 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _blue.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: 1 / 9,
                  strokeWidth: 6,
                  backgroundColor: _border,
                  valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('1',
                      style: TextStyle(
                          color: _textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const Text('/ 9',
                      style: TextStyle(
                          color: _textSecondary,
                          fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tasks Complete',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('1 of 9 milestones done. July is your foundation month — lock in the legal structure.',
                    style: TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(t,
        style: const TextStyle(
            color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w700));
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _VisionGoal {
  final String title, targetAmount, timeline, imageUrl;
  final IconData icon;
  final Color color;
  final double progress;
  const _VisionGoal(this.title, this.icon, this.color, this.progress,
      this.targetAmount, this.timeline, this.imageUrl);
}

class _FinancialPlan {
  final String goalName, totalCost, saved, monthlyNeeded, gap;
  final double progress;
  final int monthsLeft;
  final Color color;
  const _FinancialPlan(this.goalName, this.totalCost, this.saved,
      this.progress, this.monthlyNeeded, this.gap, this.monthsLeft, this.color);
}

class _Month {
  final String label;
  final List<_Task> tasks;
  const _Month(this.label, this.tasks);
}

class _Task {
  final String text;
  final bool done;
  const _Task(this.text, this.done);
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _VisionBoardCard extends StatelessWidget {
  final _VisionGoal goal;
  const _VisionBoardCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: goal.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: goal.color.withValues(alpha: 0.15)),
            errorWidget: (_, __, ___) =>
                Container(color: goal.color.withValues(alpha: 0.15)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  goal.color.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goal.color.withValues(alpha: 0.2),
                    border: Border.all(
                        color: goal.color.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 16),
                ),
                const Spacer(),
                Text(goal.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.3)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money_rounded,
                        color: goal.color, size: 12),
                    Text(goal.targetAmount,
                        style: TextStyle(
                            color: goal.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    Text('  ·  ${goal.timeline}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${(goal.progress * 100).round()}% complete',
                    style: TextStyle(
                        color: goal.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialPlanCard extends StatelessWidget {
  final _FinancialPlan plan;
  const _FinancialPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isFullyFunded = plan.progress >= 1.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: plan.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: plan.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(plan.goalName,
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
              if (isFullyFunded)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Funded',
                      style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _planStat(plan.totalCost, 'Total Cost', plan.color),
              _planDivider(),
              _planStat(plan.saved, 'Saved', const Color(0xFF10B981)),
              _planDivider(),
              _planStat(
                  plan.monthsLeft > 0 ? '${plan.monthsLeft}mo' : 'Now',
                  'Timeline',
                  const Color(0xFF6B7080)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plan.progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE8EAF0),
              valueColor: AlwaysStoppedAnimation<Color>(plan.color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${(plan.progress * 100).round()}% saved',
                  style: TextStyle(
                      color: plan.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              if (!isFullyFunded)
                Text('Need ${plan.monthlyNeeded}/mo',
                    style: const TextStyle(
                        color: Color(0xFF6B7080),
                        fontSize: 11)),
            ],
          ),
          if (!isFullyFunded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Currently ${plan.gap}',
                  style: const TextStyle(
                      color: Color(0xFF6B7080),
                      fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _planStat(String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF9CA3AF), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _planDivider() {
    return const ColoredBox(color: Color(0xFFE8EAF0), child: SizedBox(width: 1, height: 24));
  }
}

class _MonthCard extends StatefulWidget {
  final _Month month;
  const _MonthCard({required this.month});

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  late List<bool> _done;

  @override
  void initState() {
    super.initState();
    _done = widget.month.tasks.map((t) => t.done).toList();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _done.where((d) => d).length;
    final total = widget.month.tasks.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 10),
                Text(widget.month.label,
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('$completedCount / $total',
                    style: TextStyle(
                        color: completedCount == total
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7080),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: completedCount / total,
              backgroundColor: const Color(0xFFE8EAF0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF3B82F6)),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            widget.month.tasks.length,
            (i) => GestureDetector(
              onTap: () => setState(() => _done[i] = !_done[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Color(0xFFE8EAF0),
                          width: 1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _done[i]
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFF3F4F6),
                        border: Border.all(
                            color: _done[i]
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFE8EAF0),
                            width: 1),
                      ),
                      child: _done[i]
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 12)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                          widget.month.tasks[i].text,
                          style: TextStyle(
                              color: _done[i]
                                  ? const Color(0xFF1A1A2E)
                                  : const Color(0xFF6B7080),
                              fontSize: 13,
                              decoration: _done[i]
                                  ? TextDecoration.none
                                  : null)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
