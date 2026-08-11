import '../../domain/entities/auto_invest.dart';
import '../../domain/entities/auto_invest_enums.dart';
import '../../domain/repositories/auto_invest_repository.dart';
import '../data_source/auto_invest_remote_data_source.dart';
import '../models/auto_invest_models.dart';

class AutoInvestRepositoryImpl implements AutoInvestRepository {
  final AutoInvestRemoteDataSource dataSource;
  AutoInvestRepositoryImpl(this.dataSource);

  @override
  Future<AutoInvestPreviewEntity> getAllocationPreview({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
  }) async {
    final model = await dataSource.getAllocationPreview(
      riskProfile: riskProfile,
      goal: goal,
      amountUsd: amountUsd,
    );
    return model.toEntity();
  }

  @override
  Future<AutoInvestPlanEntity> createPlan({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
    required AutoInvestCadence cadence,
    required List<AutoInvestAllocationEntity> allocations,
  }) async {
    final model = await dataSource.createPlan(
      riskProfile: riskProfile,
      goal: goal,
      amountUsd: amountUsd,
      cadence: cadence,
      allocations: allocations.map(AutoInvestAllocationModel.fromEntity).toList(),
    );
    return model.toEntity();
  }

  @override
  Future<AutoInvestPlanEntity> confirmPlan(String planId) async {
    final model = await dataSource.confirmPlan(planId);
    return model.toEntity();
  }

  @override
  Future<AutoInvestPlanEntity?> getActivePlan() async {
    final model = await dataSource.getActivePlan();
    return model?.toEntity();
  }

  @override
  Future<AutoInvestPlanEntity> getPlan(String planId) async {
    final model = await dataSource.getPlan(planId);
    return model.toEntity();
  }

  @override
  Future<AutoInvestPlanEntity> pausePlan(String planId) async {
    final model = await dataSource.pausePlan(planId);
    return model.toEntity();
  }

  @override
  Future<AutoInvestPlanEntity> resumePlan(String planId) async {
    final model = await dataSource.resumePlan(planId);
    return model.toEntity();
  }

  @override
  Future<AutoInvestPlanEntity> cancelPlan(String planId) async {
    final model = await dataSource.cancelPlan(planId);
    return model.toEntity();
  }

  @override
  Future<AutoInvestPlanEntity> triggerNextRound(String planId) async {
    final model = await dataSource.triggerNextRound(planId);
    return model.toEntity();
  }

  @override
  Future<List<AutoInvestExecutionEntity>> getExecutions(String planId) async {
    final models = await dataSource.getExecutions(planId);
    return models.map((m) => m.toEntity()).toList();
  }
}
