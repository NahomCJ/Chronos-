import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../constants/tickpay_colors.dart';
import 'tickpay_circle_button.dart';

/// Shared dark-surface header for TickPay dashboard-style screens.
///
/// Supports either a leading avatar (dashboard) or a back button (detail
/// screens), a title/subtitle block, and the standard notification + chat
/// trailing actions.
class TickpayHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final ImageProvider? avatar;
  final VoidCallback? onNotifications;
  final VoidCallback? onChat;

  const TickpayHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.avatar,
    this.onNotifications,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          if (onBack != null) ...[
            TickpayCircleButton(icon: Icons.arrow_back, onTap: onBack!),
            const SizedBox(width: 12),
          ] else if (avatar != null) ...[
            CircleAvatar(radius: 22, backgroundImage: avatar),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.titleMedium.copyWith(
                    color: TickpayColors.textOnDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyles.bodySmall.copyWith(
                    color: TickpayColors.textMutedDark,
                  ),
                ),
              ],
            ),
          ),
          if (onNotifications != null)
            _OutlinedActionIcon(
              icon: Icons.notifications_none,
              onTap: onNotifications!,
            ),
          if (onChat != null) ...[
            const SizedBox(width: 12),
            Material(
              color: TickpayColors.accentOrange,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onChat,
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OutlinedActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OutlinedActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: TickpayColors.glassStrong, width: 1),
        ),
        child: Icon(icon, color: TickpayColors.textOnDark, size: 18),
      ),
    );
  }
}
