import 'package:country_picker/country_picker.dart';

class PhoneFormatter {
  /// Convert to E.164 format required by Firebase
  static String toE164(String input, Country country) {
    final digits = input.replaceAll(RegExp(r'\D'), '');

    final phone = digits.startsWith('0')
        ? digits.substring(1)
        : digits;

    return '+${country.phoneCode}$phone';
  }

  /// Very basic validation (enough for Firebase)
  static bool isValid(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15;
  }
}
