import 'package:flutter/material.dart';

import 'constants.dart';
class LListTile{
static ListTileThemeData theme(ColorScheme scheme) {
  return ListTileThemeData(
    iconColor: scheme.primary,
    textColor: scheme.onSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: Constants.borderRadiusMedium,
    ),
  );
}
}