import 'package:flutter/material.dart';

import '../constants/tickpay_colors.dart';

/// Circular translucent icon button (e.g. the back arrow in the header).
class TickpayCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const TickpayCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = TickpayColors.textOnDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TickpayColors.glassStrong,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}
