import '../entities/auto_invest.dart';
import '../entities/auto_invest_enums.dart';

abstract class AutoInvestRepository {
  Future<AutoInvestPreviewEntity> getAllocationPreview({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
  });

  Future<AutoInvestPlanEntity> createPlan({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
    required AutoInvestCadence cadence,
    required List<AutoInvestAllocationEntity> allocations,
  });

  /// Executes round 1: crypto legs execute for real, stock/etf legs land as
  /// `PLANNED`. Individual legs can come back `FAILED` even on success.
  Future<AutoInvestPlanEntity> confirmPlan(String planId);

  /// The current user's active/pending plan, or `null` if none exists.
  Future<AutoInvestPlanEntity?> getActivePlan();

  Future<AutoInvestPlanEntity> getPlan(String planId);
  Future<AutoInvestPlanEntity> pausePlan(String planId);
  Future<AutoInvestPlanEntity> resumePlan(String planId);
  Future<AutoInvestPlanEntity> cancelPlan(String planId);

  /// Manually triggers the next round ("Invest Next Round Now").
  Future<AutoInvestPlanEntity> triggerNextRound(String planId);

  Future<List<AutoInvestExecutionEntity>> getExecutions(String planId);
}
