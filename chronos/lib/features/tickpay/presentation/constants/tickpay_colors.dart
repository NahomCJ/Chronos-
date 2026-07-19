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

  // Light "sheet" area that slides up from the bottom on detail screens —
  // also the canonical page background now that TickPay is a light-theme
  // feature. `scaffoldLight` is the name to reach for on a new page;
  // `lightSheet` stays for the existing bottom-sheet call sites.
  static const Color scaffoldLight = Color(0xFFF8F9FA);
  static const Color lightSheet = Color(0xFFF8F9FA);
  static const Color cardWhite = Colors.white;
  static const Color neutralSurface = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFEEEEEE);

  // Brand red gradient used on every primary CTA — TickPay's one brand
  // accent. Not to be used for semantic error/negative states; see
  // `negative` below for that.
  static const Color brandRedDark = Color(0xFF8B0000);
  static const Color brandRed = Color(0xFFE53935);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandRedDark, brandRed],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Secondary accent — the recurring purple across ai-picks/active-plans/
  // rewards/etc, formalized here instead of each page picking its own
  // shade (previously 8+ different purples/violets across the feature).
  static const Color accentPurple = Color(0xFF7C3AED);

  // Semantic — matches the shared PantherColors / app-wide CLAUDE.md values,
  // so a "positive" or "negative" figure reads the same in TickPay as it
  // does everywhere else in the app.
  static const Color positive = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color negative = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Deprecated aliases — kept so existing call sites don't all need to
  // change in the same commit; new code should use positive/warning/info.
  static const Color accentOrange = Color(0xFFDC8F4A);
  static const Color accentGold = Color(0xFFF5A623);
  static const Color positiveGreen = positive;
  static const Color infoCyan = info;
  static const Color warningAmber = warning;
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
