
import '../repositories/onboarding_repository.dart';

class CompleteOnboarding {
  final OnboardingRepository repository;

  CompleteOnboarding({required this.repository});

  Future<void> call() {
    return repository.completeOnboarding();
  }
}

