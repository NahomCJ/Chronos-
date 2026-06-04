import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Centralised Pexels CDN URLs for all TickPay media.
/// Photos: https://images.pexels.com/photos/{id}/pexels-photo-{id}.jpeg
/// Videos: https://videos.pexels.com/video-files/{id}/{id}-hd_...mp4
class TickPayMedia {
  TickPayMedia._();

  // ── Product photos ────────────────────────────────────────────────────────

  /// iPhone 15 Pro — photo by Ana Quirosa (Pexels #19060954)
  static const String iphone15Pro =
      'https://images.pexels.com/photos/19060954/pexels-photo-19060954.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Black over-ear headphones — (Pexels #1649771)
  static const String headphonesBlack =
      'https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// White wireless headphones — (Pexels #3394665)
  static const String headphonesWhite =
      'https://images.pexels.com/photos/3394665/pexels-photo-3394665.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Adidas shoe close-up — (Pexels #787593)
  static const String adidasShoes =
      'https://images.pexels.com/photos/787593/pexels-photo-787593.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Nike shoes pair — (Pexels #2529157)
  static const String nikeShoes =
      'https://images.pexels.com/photos/2529157/pexels-photo-2529157.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// White Adidas sneakers — (Pexels #1225136)
  static const String whiteSneakers =
      'https://images.pexels.com/photos/1225136/pexels-photo-1225136.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Silver Apple Watch — (Pexels #437038)
  static const String appleWatch =
      'https://images.pexels.com/photos/437038/pexels-photo-437038.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Black Apple Watch sport band — (Pexels #5054541)
  static const String appleWatchBlack =
      'https://images.pexels.com/photos/5054541/pexels-photo-5054541.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Wireless earbuds with phone — (Pexels #5081398)
  static const String wirelessEarbuds =
      'https://images.pexels.com/photos/5081398/pexels-photo-5081398.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// MacBook on desk — (Pexels #205421)
  static const String macbook =
      'https://images.pexels.com/photos/205421/pexels-photo-205421.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// iPad tablet — (Pexels #1334597)
  static const String ipad =
      'https://images.pexels.com/photos/1334597/pexels-photo-1334597.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Smartwatch fitness — (Pexels #475773)
  static const String smartwatch =
      'https://images.pexels.com/photos/475773/pexels-photo-475773.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// JBL / bluetooth speaker — (Pexels #1706694)
  static const String bluetoothSpeaker =
      'https://images.pexels.com/photos/1706694/pexels-photo-1706694.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Smartphone app screen — (Pexels #5437583)
  static const String smartphone =
      'https://images.pexels.com/photos/5437583/pexels-photo-5437583.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  // ── Background videos ─────────────────────────────────────────────────────

  /// Woman shopping in boutique — TickPay welcome bg (Pexels #7680438)
  static const String welcomeVideo =
      'https://videos.pexels.com/video-files/7680438/7680438-hd_1080_1920_25fps.mp4';

  /// Woman using smartphone for e-payment (Pexels video #4109600)
  static const String paymentVideo =
      'https://videos.pexels.com/video-files/4109600/4109600-hd_1080_1920_30fps.mp4';

  /// Woman shopping for clothes in boutique — TickPay welcome bg (Pexels #7680438)
  static const String shoppingVideo =
      'https://videos.pexels.com/video-files/7680438/7680438-hd_1080_1920_25fps.mp4';

  /// Cinematic city bokeh night drive — onboarding bg (Pexels #20407079)
  static const String onboardingVideo =
      'https://videos.pexels.com/video-files/20407079/20407079-hd_1080_1920_50fps.mp4';

  /// Purple abstract background (Pexels #7101912)
  static const String purpleAbstractVideo =
      'https://videos.pexels.com/video-files/7101912/7101912-hd_1080_1920_30fps.mp4';
}

// ── Shared helper widget ──────────────────────────────────────────────────────

/// Drop-in replacement for Image.asset that loads from Pexels CDN with
/// shimmer placeholder and graceful error fallback.
class TickPayImage extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const TickPayImage(
    this.url, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width ?? double.infinity,
      fit: fit,
      placeholder: (_, __) => Container(
        height: height,
        width: width ?? double.infinity,
        color: Colors.white.withValues(alpha: 0.06),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Colors.white24,
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        height: height,
        width: width ?? double.infinity,
        color: Colors.white.withValues(alpha: 0.05),
        child: const Icon(Icons.image_outlined, color: Colors.white24),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
