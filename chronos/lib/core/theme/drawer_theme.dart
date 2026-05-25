import 'package:flutter/material.dart';
import 'constants.dart'; 

class DDrawer {
  static DrawerThemeData theme(ColorScheme scheme) {
    return DrawerThemeData(
      backgroundColor: scheme.surface,
      elevation: Elevation.medium,
      shape: RoundedRectangleBorder(
        borderRadius: Constants.borderRadiusLarge,
        side: BorderSide(
          color: scheme.outlineVariant,
          width: Constants.borderWidthThin,
        ),
      ),
      scrimColor: scheme.scrim.withOpacity(0.6),
      width: 200,
    );
  }
}
