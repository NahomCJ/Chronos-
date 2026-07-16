
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingLocalDataSourceImpl {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  Future<bool> getOnboardingStatus() async {
    return sharedPreferences.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    await sharedPreferences.setBool(_onboardingCompletedKey, true);
  }
}
