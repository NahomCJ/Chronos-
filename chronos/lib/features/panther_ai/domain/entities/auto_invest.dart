import 'auto_invest_enums.dart';

/// One leg of an Auto-Invest allocation — a single symbol with its target
/// slice of the total dollar amount. Returned by both the allocation-preview
/// endpoint (no persistence) and as part of a saved plan.
class AutoInvestAllocationEntity {
  final AutoInvestAssetClass assetClass;
  final String symbol;
  final String name;
  final double percentage;
  final double amountUsd;
  final String rationale;

  const AutoInvestAllocationEntity({
    required this.assetClass,
    required this.symbol,
    required this.name,
    required this.percentage,
    required this.amountUsd,
    required this.rationale,
  });
}

/// The outcome of one leg of one round — crypto legs land as `executed`
/// (or `failed`) immediately; stock/etf legs land as `planned` since there
/// is no brokerage integration to actually place those orders yet.
class AutoInvestExecutionEntity {
  final String id;
  final int roundNumber;
  final AutoInvestAssetClass assetClass;
  final String symbol;
  final double amountUsd;
  final AutoInvestExecutionStatus status;
  final String? tradeId;
  final String? failureReason;
  final DateTime? executedAt;

  const AutoInvestExecutionEntity({
    required this.id,
    required this.roundNumber,
    required this.assetClass,
    required this.symbol,
    required this.amountUsd,
    required this.status,
    this.tradeId,
    this.failureReason,
    this.executedAt,
  });
}

class AutoInvestPlanEntity {
  final String id;
  final AutoInvestRiskProfile riskProfile;
  final AutoInvestGoal goal;
  final double amountUsd;
  final AutoInvestCadence cadence;
  final AutoInvestPlanStatus status;
  final int roundsCompleted;
  final DateTime? nextRoundAt;
  final List<AutoInvestAllocationEntity> allocations;
  final List<AutoInvestExecutionEntity> executions;

  const AutoInvestPlanEntity({
    required this.id,
    required this.riskProfile,
    required this.goal,
    required this.amountUsd,
    required this.cadence,
    required this.status,
    required this.roundsCompleted,
    this.nextRoundAt,
    required this.allocations,
    required this.executions,
  });

  /// Executions belonging to the most recent round only — used by the
  /// success page to show "what just happened" instead of full history.
  List<AutoInvestExecutionEntity> get latestRoundExecutions {
    if (executions.isEmpty) return const [];
    final latest = executions.map((e) => e.roundNumber).reduce((a, b) => a > b ? a : b);
    return executions.where((e) => e.roundNumber == latest).toList();
  }
}

class AutoInvestSummaryEntity {
  final double cryptoPct;
  final double stockPct;
  final double etfPct;

  const AutoInvestSummaryEntity({
    required this.cryptoPct,
    required this.stockPct,
    required this.etfPct,
  });
}

/// Response of `POST /allocation-preview` — a proposed mix that has not
/// been saved anywhere yet.
class AutoInvestPreviewEntity {
  final List<AutoInvestAllocationEntity> allocations;
  final AutoInvestSummaryEntity summary;

  const AutoInvestPreviewEntity({
    required this.allocations,
    required this.summary,
  });
}
