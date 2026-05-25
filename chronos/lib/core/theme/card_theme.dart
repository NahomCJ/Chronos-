import 'package:flutter/material.dart';
import 'constants.dart';

class CCard {
  static CardThemeData theme(ColorScheme scheme) {
    return CardThemeData(
      color: scheme.surface,
      // elevation: Elevation.small,
      margin: const EdgeInsets.all(Constants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: Constants.borderRadiusMedium,
        side: BorderSide(
          color: scheme.outline,
          width: Constants.borderWidthThin,
        ),
      ),
      shadowColor: scheme.shadow,
      clipBehavior: Clip.antiAlias,
    );
  }
}