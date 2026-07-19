import 'package:flutter/material.dart';
import 'index.dart';

class AppTheme {
    static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CColor.seedPrimary,
        secondary: CColor.seedSecondary,
        tertiary: CColor.seedTertiary,
        brightness: Brightness.light,
        
      ),
    );
      return base.copyWith(
      elevatedButtonTheme: BButton.theme(base.colorScheme),
      outlinedButtonTheme: OOutlinedButton.theme(base.colorScheme),
      iconButtonTheme: IIconButton.theme(base.colorScheme),
      appBarTheme: AAppBar.theme(base.colorScheme),
      cardTheme: CCard.theme(base.colorScheme),
      listTileTheme: LListTile.theme(base.colorScheme),
      drawerTheme: DDrawer.theme(base.colorScheme),
      tabBarTheme: TTabBar.theme(base.colorScheme),
      scaffoldBackgroundColor: base.colorScheme.surface,
      
    );
  }

static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CColor.seedPrimary,
        secondary: CColor.seedSecondary,
        tertiary: CColor.seedTertiary,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      elevatedButtonTheme: BButton.theme(base.colorScheme),
      outlinedButtonTheme: OOutlinedButton.theme(base.colorScheme),
      iconButtonTheme: IIconButton.theme(base.colorScheme),
      cardTheme: CCard.theme(base.colorScheme),
      listTileTheme: LListTile.theme(base.colorScheme),
      drawerTheme: DDrawer.theme(base.colorScheme),
      appBarTheme: AAppBar.theme(base.colorScheme),
      tabBarTheme: TTabBar.theme(base.colorScheme),
      scaffoldBackgroundColor: base.colorScheme.surface,
    );
  }
}