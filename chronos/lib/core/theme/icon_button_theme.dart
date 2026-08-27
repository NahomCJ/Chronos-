import 'package:flutter/material.dart';

import 'constants.dart';

class IIconButton {
  static IconButtonThemeData theme(ColorScheme scheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: Constants.paddingAllSmall,
        shape: const RoundedRectangleBorder(
          borderRadius: Constants.borderRadiusMedium,
        ),
        iconSize: IconSize.small,
      ),
    );
  }
}
