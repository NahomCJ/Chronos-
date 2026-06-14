import 'package:flutter/material.dart';

class BudgetIntelligencePage extends StatefulWidget {
  const BudgetIntelligencePage({super.key});

  @override
  State<BudgetIntelligencePage> createState() => _BudgetIntelligencePageState();
}

class _BudgetIntelligencePageState extends State<BudgetIntelligencePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;
  int _selectedPeriod = 0;

  static const _bg = Color(0xFF06060E);
  static const _card = Color(0xFF0F0F1C);
  static const _teal = Color(0xFF14B8A6);
  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFEF4444);
  static const _amber = Color(0xFFF59E0B);

  static const _periods = ['This Month', 'Last Month', 'YTD'];

  static const _categories = [
    _BudgetCat('Housing', 2100, 2100, Color(0xFF6366F1), Icons.home_rounded),
    _BudgetCat('Food & Dining', 480, 600, Color(0xFF10B981), Icons.restaurant_rounded),
    _BudgetCat('Transport', 320, 400, Color(0xFF8B5CF6), Icons.directions_car_rounded),
    _BudgetCat('Entertainment', 165, 200, Color(0xFFEC4899), Icons.movie_rounded),
    _BudgetCat('Shopping', 390, 300, Color(0xFFEF4444), Icons.shopping_bag_rounded),
    _BudgetCat('Health', 95, 150, Color(0xFF14B8A6), Icons.favorite_rounded),
    _BudgetCat('Savings', 500, 500, Color(0xFF22C55E), Icons.savings_rounded),
  ];

  double get _totalBudget =>
      _categories.fold(0.0, (s, c) => s + c.budget);
  double get _totalSpent =>
      _categories.fold(0.0, (s, c) => s + c.spent);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
        title: const Text('Budget Intelligence',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
      body: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodToggle(),
              const SizedBox(height: 20),
              _buildOverviewCard(),
              const SizedBox(height: 24),
              _buildRingProgress(),
              const SizedBox(height: 24),
              _buildCategoryList(),
              const SizedBox(height: 24),
              _buildChrisInsight(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          _periods.length,
          (i) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedPeriod == i
                      ? _teal.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _periods[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedPeriod == i
                        ? _teal
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: _selectedPeriod == i
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final pct = _totalSpent / _totalBudget;
    final over = _totalSpent > _totalBudget;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _teal.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _teal.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12)),
                  Text('\$${_totalSpent.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Budget',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11)),
                  Text('\$${_totalBudget.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (pct * _anim.value).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(
                  over ? _red : pct > 0.85 ? _amber : _green),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                over
                    ? 'Over budget by \$${(_totalSpent - _totalBudget).toStringAsFixed(0)}'
                    : '\$${(_totalBudget - _totalSpent).toStringAsFixed(0)} remaining',
                style: TextStyle(
                    color: over ? _red : _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text('${(pct * 100).toStringAsFixed(0)}% used',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRingProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Overview',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((c) {
                final pct = (c.spent / c.budget).clamp(0.0, 1.0);
                final over = c.spent > c.budget;
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              value: pct * _anim.value,
                              strokeWidth: 5,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.07),
                              valueColor: AlwaysStoppedAnimation(
                                  over ? _red : c.color),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Icon(c.icon, color: c.color, size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(c.name.split(' ').first,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10)),
                      const SizedBox(height: 2),
                      Text('${(pct * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                              color: over ? _red : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Breakdown',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._categories.map((c) {
          final pct = (c.spent / c.budget).clamp(0.0, 1.0);
          final over = c.spent > c.budget;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: over
                      ? _red.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.06),
                  width: 0.8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.color.withValues(alpha: 0.12)),
                      child: Icon(c.icon, color: c.color, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(c.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text('\$${c.spent.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: over ? _red : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text(' / \$${c.budget.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct * _anim.value,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor:
                        AlwaysStoppedAnimation(over ? _red : c.color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChrisInsight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _teal.withValues(alpha: 0.12)),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _teal, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chris suggests',
                    style: TextStyle(
                        color: _teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(
                  'Shopping is \$90 over budget this month. Redirecting that to savings would hit your 3-month emergency fund goal by September.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCat {
  final String name;
  final double spent;
  final double budget;
  final Color color;
  final IconData icon;
  const _BudgetCat(this.name, this.spent, this.budget, this.color, this.icon);
}
