
abstract class OnboardingRepository {
  Future<bool> getOnboardingStatus();
  Future<void> completeOnboarding();
}

