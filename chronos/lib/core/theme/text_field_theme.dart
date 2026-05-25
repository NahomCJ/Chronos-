import 'package:flutter/material.dart';
import 'constants.dart';

class TTextField {
  static InputDecorationTheme theme(ColorScheme scheme) {
    return InputDecorationTheme(
      contentPadding: Constants.paddingAllSmall
          .add(Constants.paddingAllSmall), 

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.paddingSmall),
        borderSide: BorderSide(
          color: scheme.outline,
          width: Constants.borderWidthThin,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.paddingSmall),
        borderSide: BorderSide(
          color: scheme.outline,
          width: Constants.borderWidthThin,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.paddingSmall),
        borderSide: BorderSide(
          color: scheme.primary,
          width: Constants.borderWidthMedium,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.paddingSmall),
        borderSide: BorderSide(
          color: scheme.error,
          width: Constants.borderWidthThin,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Constants.paddingSmall),
        borderSide: BorderSide(
          color: scheme.error,
          width: Constants.borderWidthMedium,
        ),
      ),

      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      labelStyle: TextStyle(color: scheme.onSurface),
      errorStyle: TextStyle(color: scheme.error),
    );
  }
}
