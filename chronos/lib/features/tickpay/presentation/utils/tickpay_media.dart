import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Centralised Pexels CDN URLs for all TickPay media.
/// Photos: https://images.pexels.com/photos/{id}/pexels-photo-{id}.jpeg
/// Videos: https://videos.pexels.com/video-files/{id}/{id}-hd_...mp4
class TickPayMedia {
  TickPayMedia._();

  // ── Product photos ────────────────────────────────────────────────────────

  /// iPhone 15 Pro  photo by Ana Quirosa (Pexels #19060954)
  static const String iphone15Pro =
      'https://images.pexels.com/photos/19060954/pexels-photo-19060954.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Black over-ear headphones  (Pexels #1649771)
  static const String headphonesBlack =
      'https://images.pexels.com/photos/1649771/pexels-photo-1649771.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// White wireless headphones  (Pexels #3394665)
  static const String headphonesWhite =
      'https://images.pexels.com/photos/3394665/pexels-photo-3394665.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Adidas shoe close-up  (Pexels #787593)
  static const String adidasShoes =
      'https://images.pexels.com/photos/787593/pexels-photo-787593.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Nike shoes pair  (Pexels #2529157)
  static const String nikeShoes =
      'https://images.pexels.com/photos/2529157/pexels-photo-2529157.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// White Adidas sneakers  (Pexels #1225136)
  static const String whiteSneakers =
      'https://images.pexels.com/photos/1225136/pexels-photo-1225136.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Silver Apple Watch  (Pexels #437038)
  static const String appleWatch =
      'https://images.pexels.com/photos/437038/pexels-photo-437038.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Black Apple Watch sport band  (Pexels #5054541)
  static const String appleWatchBlack =
      'https://images.pexels.com/photos/5054541/pexels-photo-5054541.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Wireless earbuds with phone  (Pexels #5081398)
  static const String wirelessEarbuds =
      'https://images.pexels.com/photos/5081398/pexels-photo-5081398.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// MacBook on desk  (Pexels #205421)
  static const String macbook =
      'https://images.pexels.com/photos/205421/pexels-photo-205421.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// iPad tablet  (Pexels #1334597)
  static const String ipad =
      'https://images.pexels.com/photos/1334597/pexels-photo-1334597.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Smartwatch fitness  (Pexels #475773)
  static const String smartwatch =
      'https://images.pexels.com/photos/475773/pexels-photo-475773.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// JBL / bluetooth speaker  (Pexels #1706694)
  static const String bluetoothSpeaker =
      'https://images.pexels.com/photos/1706694/pexels-photo-1706694.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Smartphone app screen  (Pexels #5437583)
  static const String smartphone =
      'https://images.pexels.com/photos/5437583/pexels-photo-5437583.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  // ── Background videos ─────────────────────────────────────────────────────

  /// Woman checking shopping bags, portrait  TickPay welcome bg (Pexels #6565434)
  static const String welcomeVideo =
      'https://videos.pexels.com/video-files/6565434/6565434-hd_1080_1920_24fps.mp4';

  /// Woman using smartphone for e-payment (Pexels video #4109600)
  static const String paymentVideo =
      'https://videos.pexels.com/video-files/4109600/4109600-hd_1080_1920_30fps.mp4';

  /// Energetic woman with shopping bags  fallback portrait (Pexels #7680438)
  static const String shoppingVideo =
      'https://videos.pexels.com/video-files/7680438/7680438-hd_1080_1920_25fps.mp4';

  /// Fashion dress  (Pexels #1536619)
  static const String fashionDress =
      'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Handbag  (Pexels #1152077)
  static const String handbag =
      'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Gym bag / sports  (Pexels #1280064)
  static const String gymBag =
      'https://images.pexels.com/photos/1280064/pexels-photo-1280064.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Coffee maker  (Pexels #2080590)
  static const String coffeeMaker =
      'https://images.pexels.com/photos/2080590/pexels-photo-2080590.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Table lamp  (Pexels #1112598)
  static const String tableLamp =
      'https://images.pexels.com/photos/1112598/pexels-photo-1112598.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Perfume bottle  (Pexels #965989)
  static const String perfume =
      'https://images.pexels.com/photos/965989/pexels-photo-965989.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Skincare set  (Pexels #3373736)
  static const String skincare =
      'https://images.pexels.com/photos/3373736/pexels-photo-3373736.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Gaming controller  (Pexels #3945683)
  static const String gameController =
      'https://images.pexels.com/photos/3945683/pexels-photo-3945683.jpeg'
      '?auto=compress&cs=tinysrgb&w=600';

  /// Welcome page static photo fallback  happy woman with colorful bags (Pexels #5632400)
  static const String welcomePhoto =
      'https://images.pexels.com/photos/5632400/pexels-photo-5632400.jpeg'
      '?auto=compress&cs=tinysrgb&w=1080';

  /// Cinematic city bokeh night drive  kept as fallback (Pexels #20407079)
  static const String onboardingVideo =
      'https://videos.pexels.com/video-files/20407079/20407079-hd_1080_1920_50fps.mp4';

  // ── Onboarding per-slide videos ───────────────────────────────────────────

  /// Slide 1  Finance: contactless payment (Pexels #7669659)
  static const String onboardingFinance =
      'https://videos.pexels.com/video-files/7669659/7669659-hd_1080_1920_25fps.mp4';

  /// Slide 2  AI: dynamic purple light waves (Pexels #34576602)
  static const String onboardingAi =
      'https://videos.pexels.com/video-files/34576602/14651995_1080_1920_30fps.mp4';

  /// Slide 3  Shopping/BNPL: woman shopping boutique (Pexels #7680438)
  static const String onboardingShopping =
      'https://videos.pexels.com/video-files/7680438/7680438-hd_1080_1920_25fps.mp4';

  /// Slide 4  Crypto: crypto trading on smartphone (Pexels #34453413)
  static const String onboardingCrypto =
      'https://videos.pexels.com/video-files/34453413/14599279_1080_1920_25fps.mp4';

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
