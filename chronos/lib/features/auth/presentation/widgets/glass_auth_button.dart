import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/constants.dart';

class GlassAuthButton extends StatelessWidget {
  final String label;
  final Widget? leading;
  final IconData? icon;
  final VoidCallback? onPressed;

  const GlassAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return ClipRRect(
      borderRadius: Constants.borderRadiusFull,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: Constants.borderRadiusFull,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: disabled ? 0.10 : 0.16),
                Colors.white.withValues(alpha: disabled ? 0.06 : 0.10),
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 12),
                      ] else if (icon != null) ...[
                        Icon(icon, color: Colors.white),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: disabled ? 0.75 : 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
