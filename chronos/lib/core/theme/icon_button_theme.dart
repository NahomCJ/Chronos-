import 'package:flutter/material.dart';

import 'constants.dart';

class IIconButton {
  static IconButtonThemeData theme(ColorScheme scheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: Constants.paddingHorizontalMedium
            .add(Constants.paddingVerticalSmall),
        shape: const RoundedRectangleBorder(
          borderRadius: Constants.borderRadiusMedium,
        ),
        iconSize: IconSize.medium,
      ),
    );
  }
}
