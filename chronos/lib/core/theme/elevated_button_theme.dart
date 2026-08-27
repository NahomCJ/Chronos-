import 'package:flutter/material.dart';
import 'constants.dart';
import 'text_theme.dart';
import 'preset_colors.dart';

class BButton {
  static ElevatedButtonThemeData theme(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CColor.primaryButton,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 44),
        padding: Constants.paddingHorizontalMedium,
        shape: const StadiumBorder(), // Capsule shape from image
        textStyle: TextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        elevation: 0,
      ),
    );
  }
}
