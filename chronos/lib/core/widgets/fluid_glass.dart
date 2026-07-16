import 'dart:ui';
import 'package:flutter/material.dart';

/// FluidGlass — frosted glass container.
///
/// Use [FluidGlass.dark] on dark backgrounds (#06060E, #0A0A14, bg.png pages).
/// Use [FluidGlass.light] on light backgrounds (#F5F5F5, #F5F6FA).
/// Use the default constructor for full control.
class FluidGlass extends StatelessWidget {
  const FluidGlass({
    super.key,
    required this.child,
    this.blur = 14.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding,
    this.tintColor = const Color(0xFFFFFFFF),
    this.tintOpacity = 0.09,
    this.showBorder = true,
    this.showShadow = true,
  });

  /// Dark-background variant: subtle dark gradient on deep dark / bg-image pages.
  /// The dark tint improves text legibility without killing the glass effect.
  const FluidGlass.dark({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding,
    this.showBorder = true,
    this.showShadow = true,
  })  : tintColor = const Color(0xFF000000),
        tintOpacity = 0.22;

  /// Light-background variant: frosted white on light pages.
  const FluidGlass.light({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding,
    this.showBorder = true,
    this.showShadow = true,
  })  : tintColor = const Color(0xFFFFFFFF),
        tintOpacity = 0.72;

  final Widget child;
  final double blur;
  final BorderRadius borderRadius;
  final EdgeInsets? padding;
  final Color tintColor;
  final double tintOpacity;
  final bool showBorder;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final isLight = tintOpacity > 0.4;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tintColor.withValues(alpha: tintOpacity + 0.05),
                tintColor.withValues(alpha: (tintOpacity - 0.03).clamp(0, 1)),
              ],
            ),
            border: showBorder
                ? Border.all(
                    color: isLight
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.14),
                    width: 0.8,
                  )
                : null,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: isLight ? 0.06 : 0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
