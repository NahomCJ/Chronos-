import '../entities/affordability_result.dart';
import '../repositories/panther_ai_repository.dart';

class CheckAffordability {
  final PantherAiRepository repository;
  CheckAffordability(this.repository);
  Future<AffordabilityResult> call(double amount, String merchant) =>
      repository.checkAffordability(amount, merchant);
}
