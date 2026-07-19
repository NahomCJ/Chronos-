/// Single source of truth for every TickPay asset path.
///
/// All TickPay design materials live under `assets/tickpay/`. Referencing them
/// through these constants avoids brittle string literals scattered across the
/// UI and makes typos a compile-time concern.
class TickpayAssets {
  const TickpayAssets._();

  static const String _base = 'assets/tickpay';

  // Shared background used on the onboarding flow.
  static const String background = '$_base/background.png';

  // Quick-action / shortcut glyphs (black artwork on transparent canvas).
  static const String shopIcon = '$_base/shop_icon.png';
  static const String payBillsIcon = '$_base/pay_bills_icon.png';
  static const String transferIcon = '$_base/transfer_icon.png';
  static const String scanQrIcon = '$_base/scan_qr_icon.png';
  static const String rewardsIcon = '$_base/rewards_icon.png';
  static const String alertsIcon = '$_base/alerts_icon.png';
  static const String creditIcon = '$_base/creadit_icon.png';
  static const String plansIcon = '$_base/plans_icon.png';
  static const String settingIcon = '$_base/setting_icon.png';
  static const String notificationIcon = '$_base/notification_icon.png';
  static const String chatAiIcon = '$_base/chat_ai_icon.png';
  static const String dollarIcon = '$_base/dollar_icon.png';

  // Merchant logos.
  static const String amazon = '$_base/amazon.png';
  static const String nike = '$_base/nike.png';

  // Product imagery (AI picks).
  static const String airpods = '$_base/airpods.png';
  static const String nikeAirMax = '$_base/nike_airmax.png';
}
