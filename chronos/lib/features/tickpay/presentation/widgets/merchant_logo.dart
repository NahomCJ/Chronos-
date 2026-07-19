import 'package:flutter/material.dart';

import '../constants/tickpay_colors.dart';

/// Rounded merchant/product thumbnail. Renders the supplied [asset] in full
/// color (merchant logos, product photos) with a graceful fallback.
class MerchantLogo extends StatelessWidget {
  final String asset;
  final double size;
  final double radius;

  const MerchantLogo({
    super.key,
    required this.asset,
    this.size = 48,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: TickpayColors.neutralSurface,
          alignment: Alignment.center,
          child: Icon(
            Icons.storefront_outlined,
            color: Colors.grey.shade500,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
