import 'package:flutter/material.dart';
import 'constants.dart';
import 'text_theme.dart';

class AAppBar {
  static AppBarTheme theme(ColorScheme scheme) {
    return AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyles.headlineMedium,
      iconTheme: const IconThemeData(
        size: IconSize.medium,
      ),
      actionsIconTheme: const IconThemeData(
        size: IconSize.medium,
      ),
      toolbarHeight: Constants.appBarHeight,
    );
  }
}
