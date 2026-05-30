import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/theme/text_theme.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../constants/tickpay_colors.dart';
import '../widgets/widgets.dart';

/// Lists TickPay notifications (payments, offers, approvals, info).
class TickpayNotificationsPage extends StatelessWidget {
  const TickpayNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = sl<TickpayRepository>().getNotifications();
    final int unread = notifications.where((n) => n.isUnread).length;

    return Scaffold(
      backgroundColor: TickpayColors.lightSheet,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B1430), Color(0xFF120B1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    TickpayCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyles.titleLarge.copyWith(
                              color: TickpayColors.textOnDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$unread unread',
                            style: TextStyles.bodySmall
                                .copyWith(color: TickpayColors.textMutedDark),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Mark all read',
                        style: TextStyles.bodyMedium
                            .copyWith(color: TickpayColors.infoCyan),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) =>
                  NotificationCard(notification: notifications[i]),
            ),
          ),
        ],
      ),
    );
  }
}
