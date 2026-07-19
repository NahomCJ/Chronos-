import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/tickpay_notification.dart';
import '../constants/tickpay_colors.dart';

/// A single notification card on the Notifications screen.
class NotificationCard extends StatelessWidget {
  final TickpayNotification notification;

  const NotificationCard({super.key, required this.notification});

  IconData get _icon {
    switch (notification.type) {
      case TickpayNotificationType.payment:
        return Icons.attach_money;
      case TickpayNotificationType.offer:
        return Icons.star_border;
      case TickpayNotificationType.approval:
        return Icons.check_circle_outline;
      case TickpayNotificationType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TickpayColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: TickpayColors.neutralSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyles.titleMedium.copyWith(
                          color: TickpayColors.textPrimaryLight,
                          fontWeight: notification.isUnread
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (notification.isUnread)
                      Container(
                        margin: const EdgeInsets.only(top: 6, left: 8),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: TickpayColors.infoCyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyles.bodySmall.copyWith(
                    color: TickpayColors.textMutedLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      notification.time,
                      style: TextStyles.labelSmall
                          .copyWith(color: TickpayColors.textMutedDark),
                    ),
                    const Spacer(),
                    if (notification.isImportant)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Important',
                          style: TextStyles.labelSmall.copyWith(
                            color: TickpayColors.brandRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
}
