import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TickPayAlertsPage extends StatefulWidget {
  const TickPayAlertsPage({super.key});

  @override
  State<TickPayAlertsPage> createState() => _TickPayAlertsPageState();
}

class _TickPayAlertsPageState extends State<TickPayAlertsPage> {
  bool _notificationsOn = true;

  static const _alerts = [
    _Alert('Payment Due Tomorrow', '1 day',
        'Your iPhone 15 Pro payment of \$249.75 is due May 22, 2026',
        '\$249.75', 'Apple Store', _AlertType.warning),
    _Alert('Payment Overdue', '3 days ago',
        'Your Samsung TV payment was due 3 days ago. Please pay to avoid late fees',
        '\$149.75', 'Samsung', _AlertType.danger),
    _Alert('Upcoming Payments', '2 hours ago',
        'You have 3 payments due within the next 7 days totaling \$382.00',
        null, null, _AlertType.info),
    _Alert('Great Payment Record!', '1 day ago',
        'You\'ve made 6 on-time payments this month. Keep up the excellent work.',
        null, null, _AlertType.success),
    _Alert('Payment Confirmation', '4 days ago',
        'Your payment of \$87.25 to Best Buy was successfully processed.',
        '\$87.25', 'Best Buy', _AlertType.success),
    _Alert('Spending Insight', '1 week ago',
        'You have saved \$45 in interest this month using BNPL instead of credit cards.',
        null, null, _AlertType.insight),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withValues(alpha: 0.5)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildNotifToggle(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _alerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _buildAlertCard(_alerts[i]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alerts',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Payment notifications & insights',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotifToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_active,
                color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Notifications',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            Switch(
              value: _notificationsOn,
              onChanged: (v) => setState(() => _notificationsOn = v),
              activeColor: const Color(0xFF3B82F6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(_Alert alert) {
    final colors = _alertColors(alert.type);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.$1.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.$1.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.$1.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(colors.$2, color: colors.$1, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(alert.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    Text(alert.time,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(alert.body,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.4)),
                if (alert.amount != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                            '${alert.amount}  ${alert.store ?? ''}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.$1.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Pay Now →',
                            style: TextStyle(
                                color: colors.$1,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _alertColors(_AlertType type) {
    switch (type) {
      case _AlertType.warning:
        return (const Color(0xFFDC8F4A), Icons.schedule);
      case _AlertType.danger:
        return (const Color(0xFFFF5252), Icons.warning_amber);
      case _AlertType.info:
        return (const Color(0xFF3B82F6), Icons.calendar_today);
      case _AlertType.success:
        return (const Color(0xFF00C853), Icons.star_border);
      case _AlertType.insight:
        return (const Color(0xFF7C3AED), Icons.lightbulb_outline);
    }
  }
}

enum _AlertType { warning, danger, info, success, insight }

class _Alert {
  final String title, time, body;
  final String? amount, store;
  final _AlertType type;
  const _Alert(this.title, this.time, this.body, this.amount, this.store,
      this.type);
}
