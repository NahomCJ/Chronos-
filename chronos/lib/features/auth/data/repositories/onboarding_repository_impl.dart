
import '../../domain/repositories/onboarding_repository.dart';
import '../data_source/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSourceImpl localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> getOnboardingStatus() {
    return localDataSource.getOnboardingStatus();
  }

  @override
  Future<void> completeOnboarding() {
    return localDataSource.completeOnboarding();
  }
}

