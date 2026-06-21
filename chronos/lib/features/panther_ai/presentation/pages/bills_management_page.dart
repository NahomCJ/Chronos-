import 'package:flutter/material.dart';

class BillsManagementPage extends StatefulWidget {
  const BillsManagementPage({super.key});

  @override
  State<BillsManagementPage> createState() => _BillsManagementPageState();
}

class _BillsManagementPageState extends State<BillsManagementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  static const _bg = Color(0xFFF5F6FA);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFEF4444);
  static const _amber = Color(0xFFF59E0B);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _textSubtle = Color(0xFF9CA3AF);
  static const _border = Color(0xFFE8EAF0);

  static const _bills = [
    _Bill('Rent / Mortgage', '\$1,850', 'Jun 1', Icons.home_rounded, Color(0xFF6366F1), true),
    _Bill('Electricity', '\$94', 'Jun 5', Icons.bolt_rounded, Color(0xFFF59E0B), false),
    _Bill('Internet', '\$79', 'Jun 8', Icons.wifi_rounded, Color(0xFF3B82F6), true),
    _Bill('Netflix', '\$22', 'Jun 10', Icons.play_circle_rounded, Color(0xFFEF4444), true),
    _Bill('Gym Membership', '\$45', 'Jun 12', Icons.fitness_center_rounded, Color(0xFF10B981), false),
    _Bill('Car Insurance', '\$186', 'Jun 15', Icons.directions_car_rounded, Color(0xFF8B5CF6), false),
    _Bill('Phone', '\$65', 'Jun 20', Icons.phone_android_rounded, Color(0xFF14B8A6), true),
  ];

  static const _categories = [
    _Category('Housing', 1850, Color(0xFF6366F1)),
    _Category('Utilities', 173, Color(0xFFF59E0B)),
    _Category('Entertainment', 22, Color(0xFFEF4444)),
    _Category('Transport', 186, Color(0xFF8B5CF6)),
    _Category('Health', 45, Color(0xFF10B981)),
    _Category('Communication', 65, Color(0xFF14B8A6)),
  ];

  double get _totalMonthly =>
      _categories.fold(0.0, (s, c) => s + c.amount);

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
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3F4F6)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF374151), size: 16),
          ),
        ),
        title: const Text('Bills Management',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('June 2025',
                style: TextStyle(
                    color: _blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.15))),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  _buildCategoryBars(),
                  const SizedBox(height: 24),
                  _buildUpcomingBills(),
                  const SizedBox(height: 24),
                  _buildAutoPayCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(22),
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
        border: Border.all(color: _blue.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _blue.withValues(alpha: 0.12)),
                child: const Icon(Icons.receipt_rounded,
                    color: _blue, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Bills',
                      style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12)),
                  Text('\$${_totalMonthly.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Next due',
                      style: TextStyle(
                          color: _textSubtle,
                          fontSize: 11)),
                  const Text('Jun 1',
                      style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  Text('in 3 days',
                      style: TextStyle(color: _amber, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _summaryBadge(Icons.check_circle_outline_rounded,
                  '4 on auto-pay', _green),
              const SizedBox(width: 10),
              _summaryBadge(Icons.pending_outlined, '3 manual', _amber),
              const SizedBox(width: 10),
              _summaryBadge(Icons.warning_amber_rounded, '0 overdue', _red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Flexible(
              child: Text(text,
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBars() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending by Category',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          ..._categories.map((c) {
            final pct = c.amount / _totalMonthly;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: c.color)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(c.name,
                              style: const TextStyle(
                                  color: _textSecondary,
                                  fontSize: 12))),
                      Text('\$${c.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct * _anim.value,
                      backgroundColor: _border,
                      valueColor: AlwaysStoppedAnimation(c.color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUpcomingBills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upcoming Bills',
            style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._bills.map((b) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: b.color.withValues(alpha: 0.12)),
                    child: Icon(b.icon, color: b.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.name,
                            style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: _textSubtle,
                                size: 10),
                            const SizedBox(width: 4),
                            Text(b.dueDate,
                                style: const TextStyle(
                                    color: _textSubtle,
                                    fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(b.amount,
                          style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: b.autoPay
                              ? _green.withValues(alpha: 0.10)
                              : _amber.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(b.autoPay ? 'Auto' : 'Manual',
                            style: TextStyle(
                                color: b.autoPay ? _green : _amber,
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAutoPayCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: 0.12)),
            child: const Icon(Icons.auto_mode_rounded,
                color: _green, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto-Pay Active',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 3),
                Text('4 of 7 bills paid automatically. Save time — enable auto-pay for remaining bills.',
                    style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Manage',
                style: TextStyle(
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Bill {
  final String name;
  final String amount;
  final String dueDate;
  final IconData icon;
  final Color color;
  final bool autoPay;
  const _Bill(
      this.name, this.amount, this.dueDate, this.icon, this.color, this.autoPay);
}

class _Category {
  final String name;
  final double amount;
  final Color color;
  const _Category(this.name, this.amount, this.color);
}
