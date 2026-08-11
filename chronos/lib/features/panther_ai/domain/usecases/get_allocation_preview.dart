import '../entities/auto_invest.dart';
import '../entities/auto_invest_enums.dart';
import '../repositories/auto_invest_repository.dart';

class GetAllocationPreview {
  final AutoInvestRepository repository;
  GetAllocationPreview(this.repository);

  Future<AutoInvestPreviewEntity> call({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
  }) =>
      repository.getAllocationPreview(
        riskProfile: riskProfile,
        goal: goal,
        amountUsd: amountUsd,
      );
}
