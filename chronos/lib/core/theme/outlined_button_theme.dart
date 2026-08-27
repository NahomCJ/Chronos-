import 'index.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class OOutlinedButton {
  static OutlinedButtonThemeData theme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        minimumSize: const Size(0, 40),
        padding: Constants.paddingHorizontalMedium
            .add(Constants.paddingVerticalTiny),
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.primary),
        textStyle: TextStyles.bodyMedium,
      ),
    );
  }
}
