import 'package:flutter/material.dart';

/// Canonical light-theme palette for the Panther AI financial-intelligence
/// dashboards (portfolio, net worth, tax, budget, liabilities, market,
/// trading, rebalancing, etc). Before this, each page defined its own
/// private `_bg`/`_card`/accent constants, which drifted into two competing
/// families (a light one and an unrelated dark "neon" one) plus 7+ one-off
/// accent colors with no semantic meaning. Semantic colors match the
/// app-wide values documented in chronos/CLAUDE.md's Design System section.
class PantherColors {
  PantherColors._();

  static const bg = Color(0xFFF5F6FA);
  static const card = Colors.white;
  static const cardAlt = Color(0xFFF3F4F6);
  static const border = Color(0xFFE8EAF0);

  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7080);
  static const textSubtle = Color(0xFF9CA3AF);

  // Semantic — matches CLAUDE.md's app-wide Positive/Warning/Info/Negative.
  static const positive = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const negative = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Single Panther AI brand accent — already the recurring choice across
  // panther_ai_page.dart, budget/liabilities intelligence, and tickpay_ai.
  static const brand = Color(0xFF7C6EF0);
  static const brandLight = Color(0xFFEDE9FE);
  static const brandDark = Color(0xFF5B3FC4);
}
