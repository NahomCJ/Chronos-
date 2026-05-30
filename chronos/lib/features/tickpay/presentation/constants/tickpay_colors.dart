import 'package:flutter/material.dart';

/// Centralized color palette for the TickPay feature, derived from the
/// Figma design system. Keeping these in one place guarantees a consistent
/// look across every screen and makes future re-theming a single-file change.
class TickpayColors {
  const TickpayColors._();

  // Dark surfaces (onboarding + dashboard headers).
  static const Color scaffoldDark = Color(0xFF120B1A);
  static const Color pureBlack = Colors.black;

  // Glass / translucent surfaces layered over the dark background.
  static const Color glassFill = Color(0x0DFFFFFF); // white @ 5%
  static const Color glassBorder = Color(0x1AFFFFFF); // white @ 10%
  static const Color glassStrong = Color(0x1FFFFFFF); // white @ ~12%

  // Light "sheet" area that slides up from the bottom on detail screens.
  static const Color lightSheet = Color(0xFFF8F9FA);
  static const Color cardWhite = Colors.white;
  static const Color neutralSurface = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFEEEEEE);

  // Brand red gradient used on every primary CTA.
  static const Color brandRedDark = Color(0xFF8B0000);
  static const Color brandRed = Color(0xFFE53935);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandRedDark, brandRed],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Accents.
  static const Color accentOrange = Color(0xFFDC8F4A);
  static const Color accentGold = Color(0xFFF5A623);
  static const Color positiveGreen = Color(0xFF20C55D);
  static const Color infoCyan = Color(0xFF00E5FF);
  static const Color warningAmber = Color(0xFFFFD54F);
  static const Color warningAmberText = Color(0xFFF57F17);

  // Typography colors.
  static const Color textOnDark = Colors.white;
  static const Color textMutedDark = Color(0xFFA1A1A1);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textMutedLight = Color(0xFF666666);

  // Category chip tints (Active Plans).
  static const Color chipElectronicsBg = Color(0xFFE3F2FD);
  static const Color chipElectronicsText = Color(0xFF1976D2);
  static const Color chipFashionBg = Color(0xFFF3E5F5);
  static const Color chipFashionText = Color(0xFF8E24AA);
  static const Color chipHomeBg = Color(0xFFE8F5E9);
  static const Color chipHomeText = Color(0xFF2E7D32);
}
