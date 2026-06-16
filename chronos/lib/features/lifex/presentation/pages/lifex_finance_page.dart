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
  bool _useAvalanche = true;

  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  static const _green = Color(0xFF10B981);
  static const _greenLight = Color(0xFF34D399);
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);

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
      backgroundColor: const Color(0xFFF5F6FA),
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
                Tab(text: 'Life Ledger'),
                Tab(text: 'Budgets'),
                Tab(text: 'Goals'),
              ],
              labelColor: _green,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _green,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildLedgerTab(),
            _buildBudgetsTab(),
            _buildGoalsTab(),
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
              'https://images.pexels.com/photos/730547/pexels-photo-730547.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: _green.withValues(alpha: 0.15)),
          errorWidget: (_, __, ___) =>
              Container(color: _green.withValues(alpha: 0.15)),
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
              _tag(Icons.trending_up_rounded, 'FINANCIAL DOMAIN', _green),
              const SizedBox(height: 10),
              Text('Life\nLedger',
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

  // ── LEDGER TAB ──────────────────────────────────────────────────────────────

  Widget _buildLedgerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNetWorthCard(),
          const SizedBox(height: 16),
          _buildCashflowCard(),
          const SizedBox(height: 20),
          _sectionTitle('Where Your Money Goes'),
          const SizedBox(height: 12),
          _buildSpendingBreakdown(),
          const SizedBox(height: 20),
          _buildStudentLoanSection(),
          const SizedBox(height: 20),
          _buildWeeklyNudge(),
        ],
      ),
    );
  }

  Widget _buildNetWorthCard() {
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
                _green.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: _green.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('NET WORTH',
                      style: TextStyle(
                          color: _green,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                ),
                const Spacer(),
                Text('Updated today',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11)),
              ]),
              const SizedBox(height: 14),
              const Text('\$5,300',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800)),
              Row(children: [
                const Icon(Icons.arrow_upward_rounded,
                    color: _greenLight, size: 14),
                Text(' +\$320 this month',
                    style: const TextStyle(
                        color: _greenLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _netWorthStat(
                        'Assets', '\$23,500', const Color(0xFF10B981))),
                Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.08)),
                Expanded(
                    child: _netWorthStat(
                        'Debts', '-\$18,200', const Color(0xFFEF4444))),
                Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.08)),
                Expanded(
                    child: _netWorthStat(
                        'Net', '\$5,300', const Color(0xFF10B981))),
              ]),
              const SizedBox(height: 4),
              Text(
                  "Most people never see this number. This is your starting point — it only goes up from here.",
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.38),
                      fontSize: 11,
                      height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _netWorthStat(String label, String val, Color color) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
    ]);
  }

  Widget _buildCashflowCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
                child: _cashflowStat(
                    'Monthly Income', '\$4,200', const Color(0xFF10B981))),
            Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
                child: _cashflowStat(
                    'Monthly Spend', '\$2,985', const Color(0xFFEF4444))),
            Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
                child: _cashflowStat(
                    'Saved', '\$1,215', const Color(0xFF3B82F6))),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 2985 / 4200,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            Text('71.1% of income spent',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11)),
            const Spacer(),
            Text('28.9% saved',
                style: const TextStyle(
                    color: _greenLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  Widget _cashflowStat(String label, String val, Color color) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: color, fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10),
          textAlign: TextAlign.center),
    ]);
  }

  Widget _buildSpendingBreakdown() {
    const categories = [
      _SpendCat('Housing & Rent', 1200, 4200, Color(0xFF6366F1)),
      _SpendCat('Food & Dining', 520, 4200, Color(0xFFF59E0B)),
      _SpendCat('Transport', 240, 4200, Color(0xFF3B82F6)),
      _SpendCat('Health', 185, 4200, Color(0xFF14B8A6)),
      _SpendCat('Subscriptions', 95, 4200, Color(0xFFEC4899)),
      _SpendCat('Entertainment', 145, 4200, Color(0xFFEF4444)),
      _SpendCat('Savings (auto)', 600, 4200, Color(0xFF10B981)),
    ];
    return Column(
      children: categories
          .map((c) => _SpendingBar(cat: c))
          .toList(),
    );
  }

  Widget _buildStudentLoanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Student Loan Tracker'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Color(0xFF6366F1), size: 18),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Federal Student Loans',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text('6.5% interest · Repaye plan',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12)),
                ]),
                const Spacer(),
                const Text('\$22,500',
                    style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _loanStat('Monthly', '\$280',
                        const Color(0xFF6366F1))),
                Expanded(
                    child: _loanStat('Payoff Date', 'Oct 2031',
                        Colors.white)),
                Expanded(
                    child: _loanStat('Total Interest', '\$4,820',
                        const Color(0xFFEF4444))),
              ]),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.38,
                  backgroundColor:
                      const Color(0xFF6366F1).withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text('38% paid off · \$13,950 remaining',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11)),
              const SizedBox(height: 14),
              Row(children: [
                _loanAction('IDR Check', Icons.calculate_rounded,
                    const Color(0xFF6366F1)),
                const SizedBox(width: 8),
                _loanAction('Forgiveness?', Icons.volunteer_activism_rounded,
                    const Color(0xFF10B981)),
                const SizedBox(width: 8),
                _loanAction('Refi Options', Icons.sync_alt_rounded,
                    const Color(0xFFF59E0B)),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loanStat(String label, String val, Color color) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
          textAlign: TextAlign.center),
    ]);
  }

  Widget _loanAction(String label, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  Widget _buildWeeklyNudge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _green.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _green.withValues(alpha: 0.12),
              border:
                  Border.all(color: _green.withValues(alpha: 0.4), width: 1)),
          child: const Icon(Icons.auto_awesome_rounded,
              color: _green, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text("This Week's Nudge",
                  style: TextStyle(
                      color: _greenLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                "You've saved 28.9% of your income — that's ahead of most people your age. One small next step: set up an automatic \$50/week transfer to a separate savings account.",
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12.5,
                    height: 1.5),
              ),
            ])),
      ]),
    );
  }

  // ── BUDGETS TAB ─────────────────────────────────────────────────────────────

  Widget _buildBudgetsTab() {
    const budgets = [
      _Budget('Groceries', 340, 500, Color(0xFF10B981)),
      _Budget('Entertainment', 180, 200, Color(0xFFF59E0B)),
      _Budget('Transport', 95, 150, Color(0xFF3B82F6)),
      _Budget('Health', 120, 200, Color(0xFF14B8A6)),
      _Budget('Dining Out', 220, 250, Color(0xFFEF4444)),
      _Budget('Shopping', 145, 200, Color(0xFFEC4899)),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthOverview(),
          const SizedBox(height: 22),
          _sectionTitle('Budget Categories'),
          const SizedBox(height: 14),
          ...budgets.map((b) => _BudgetBar(budget: b)),
          const SizedBox(height: 18),
          _buildChrisInsight(
              "You're on track this month. Dining Out is at 88% — consider cooking at home twice this week to stay under budget."),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: _green.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: _green.withValues(alpha: 0.05),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: _green, size: 18),
                    const SizedBox(width: 8),
                    const Text('Add Budget Category',
                        style: TextStyle(
                            color: _green,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
          ),
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
              colors: [
                _green.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _green.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                    child: _overviewStat(
                        'Spent', '\$2,485', const Color(0xFFEF4444))),
                Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.08)),
                Expanded(
                    child:
                        _overviewStat('Budget', '\$3,200', _green)),
                Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.08)),
                Expanded(
                    child: _overviewStat(
                        'Saved', '\$1,215', const Color(0xFF3B82F6))),
              ]),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 2485 / 3200,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(_green),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(children: [
                Text('77.7% of monthly budget used',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11)),
                const Spacer(),
                const Text('11 days left',
                    style: TextStyle(
                        color: _greenLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewStat(String label, String val, Color color) {
    return Column(children: [
      Text(val,
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
    ]);
  }

  // ── GOALS TAB ───────────────────────────────────────────────────────────────

  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDebtPayoffSection(),
          const SizedBox(height: 24),
          _sectionTitle('Financial Goals'),
          const SizedBox(height: 14),
          ...[
            _PlanCard('Emergency Fund', '\$8,500', '\$10,000',
                const Color(0xFF10B981), 0.85),
            _PlanCard('House Down Payment', '\$22,000', '\$40,000',
                const Color(0xFF3B82F6), 0.55),
            _PlanCard('Investment Portfolio', '\$15,200', '\$50,000',
                const Color(0xFF8B5CF6), 0.30),
            _PlanCard('Vacation Fund', '\$1,800', '\$3,000',
                const Color(0xFFF59E0B), 0.60),
          ].map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12), child: p)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: _green.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(16),
                color: _green.withValues(alpha: 0.05),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: _green, size: 18),
                    const SizedBox(width: 8),
                    const Text('Create New Goal',
                        style: TextStyle(
                            color: _green,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtPayoffSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Debt Payoff Roadmap'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.07), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _useAvalanche = true),
                    child: _strategyTab(
                        'Avalanche', 'Highest interest first',
                        _useAvalanche),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _useAvalanche = false),
                    child: _strategyTab(
                        'Snowball', 'Smallest balance first',
                        !_useAvalanche),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.flag_rounded, color: _greenLight, size: 16),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                        _useAvalanche
                            ? 'Debt-free in 2 yrs 4 months'
                            : 'Debt-free in 2 yrs 9 months',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text(
                        _useAvalanche
                            ? 'Saves ~\$1,240 in interest'
                            : 'Good for motivation wins',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11)),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              ..._buildDebtList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _strategyTab(String title, String sub, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: selected
            ? _green.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: selected
                ? _green.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: selected ? _greenLight : Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        Text(sub,
            style: TextStyle(
                color: selected
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.3),
                fontSize: 10)),
      ]),
    );
  }

  List<Widget> _buildDebtList() {
    final debts = _useAvalanche
        ? [
            _Debt('Credit Card', '\$3,200', '22.9%', const Color(0xFFEF4444)),
            _Debt('Car Loan', '\$8,500', '6.8%', const Color(0xFFF59E0B)),
            _Debt('Student Loans', '\$22,500', '6.5%', const Color(0xFF6366F1)),
          ]
        : [
            _Debt('Credit Card', '\$3,200', '22.9%', const Color(0xFFEF4444)),
            _Debt('Car Loan', '\$8,500', '6.8%', const Color(0xFFF59E0B)),
            _Debt('Student Loans', '\$22,500', '6.5%', const Color(0xFF6366F1)),
          ];

    return debts
        .asMap()
        .entries
        .map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: e.value.color.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text('${e.key + 1}',
                        style: TextStyle(
                            color: e.value.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Text('${e.value.rate} APR',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11)),
                      ]),
                ),
                Text(e.value.balance,
                    style: TextStyle(
                        color: e.value.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ]),
            ))
        .toList();
  }

  Widget _buildChrisInsight(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _green.withValues(alpha: 0.12),
              border:
                  Border.all(color: _green.withValues(alpha: 0.4), width: 1)),
          child: const Icon(Icons.auto_awesome_rounded,
              color: _green, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Chris says',
                  style: TextStyle(
                      color: _green,
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

// ── Data models ───────────────────────────────────────────────────────────────

class _SpendCat {
  final String name;
  final double amount;
  final double income;
  final Color color;
  const _SpendCat(this.name, this.amount, this.income, this.color);
}

class _SpendingBar extends StatelessWidget {
  final _SpendCat cat;
  const _SpendingBar({required this.cat});

  @override
  Widget build(BuildContext context) {
    final pct = cat.amount / cat.income;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 130,
          child: Text(cat.name,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12.5),
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: cat.color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(cat.color),
              minHeight: 7,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 50,
          child: Text('\$${cat.amount.toInt()}',
              style: TextStyle(
                  color: cat.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.right),
        ),
      ]),
    );
  }
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
        border: Border.all(
            color: budget.color
                .withValues(alpha: warning ? 0.4 : 0.15),
            width: 1),
      ),
      child: Column(children: [
        Row(children: [
          Text(budget.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('\$${budget.spent.toInt()} / \$${budget.limit.toInt()}',
              style: TextStyle(
                  color: warning
                      ? const Color(0xFFEF4444)
                      : Colors.white.withValues(alpha: 0.55),
                  fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
                warning ? const Color(0xFFEF4444) : budget.color),
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
  const _PlanCard(
      this.title, this.current, this.target, this.color, this.progress);

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
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12)),
              child: Icon(Icons.flag_rounded, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600))),
          Text('${(progress * 100).round()}%',
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
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
          Text(current,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          Text(' of $target',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        ]),
      ]),
    );
  }
}

class _Debt {
  final String name;
  final String balance;
  final String rate;
  final Color color;
  const _Debt(this.name, this.balance, this.rate, this.color);
}
