import 'package:flutter/material.dart';

import '../../../../core/theme/text_theme.dart';
import '../../domain/entities/shortcut_action.dart';
import '../constants/tickpay_colors.dart';
import 'tickpay_glyph.dart';

/// A single circular shortcut on the Shortcuts screen (white circle, dark
/// glyph), with its label below.
class ShortcutTile extends StatelessWidget {
  final ShortcutAction action;
  final VoidCallback? onTap;

  const ShortcutTile({super.key, required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: TickpayGlyph(
              asset: action.iconAsset,
              color: Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            action.label,
            style: TextStyles.bodyMedium.copyWith(
              color: TickpayColors.textOnDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
