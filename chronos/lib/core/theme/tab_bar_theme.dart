import 'package:flutter/material.dart';

class TTabBar {
  static TabBarThemeData theme(ColorScheme scheme) {
    return TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: scheme.primary,
          width: 2,
        ),
      ),
      overlayColor: WidgetStatePropertyAll(
        scheme.primary.withValues(alpha: 0.08),
      ),
      dividerColor: scheme.outlineVariant,
    );
  }
}