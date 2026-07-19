import 'package:flutter/material.dart';

class Constants {
  //====================== Padding ======================================

  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  //====================== appbar ================================
  static const double appBarHeight = 56.0;


//====================== Border Widths ================================
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 2.0;
  static const double borderWidthThick = 3.0;


  // EdgeInsets for reuse
  static const EdgeInsets paddingAllTiny = EdgeInsets.all(paddingTiny);
  static const EdgeInsets paddingAllSmall = EdgeInsets.all(paddingSmall);
  static const EdgeInsets paddingAllMedium = EdgeInsets.all(paddingMedium);
  static const EdgeInsets paddingAllLarge = EdgeInsets.all(paddingLarge);
  static const EdgeInsets paddingAllExtraLarge = EdgeInsets.all(
    paddingExtraLarge,
  );

  // Horizontal Padding
  static const EdgeInsets paddingHorizontalTiny = EdgeInsets.symmetric(
    horizontal: paddingTiny,
  );
  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(
    horizontal: paddingSmall,
  );
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(
    horizontal: paddingMedium,
  );
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(
    horizontal: paddingLarge,
  );
  static const EdgeInsets paddingHorizontalExtraLarge = EdgeInsets.symmetric(
    horizontal: paddingExtraLarge,
  );

  // Vertical Padding
  static const EdgeInsets paddingVerticalTiny = EdgeInsets.symmetric(
    vertical: paddingTiny,
  );
  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(
    vertical: paddingSmall,
  );
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(
    vertical: paddingMedium,
  );
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(
    vertical: paddingLarge,
  );
  static const EdgeInsets paddingVerticalExtraLarge = EdgeInsets.symmetric(
    vertical: paddingExtraLarge,
  );

  //====================== Margin ======================================

  static const double marginTiny = 4.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginExtraLarge = 32.0;

  // EdgeInsets for Margins
  static const EdgeInsets marginAllTiny = EdgeInsets.all(marginTiny);
  static const EdgeInsets marginAllSmall = EdgeInsets.all(marginSmall);
  static const EdgeInsets marginAllMedium = EdgeInsets.all(marginMedium);
  static const EdgeInsets marginAllLarge = EdgeInsets.all(marginLarge);
  static const EdgeInsets marginAllExtraLarge = EdgeInsets.all(
    marginExtraLarge,
  );

  // Horizontal Margin
  static const EdgeInsets marginHorizontalTiny = EdgeInsets.symmetric(
    horizontal: marginTiny,
  );
  static const EdgeInsets marginHorizontalSmall = EdgeInsets.symmetric(
    horizontal: marginSmall,
  );
  static const EdgeInsets marginHorizontalMedium = EdgeInsets.symmetric(
    horizontal: marginMedium,
  );
  static const EdgeInsets marginHorizontalLarge = EdgeInsets.symmetric(
    horizontal: marginLarge,
  );
  static const EdgeInsets marginHorizontalExtraLarge = EdgeInsets.symmetric(
    horizontal: marginExtraLarge,
  );

  // Vertical Margin
  static const EdgeInsets marginVerticalTiny = EdgeInsets.symmetric(
    vertical: marginTiny,
  );
  static const EdgeInsets marginVerticalSmall = EdgeInsets.symmetric(
    vertical: marginSmall,
  );
  static const EdgeInsets marginVerticalMedium = EdgeInsets.symmetric(
    vertical: marginMedium,
  );
  static const EdgeInsets marginVerticalLarge = EdgeInsets.symmetric(
    vertical: marginLarge,
  );
  static const EdgeInsets marginVerticalExtraLarge = EdgeInsets.symmetric(
    vertical: marginExtraLarge,
  );

  // ================== Border Radius Constants =====================

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 16.0;
  static const double radiusFull = 100.0;


  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(radiusSmall),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(radiusMedium),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(radiusLarge),
  );
  static const BorderRadius borderRadiusExtraLarge = BorderRadius.all(
    Radius.circular(radiusExtraLarge),
  );
   static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );
  static const BorderRadius topBorderRadiusSmall = BorderRadius.only(
    topLeft: Radius.circular(4.0),
    topRight: Radius.circular(4.0),
  );

  static const BorderRadius topBorderRadiusMedium = BorderRadius.only(
    topLeft: Radius.circular(8.0),
    topRight: Radius.circular(8.0),
  );

  static const BorderRadius topBorderRadiusLarge = BorderRadius.only(
    topLeft: Radius.circular(12.0),
    topRight: Radius.circular(12.0),
  );
  static const BorderRadius topBorderRadiusExtraLarge = BorderRadius.only(
    topLeft: Radius.circular(16.0),
    topRight: Radius.circular(16.0),
  );
  
}

//============= Sized Box  || gap in figma design ======================

class Space {
  // Vertical Space
  static const Widget verticalTiny = SizedBox(height: 4.0);
  static const Widget verticalSmall = SizedBox(height: 8.0);
  static const Widget verticalMedium = SizedBox(height: 16.0);
  static const Widget verticalLarge = SizedBox(height: 24.0);
  static const Widget verticalExtraLarge = SizedBox(height: 32.0);

  // Horizontal Space
  static const Widget horizontalTiny = SizedBox(width: 4.0);
  static const Widget horizontalSmall = SizedBox(width: 8.0);
  static const Widget horizontalMedium = SizedBox(width: 16.0);
  static const Widget horizontalLarge = SizedBox(width: 24.0);
  static const Widget horizontalExtraLarge = SizedBox(width: 32.0);

  //Custom sized sized boxes
  static SizedBox vertical(double height) => SizedBox(height: height);
  static SizedBox horizontal(double width) => SizedBox(width: width);

  // Custom space between widgets
  static const double largeSpace = 90;
}

// common icon size
class IconSize {
  static const double tiny = 10.0;
  static const double small = 16.0;
  static const double medium = 24.0;
  static const double large = 32.0;
  static const double extraLarge = 40.0;
  static const double huge = 50.0;
}
// common elevation

class Elevation {
  static const double none = 0.0;
  static const double small = 1.0;
  static const double medium = 2.0;
  static const double large = 4.0;
}

class Spacing {
  static const double tiny = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

class ImageSize {
  static const double tiny = 50.0;
  static const double small = 75.0;
  static const double medium = 100.0;
  static const double large = 150.0;
  static const double extraLarge = 200.0;
}
