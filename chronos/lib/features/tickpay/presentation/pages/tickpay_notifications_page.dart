import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TickPayNotificationsPage extends StatelessWidget {
  const TickPayNotificationsPage({super.key});

  static const _items = [
    _Notif(
      icon: Icons.attach_money,
      title: 'Payment Due Soon',
      body: 'Amazon payment of \$149.75 is due',
      unread: false,
    ),
    _Notif(
      icon: Icons.star_border,
      title: 'Holiday Sale Alert',
      body: 'Save 30% on electronics at Best Buy',
      unread: true,
    ),
    _Notif(
      icon: Icons.check_circle_outline,
      title: 'Purchase Approved',
      body: 'Your \$450 purchase at Nike has been approved',
      unread: false,
    ),
    _Notif(
      icon: Icons.access_time,
      title: 'Credit Limit Increased',
      body: 'Your credit limit of \$89.00 paid successfully on Dec 25',
      unread: true,
    ),
    _Notif(
      icon: Icons.attach_money,
      title: 'Payment Due Soon',
      body: 'Electricity bill of \$89.00 paid successfully on Dec 25',
      unread: false,
    ),
    _Notif(
      icon: Icons.lightbulb_outline,
      title: 'Smart Spending Tip',
      body: 'Refund of \$45.00 issued for returned item',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color(0xFF1A0A2E),
                child: SafeArea(
                  bottom: false,
                  child: _buildHeader(context),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _buildNotifCard(_items[i]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '2 unread',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Mark all read',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(_Notif notif) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.unread ? const Color(0xFFF3EFFF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notif.unread
              ? const Color(0xFFD4C8FF)
              : const Color(0xFFEEEEEE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: notif.unread
                  ? const Color(0xFFEDE7FF)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(notif.icon,
                color: notif.unread
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFF888888),
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.title,
                  style: TextStyle(
                    color: const Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontWeight:
                        notif.unread ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  notif.body,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (notif.unread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: Color(0xFFFF2D87),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final String title, body;
  final bool unread;
  const _Notif(
      {required this.icon,
      required this.title,
      required this.body,
      required this.unread});
}
