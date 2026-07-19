import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../utils/tickpay_formatters.dart';
import '../../../../core/widgets/fluid_glass.dart';
import '../constants/tickpay_colors.dart';

class TickPayUpcomingPaymentsPage extends StatefulWidget {
  const TickPayUpcomingPaymentsPage({super.key});

  @override
  State<TickPayUpcomingPaymentsPage> createState() =>
      _TickPayUpcomingPaymentsPageState();
}

class _TickPayUpcomingPaymentsPageState
    extends State<TickPayUpcomingPaymentsPage> {
  late DateTime _focusedMonth;
  late int _selectedDay;

  // Payments keyed by day-of-month (relative to current month)
  static const _payments = [
    _Payment('iPhone 15 Pro', 'Apple Store', '\$249.75', '1 of 4',
        'Due Today', true, 21),
    _Payment('Sony WH-1000XM5', 'Best Buy', '\$87.25', '2 of 4', 'Due Soon',
        true, 24),
    _Payment('Air Max Plus', 'Nike', '\$45.00', '3 of 4', 'Due Soon', false, 24),
    _Payment('MacBook Air M3', 'Apple Store', '\$274.75', '2 of 5',
        'Scheduled', true, 28),
    _Payment('55" 4K TV', 'Samsung', '\$149.75', '1 of 4', 'Scheduled', true, 30),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = now.day;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Due Today': return TickpayColors.negative;
      case 'Due Soon':  return TickpayColors.warning;
      default:          return TickpayColors.accentPurple;
    }
  }

  List<_Payment> get _paymentsForSelectedDay =>
      _payments.where((p) => p.day == _selectedDay).toList();

  List<int> get _paymentDays => _payments.map((p) => p.day).toSet().toList();

  int get _daysInMonth =>
      DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

  // 0=Sun 1=Mon … 6=Sat offset for first day of month
  int get _firstWeekdayOffset {
    final wd = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    return wd % 7; // DateTime.weekday: 1=Mon…7=Sun → convert so Sun=0
  }

  String _monthName(int m) => const [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][m];

  void _prevMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    _selectedDay = 1;
  });

  void _nextMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    _selectedDay = 1;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 4,
        onItemSelected: (i) {
          switch (i) {
            case 0: context.go(RouteConstants.home.toPath);
            case 1: context.go(RouteConstants.pantherAi.toPath);
            case 2: context.go(RouteConstants.blockHub.toPath);
          }
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/tickpay/background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0D0D1A)),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildDueTodayCard(),
                  const SizedBox(height: 14),
                  Container(
                    decoration: const BoxDecoration(
                      color: TickpayColors.lightSheet,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarCard(),
                        const SizedBox(height: 18),
                        if (_paymentsForSelectedDay.isNotEmpty) ...[
                          Text(
                            'Payments on ${_monthName(_focusedMonth.month)} $_selectedDay',
                            style: const TextStyle(
                                color: TickpayColors.textPrimaryLight,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ..._paymentsForSelectedDay.map(
                              (p) => _buildRow(context, p)),
                          const SizedBox(height: 16),
                        ],
                        const Text('All Payments',
                            style: TextStyle(
                                color: TickpayColors.textPrimaryLight,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ..._payments.map((p) => _buildRow(context, p)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upcoming Payments',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Manage your payment schedule',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: Color(0xFFDC8F4A), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDueTodayCard() {
    final today = _payments.where((p) => p.status == 'Due Today').toList();
    final total = today.fold(0.0, (sum, p) {
      final raw = p.amount.replaceAll(RegExp(r'[^\d.]'), '');
      return sum + (double.tryParse(raw) ?? 0);
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: FluidGlass.dark(
        padding: const EdgeInsets.all(4),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: TickpayColors.negative.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.event_busy_rounded,
                                color: TickpayColors.negative, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Text('Due Today',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        total > 0 ? TickpayFormatters.moneyPrecise(total) : '\$0.00',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, color: Colors.white.withValues(alpha: 0.12)),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Payments',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text(
                        '${today.length}',
                        style: const TextStyle(
                            color: TickpayColors.negative,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final totalCells = _firstWeekdayOffset + _daysInMonth;
    final rows = (totalCells / 7).ceil();
    final payDays = _paymentDays;
    final today = DateTime.now();
    final isCurrentMonth = _focusedMonth.year == today.year &&
        _focusedMonth.month == today.month;

    return FluidGlass.light(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                style: const TextStyle(
                    color: TickpayColors.textPrimaryLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              Row(children: [
                GestureDetector(
                  onTap: _prevMonth,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: TickpayColors.accentPurple.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: TickpayColors.accentPurple, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: TickpayColors.accentPurple.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: TickpayColors.accentPurple, size: 20),
                  ),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days
                .map((d) => SizedBox(
                      width: 32,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: TickpayColors.textMutedLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          ...List.generate(rows, (r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (c) {
                  final cellIndex = r * 7 + c;
                  final day = cellIndex - _firstWeekdayOffset + 1;
                  if (day < 1 || day > _daysInMonth) {
                    return const SizedBox(width: 32, height: 32);
                  }
                  final isPayment = payDays.contains(day);
                  final isSelected = _selectedDay == day;
                  final isToday = isCurrentMonth && day == today.day;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isPayment
                            ? TickpayColors.accentPurple
                            : isSelected
                                ? TickpayColors.accentPurple.withValues(alpha: 0.12)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday && !isPayment
                            ? Border.all(color: TickpayColors.accentPurple, width: 1.5)
                            : isSelected && !isPayment
                                ? Border.all(
                                    color: TickpayColors.accentPurple.withValues(alpha: 0.4))
                                : null,
                      ),
                      child: Center(
                        child: Text('$day',
                            style: TextStyle(
                              color: isPayment
                                  ? Colors.white
                                  : isSelected || isToday
                                      ? TickpayColors.accentPurple
                                      : TickpayColors.textPrimaryLight,
                              fontSize: 13,
                              fontWeight: isPayment || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(
                    color: TickpayColors.accentPurple, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('Payment due',
                  style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 11)),
              const SizedBox(width: 14),
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  border: Border.all(color: TickpayColors.accentPurple, width: 1.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('Today',
                  style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, _Payment p) {
    final sc = _statusColor(p.status);
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayRepayNow.toPath),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: sc.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.shopping_bag_outlined, color: sc, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          color: TickpayColors.textPrimaryLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(p.store,
                      style: TextStyle(
                          color: TickpayColors.textMutedLight, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(p.amount,
                    style: const TextStyle(
                        color: TickpayColors.textPrimaryLight,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(p.status,
                      style: TextStyle(
                          color: sc,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
                if (p.autoPay) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: TickpayColors.positive.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Auto-pay',
                        style: TextStyle(
                            color: TickpayColors.positive,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Payment {
  final String name, store, amount, installment, status;
  final bool autoPay;
  final int day;
  const _Payment(this.name, this.store, this.amount, this.installment,
      this.status, this.autoPay, this.day);
}
