import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXEducationPage extends StatefulWidget {
  const LifeXEducationPage({super.key});

  @override
  State<LifeXEducationPage> createState() => _LifeXEducationPageState();
}

class _LifeXEducationPageState extends State<LifeXEducationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _useAvalanche = true;
  int _selectedRefi = 0;

  static const _bg = Color(0xFFF5F6FA);
  static const _card = Colors.white;
  // Neutral dark/light-gray accent — was a page-specific indigo theme.
  static const _indigo = Color(0xFF374151);
  static const _indigoLight = Color(0xFF6B7280);

  static const _idrPlans = [
    _IDRPlan('SAVE', '\$186/mo', '\$0 remaining — income-based forgiveness', true, Color(0xFF22C55E)),
    _IDRPlan('IBR', '\$248/mo', 'Forgiveness at 20 years (2042)', false, Color(0xFF6B7280)),
    _IDRPlan('PAYE', '\$215/mo', 'Forgiveness at 20 years (2042)', false, Color(0xFF6B7280)),
    _IDRPlan('Standard', '\$312/mo', 'Paid off by June 2034. Lowest total cost.', false, Color(0xFF6B7280)),
  ];

  static const _refiOffers = [
    _RefiOffer('Earnest', '5.18%', '\$264/mo', '\$4,820 saved'),
    _RefiOffer('SoFi', '5.43%', '\$271/mo', '\$3,950 saved'),
    _RefiOffer('Splash', '4.99%', '\$259/mo', '\$5,410 saved'),
  ];

  static const _skillApps = [
    _SkillApp('Coursera', 'University courses', Icons.school_rounded, Color(0xFF374151)),
    _SkillApp('LinkedIn Learning', 'Career skills', Icons.work_rounded, Color(0xFF374151)),
    _SkillApp('Udemy', 'Practical skills', Icons.laptop_rounded, Color(0xFF374151)),
    _SkillApp('Khan Academy', 'Math & science', Icons.calculate_rounded, Color(0xFF374151)),
    _SkillApp('Duolingo', 'Languages', Icons.translate_rounded, Color(0xFF374151)),
    _SkillApp('Blinkist', 'Book summaries', Icons.menu_book_rounded, Color(0xFF374151)),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
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
                  color: const Color(0xFFF3F4F6),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF374151), size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Loans'),
                Tab(text: 'Tuition ROI'),
                Tab(text: 'Skills'),
              ],
              labelColor: _indigo,
              unselectedLabelColor: const Color(0xFF6B7080),
              indicatorColor: _indigo,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildOverviewTab(),
            _buildLoansTab(),
            _buildROITab(),
            _buildSkillsTab(),
          ],
        ),
      ),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Loan Balance',
                    style: TextStyle(color: const Color(0xFF6B7080), fontSize: 12)),
                const Text('\$28,500',
                    style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('38% paid off · access to 6 learning platforms below',
                    style: TextStyle(color: const Color(0xFF6B7080), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Explore Education'),
          const SizedBox(height: 12),
          _OverviewLink(
            icon: Icons.account_balance_rounded,
            title: 'Loans',
            subtitle: 'Repayment plans, forgiveness tracker, refinancing',
            onTap: () => _tabs.animateTo(1),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.trending_up_rounded,
            title: 'Tuition ROI',
            subtitle: 'What your degree is actually worth over time',
            onTap: () => _tabs.animateTo(2),
          ),
          const SizedBox(height: 10),
          _OverviewLink(
            icon: Icons.menu_book_rounded,
            title: 'Skills',
            subtitle: '${_skillApps.length} learning apps · free courses',
            onTap: () => _tabs.animateTo(3),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl:
              'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: _indigo.withValues(alpha: 0.2)),
          errorWidget: (_, __, ___) =>
              Container(color: _indigo.withValues(alpha: 0.2)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                _bg.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 54,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Education\nFinances',
                  style: TextStyles.displaySmall.copyWith(
                      color: const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      height: 1.1)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Loans Tab ─────────────────────────────────────────────────

  Widget _buildLoansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoanDashboard(),
          const SizedBox(height: 24),
          _buildIDRSection(),
          const SizedBox(height: 24),
          _buildForgivenessCard(),
          const SizedBox(height: 24),
          _buildRefiSection(),
          const SizedBox(height: 24),
          _buildChrisLoanNudge(),
        ],
      ),
    );
  }

  Widget _buildLoanDashboard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _indigo.withValues(alpha: 0.08),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: _indigo.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Balance',
                          style: TextStyle(
                              color: const Color(0xFF6B7080),
                              fontSize: 12)),
                      const Text('\$28,500',
                          style: TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 32,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: 0.38,
                          strokeWidth: 6,
                          backgroundColor:
                              const Color(0xFFE8EAF0),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(_indigo),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text('38%',
                          style: TextStyle(
                              color: _indigoLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _loanStat('\$312/mo', 'Monthly'),
                  _divider(),
                  _loanStat('6.8%', 'Avg APR'),
                  _divider(),
                  _loanStat('Jun 2034', 'Payoff'),
                  _divider(),
                  _loanStat('\$42,180', 'Total Cost'),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.38,
                  backgroundColor: const Color(0xFFE8EAF0),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(_indigo),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('\$17,500 paid',
                      style: TextStyle(
                          color: _indigoLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('\$28,500 remaining',
                      style: TextStyle(
                          color: const Color(0xFF6B7080),
                          fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loanStat(String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: _indigoLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          Text(label,
              style: TextStyle(
                  color: const Color(0xFF6B7080), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 28, color: const Color(0xFFE8EAF0));
  }

  Widget _buildIDRSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Repayment Plans'),
        const SizedBox(height: 6),
        Text('Compare options based on your income of \$52,000/yr.',
            style: TextStyle(
                color: const Color(0xFF6B7080), fontSize: 12)),
        const SizedBox(height: 14),
        ..._idrPlans.map((p) => _IDRPlanCard(plan: p)),
      ],
    );
  }

  Widget _buildForgivenessCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.verified_rounded,
                    color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Forgiveness Tracker',
                      style: TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text('Public Service Loan Forgiveness (PSLF)',
                      style: TextStyle(
                          color: const Color(0xFF6B7080),
                          fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _forgivenessItem('32', 'Payments Made', const Color(0xFF22C55E)),
              _forgivenessItem('88', 'Remaining', const Color(0xFF6B7280)),
              _forgivenessItem('7yr 4mo', 'Until Forgiven', const Color(0xFF6B7280)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 32 / 120,
              backgroundColor: const Color(0xFFE8EAF0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text('Must work at a qualifying employer. Your current employer qualifies.',
              style: TextStyle(
                  color: const Color(0xFF6B7080),
                  fontSize: 11,
                  height: 1.4)),
        ],
      ),
    );
  }

  Widget _forgivenessItem(String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          Text(label,
              style: TextStyle(
                  color: const Color(0xFF6B7080), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRefiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle('Refinancing Offers'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Current: 6.8%',
                  style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Refi saves money but eliminates PSLF eligibility. Choose wisely.',
            style: TextStyle(
                color: const Color(0xFF6B7080), fontSize: 12)),
        const SizedBox(height: 14),
        ...List.generate(
          _refiOffers.length,
          (i) => GestureDetector(
            onTap: () => setState(() => _selectedRefi = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedRefi == i
                    ? _indigo.withValues(alpha: 0.12)
                    : _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _selectedRefi == i
                        ? _indigo.withValues(alpha: 0.5)
                        : const Color(0xFFE8EAF0),
                    width: _selectedRefi == i ? 1.5 : 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_refiOffers[i].lender,
                            style: const TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        Text('${_refiOffers[i].monthlyPayment}/mo',
                            style: TextStyle(
                                color: const Color(0xFF6B7080),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_refiOffers[i].rate,
                          style: const TextStyle(
                              color: _indigo,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      Text(_refiOffers[i].savings,
                          style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (_selectedRefi == i) ...[
                    const SizedBox(width: 10),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _indigo),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChrisLoanNudge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withValues(alpha: 0.15),
              border:
                  Border.all(color: _indigo.withValues(alpha: 0.4), width: 1),
            ),
            child:
                const Icon(Icons.auto_awesome_rounded, color: _indigo, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chris says',
                    style: TextStyle(
                        color: _indigo,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    'You\'re 7 years from PSLF forgiveness on \$28,500. Switching to SAVE drops your payment to \$186/mo — that\'s \$126/mo freed up to put toward your emergency fund, which is still at \$0.',
                    style: TextStyle(
                        color: const Color(0xFF6B7080),
                        fontSize: 13,
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
                          color: _indigo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Switch to SAVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Ask Chris',
                            style: TextStyle(
                                color: const Color(0xFF374151),
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

  // ── Tuition ROI Tab ───────────────────────────────────────────

  Widget _buildROITab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDegreeROICard(),
          const SizedBox(height: 24),
          _buildEmployerBenefitSection(),
          const SizedBox(height: 24),
          _buildCareerTrajectory(),
        ],
      ),
    );
  }

  Widget _buildDegreeROICard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _indigo.withValues(alpha: 0.08),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _indigo.withValues(alpha: 0.25), width: 1),
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
                  color: _indigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Computer Science BS',
                    style: TextStyle(
                        color: _indigoLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _roiStat('\$95K', 'Avg Starting Salary', const Color(0xFF22C55E)),
              _roiDivider(),
              _roiStat('340%', '10yr ROI', const Color(0xFF6B7280)),
              _roiDivider(),
              _roiStat('2027', 'Break-even Year', const Color(0xFF6B7280)),
            ],
          ),
          const SizedBox(height: 18),
          _sectionTitle('Total Investment vs Earnings'),
          const SizedBox(height: 12),
          _roiBar('Total Tuition Cost', '\$46,000', 0.42, const Color(0xFFEF4444)),
          const SizedBox(height: 8),
          _roiBar('10yr Cumulative Earnings', '\$980,000', 1.0, const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _roiBar('Without Degree (median)', '\$610,000', 0.62, Colors.white38),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  width: 1),
            ),
            child: Text(
                'Your degree generates \$370K more in 10 years than the no-degree median. At \$46K total cost, that\'s \$8.04 earned per \$1 spent.',
                style: TextStyle(
                    color: const Color(0xFF6B7080),
                    fontSize: 12,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _roiStat(String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          Text(label,
              style: TextStyle(
                  color: const Color(0xFF6B7080), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _roiDivider() {
    return Container(
        width: 1, height: 32, color: const Color(0xFFE8EAF0));
  }

  Widget _roiBar(String label, String amount, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: const Color(0xFF6B7080),
                    fontSize: 11)),
            const Spacer(),
            Text(amount,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            backgroundColor: const Color(0xFFE8EAF0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmployerBenefitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Employer Tuition Benefits'),
        const SizedBox(height: 6),
        Text('Many employers offer up to \$5,250/yr tax-free for education.',
            style: TextStyle(
                color: const Color(0xFF6B7080), fontSize: 12)),
        const SizedBox(height: 14),
        ...[
          _EmployerBenefit('Your Employer', '\$5,250/yr', true,
              'You qualify — apply through HR portal'),
          _EmployerBenefit('Amazon Career Choice', '\$5,250/yr', false,
              'Not your employer — shown for reference'),
          _EmployerBenefit('Starbucks Edu Program', 'Full tuition', false,
              'ASU online — not applicable here'),
        ].map((e) => _EmployerBenefitTile(benefit: e)),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.savings_rounded,
                  color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    '\$5,250/yr in employer benefits not claimed yet. That\'s real money left on the table.',
                    style: TextStyle(
                        color: const Color(0xFF6B7080),
                        fontSize: 12,
                        height: 1.4)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareerTrajectory() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Career Salary Trajectory',
              style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Median for Computer Science graduates.',
              style: TextStyle(
                  color: const Color(0xFF6B7080), fontSize: 11)),
          const SizedBox(height: 16),
          ...[
            _CareerLevel('Entry Level (Now)', '\$72,000', 0.40, const Color(0xFF6B7280)),
            _CareerLevel('Mid-Level (3-5 yrs)', '\$95,000', 0.55, const Color(0xFF6B7280)),
            _CareerLevel('Senior (6-10 yrs)', '\$130,000', 0.74, const Color(0xFF6B7280)),
            _CareerLevel('Staff / Lead (10+ yrs)', '\$175,000', 1.0, const Color(0xFF22C55E)),
          ].map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(c.level,
                            style: TextStyle(
                                color: const Color(0xFF6B7080),
                                fontSize: 12)),
                        const Spacer(),
                        Text(c.salary,
                            style: TextStyle(
                                color: c.color,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: c.progress,
                        backgroundColor: const Color(0xFFE8EAF0),
                        valueColor: AlwaysStoppedAnimation<Color>(c.color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Skills Tab ─────────────────────────────────────────────────

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChrisSkillRec(),
          const SizedBox(height: 24),
          _sectionTitle('Learning Apps'),
          const SizedBox(height: 6),
          Text(
              'Free to start. Chris picks based on your career path and learning style.',
              style: TextStyle(
                  color: const Color(0xFF6B7080), fontSize: 12)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.0,
            ),
            itemCount: _skillApps.length,
            itemBuilder: (_, i) => _SkillAppCard(app: _skillApps[i]),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Top Free Courses Right Now'),
          const SizedBox(height: 14),
          ...[
            _FreeCourse('Financial Modeling in Excel', 'Coursera', '4.8', '6hr',
                const Color(0xFF374151)),
            _FreeCourse('Python for Everybody', 'Coursera', '4.9', '8hr',
                const Color(0xFF374151)),
            _FreeCourse('Public Speaking Fundamentals', 'Udemy', '4.7', '3hr',
                const Color(0xFF374151)),
          ].map((c) => _FreeCourseCard(course: c)),
        ],
      ),
    );
  }

  Widget _buildChrisSkillRec() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withValues(alpha: 0.15),
              border: Border.all(
                  color: _indigo.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _indigo, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chris recommends',
                    style: TextStyle(
                        color: _indigo,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    'Adding financial modeling to your CS background puts you in the top 8% of candidates for FinTech roles — which pay 22% more than typical CS roles at your level.',
                    style: TextStyle(
                        color: const Color(0xFF6B7080),
                        fontSize: 13,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Color(0xFF1A1A2E), fontSize: 16, fontWeight: FontWeight.w700));
  }
}

// ── Overview link card (light theme) ────────────────────────────────────────

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF3F4F6)),
              child: Icon(icon, color: const Color(0xFF374151), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: TextStyle(color: const Color(0xFF6B7080), fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _IDRPlan {
  final String name, payment, note;
  final bool recommended;
  final Color color;
  const _IDRPlan(
      this.name, this.payment, this.note, this.recommended, this.color);
}

class _RefiOffer {
  final String lender, rate, monthlyPayment, savings;
  const _RefiOffer(this.lender, this.rate, this.monthlyPayment, this.savings);
}

class _SkillApp {
  final String name, description;
  final IconData icon;
  final Color color;
  const _SkillApp(this.name, this.description, this.icon, this.color);
}

class _EmployerBenefit {
  final String employer, amount, note;
  final bool eligible;
  const _EmployerBenefit(this.employer, this.amount, this.eligible, this.note);
}

class _CareerLevel {
  final String level, salary;
  final double progress;
  final Color color;
  const _CareerLevel(this.level, this.salary, this.progress, this.color);
}

class _FreeCourse {
  final String title, platform, rating, duration;
  final Color color;
  const _FreeCourse(
      this.title, this.platform, this.rating, this.duration, this.color);
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _IDRPlanCard extends StatelessWidget {
  final _IDRPlan plan;
  const _IDRPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: plan.recommended
            ? plan.color.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: plan.recommended
                ? plan.color.withValues(alpha: 0.4)
                : const Color(0xFFE8EAF0),
            width: plan.recommended ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(plan.name,
                        style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    if (plan.recommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: plan.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Recommended',
                            style: TextStyle(
                                color: plan.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(plan.note,
                    style: TextStyle(
                        color: const Color(0xFF6B7080),
                        fontSize: 11,
                        height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(plan.payment,
              style: TextStyle(
                  color: plan.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EmployerBenefitTile extends StatelessWidget {
  final _EmployerBenefit benefit;
  const _EmployerBenefitTile({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: benefit.eligible
                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                : const Color(0xFFE8EAF0),
            width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(benefit.employer,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(benefit.amount,
                  style: TextStyle(
                      color: benefit.eligible
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(benefit.note,
              style: TextStyle(
                  color: const Color(0xFF6B7080), fontSize: 11)),
        ],
      ),
    );
  }
}

class _SkillAppCard extends StatelessWidget {
  final _SkillApp app;
  const _SkillAppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: app.color.withValues(alpha: 0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: app.color.withValues(alpha: 0.12),
              ),
              child: Icon(app.icon, color: app.color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(app.name,
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(app.description,
                      style: TextStyle(
                          color: const Color(0xFF6B7080),
                          fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreeCourseCard extends StatelessWidget {
  final _FreeCourse course;
  const _FreeCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: course.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title,
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(course.platform,
                        style: TextStyle(
                            color: course.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    Text('  ·  ${course.duration}',
                        style: TextStyle(
                            color: const Color(0xFF6B7080),
                            fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF59E0B), size: 12),
                  const SizedBox(width: 2),
                  Text(course.rating,
                      style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Free',
                    style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
