import '../entities/auto_invest.dart';
import '../entities/auto_invest_enums.dart';
import '../repositories/auto_invest_repository.dart';

class CreateAutoInvestPlan {
  final AutoInvestRepository repository;
  CreateAutoInvestPlan(this.repository);

  Future<AutoInvestPlanEntity> call({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
    required AutoInvestCadence cadence,
    required List<AutoInvestAllocationEntity> allocations,
  }) =>
      repository.createPlan(
        riskProfile: riskProfile,
        goal: goal,
        amountUsd: amountUsd,
        cadence: cadence,
        allocations: allocations,
      );
}

class ConfirmAutoInvestPlan {
  final AutoInvestRepository repository;
  ConfirmAutoInvestPlan(this.repository);
  Future<AutoInvestPlanEntity> call(String planId) => repository.confirmPlan(planId);
}

class GetActiveAutoInvestPlan {
  final AutoInvestRepository repository;
  GetActiveAutoInvestPlan(this.repository);
  Future<AutoInvestPlanEntity?> call() => repository.getActivePlan();
}

class GetAutoInvestPlan {
  final AutoInvestRepository repository;
  GetAutoInvestPlan(this.repository);
  Future<AutoInvestPlanEntity> call(String planId) => repository.getPlan(planId);
}

class PauseAutoInvestPlan {
  final AutoInvestRepository repository;
  PauseAutoInvestPlan(this.repository);
  Future<AutoInvestPlanEntity> call(String planId) => repository.pausePlan(planId);
}

class ResumeAutoInvestPlan {
  final AutoInvestRepository repository;
  ResumeAutoInvestPlan(this.repository);
  Future<AutoInvestPlanEntity> call(String planId) => repository.resumePlan(planId);
}

class CancelAutoInvestPlan {
  final AutoInvestRepository repository;
  CancelAutoInvestPlan(this.repository);
  Future<AutoInvestPlanEntity> call(String planId) => repository.cancelPlan(planId);
}

class TriggerNextInvestRound {
  final AutoInvestRepository repository;
  TriggerNextInvestRound(this.repository);
  Future<AutoInvestPlanEntity> call(String planId) => repository.triggerNextRound(planId);
}

class GetAutoInvestExecutions {
  final AutoInvestRepository repository;
  GetAutoInvestExecutions(this.repository);
  Future<List<AutoInvestExecutionEntity>> call(String planId) => repository.getExecutions(planId);
}
