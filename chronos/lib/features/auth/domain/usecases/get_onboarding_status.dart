
import '../repositories/onboarding_repository.dart';

class GetOnboardingStatus {
  final OnboardingRepository repository;

  GetOnboardingStatus({required this.repository});

  Future<bool> call() {
    return repository.getOnboardingStatus();
  }
}

