import 'index.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class OOutlinedButton {
  static OutlinedButtonThemeData theme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: Constants.paddingHorizontalMedium
            .add(Constants.paddingVerticalSmall),
        shape: const RoundedRectangleBorder(
          borderRadius: Constants.borderRadiusMedium,
        ),
        side: BorderSide(color: scheme.primary),
        textStyle: TextStyles.bodyMedium,
      ),
    );
  }
}
