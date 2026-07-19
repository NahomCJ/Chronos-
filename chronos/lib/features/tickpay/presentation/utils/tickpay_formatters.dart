import 'package:intl/intl.dart';

/// Lightweight, locale-aware formatting helpers for TickPay UI values.
class TickpayFormatters {
  const TickpayFormatters._();

  static final NumberFormat _wholeMoney = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  static final NumberFormat _preciseMoney = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _points = NumberFormat.decimalPattern();

  /// Formats currency, dropping the cents when the value is a whole number
  /// (e.g. `$3,150`) and keeping them otherwise (e.g. `$149.75`).
  static String money(double value) {
    final bool isWhole = value == value.roundToDouble();
    return (isWhole ? _wholeMoney : _preciseMoney).format(value);
  }

  /// Always renders two decimal places (e.g. `$1,629.25`).
  static String moneyPrecise(double value) => _preciseMoney.format(value);

  /// Thousands-separated integer (e.g. `2,450`).
  static String points(int value) => _points.format(value);
}
