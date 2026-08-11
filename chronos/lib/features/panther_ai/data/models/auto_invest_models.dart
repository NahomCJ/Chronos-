import '../../domain/entities/auto_invest.dart';
import '../../domain/entities/auto_invest_enums.dart';

// The backend for this feature (`/api/v1/auto-invest/*`) is being built in
// a parallel branch against the same API contract this file implements —
// field names could drift slightly once both branches merge. Every model
// below parses defensively (null-safe, tolerant of missing optional
// fields) and keeps its mapping in one place (`fromJson`) so a mismatch is
// a one-file fix.

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class AutoInvestAllocationModel {
  final AutoInvestAssetClass assetClass;
  final String symbol;
  final String name;
  final double percentage;
  final double amountUsd;
  final String rationale;

  const AutoInvestAllocationModel({
    required this.assetClass,
    required this.symbol,
    required this.name,
    required this.percentage,
    required this.amountUsd,
    required this.rationale,
  });

  factory AutoInvestAllocationModel.fromJson(Map<String, dynamic> json) {
    return AutoInvestAllocationModel(
      assetClass: AutoInvestAssetClassX.fromApiValue(json['assetClass'] as String?),
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? (json['symbol'] as String? ?? ''),
      percentage: _toDouble(json['percentage']),
      amountUsd: _toDouble(json['amountUsd']),
      rationale: json['rationale'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'assetClass': assetClass.toApiValue(),
        'symbol': symbol,
        'name': name,
        'percentage': percentage,
        'amountUsd': amountUsd,
        'rationale': rationale,
      };

  AutoInvestAllocationEntity toEntity() => AutoInvestAllocationEntity(
        assetClass: assetClass,
        symbol: symbol,
        name: name,
        percentage: percentage,
        amountUsd: amountUsd,
        rationale: rationale,
      );

  factory AutoInvestAllocationModel.fromEntity(AutoInvestAllocationEntity e) =>
      AutoInvestAllocationModel(
        assetClass: e.assetClass,
        symbol: e.symbol,
        name: e.name,
        percentage: e.percentage,
        amountUsd: e.amountUsd,
        rationale: e.rationale,
      );
}

class AutoInvestSummaryModel {
  final double cryptoPct;
  final double stockPct;
  final double etfPct;

  const AutoInvestSummaryModel({
    required this.cryptoPct,
    required this.stockPct,
    required this.etfPct,
  });

  factory AutoInvestSummaryModel.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const {};
    return AutoInvestSummaryModel(
      cryptoPct: _toDouble(j['cryptoPct']),
      stockPct: _toDouble(j['stockPct']),
      etfPct: _toDouble(j['etfPct']),
    );
  }

  AutoInvestSummaryEntity toEntity() => AutoInvestSummaryEntity(
        cryptoPct: cryptoPct,
        stockPct: stockPct,
        etfPct: etfPct,
      );
}

class AutoInvestPreviewModel {
  final List<AutoInvestAllocationModel> allocations;
  final AutoInvestSummaryModel summary;

  const AutoInvestPreviewModel({required this.allocations, required this.summary});

  factory AutoInvestPreviewModel.fromJson(Map<String, dynamic> json) {
    final allocationsJson = json['allocations'] as List<dynamic>? ?? [];
    return AutoInvestPreviewModel(
      allocations: allocationsJson
          .whereType<Map<String, dynamic>>()
          .map(AutoInvestAllocationModel.fromJson)
          .toList(),
      summary: AutoInvestSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>?,
      ),
    );
  }

  AutoInvestPreviewEntity toEntity() => AutoInvestPreviewEntity(
        allocations: allocations.map((a) => a.toEntity()).toList(),
        summary: summary.toEntity(),
      );
}

class AutoInvestExecutionModel {
  final String id;
  final int roundNumber;
  final AutoInvestAssetClass assetClass;
  final String symbol;
  final double amountUsd;
  final AutoInvestExecutionStatus status;
  final String? tradeId;
  final String? failureReason;
  final DateTime? executedAt;

  const AutoInvestExecutionModel({
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

  factory AutoInvestExecutionModel.fromJson(Map<String, dynamic> json) {
    return AutoInvestExecutionModel(
      id: json['id']?.toString() ?? '',
      roundNumber: _toInt(json['roundNumber']),
      assetClass: AutoInvestAssetClassX.fromApiValue(json['assetClass'] as String?),
      symbol: json['symbol'] as String? ?? '',
      amountUsd: _toDouble(json['amountUsd']),
      status: AutoInvestExecutionStatusX.fromApiValue(json['status'] as String?),
      tradeId: json['tradeId'] as String?,
      failureReason: json['failureReason'] as String?,
      executedAt: json['executedAt'] != null
          ? DateTime.tryParse(json['executedAt'].toString())
          : null,
    );
  }

  AutoInvestExecutionEntity toEntity() => AutoInvestExecutionEntity(
        id: id,
        roundNumber: roundNumber,
        assetClass: assetClass,
        symbol: symbol,
        amountUsd: amountUsd,
        status: status,
        tradeId: tradeId,
        failureReason: failureReason,
        executedAt: executedAt,
      );
}

class AutoInvestPlanModel {
  final String id;
  final AutoInvestRiskProfile riskProfile;
  final AutoInvestGoal goal;
  final double amountUsd;
  final AutoInvestCadence cadence;
  final AutoInvestPlanStatus status;
  final int roundsCompleted;
  final DateTime? nextRoundAt;
  final List<AutoInvestAllocationModel> allocations;
  final List<AutoInvestExecutionModel> executions;

  const AutoInvestPlanModel({
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

  factory AutoInvestPlanModel.fromJson(Map<String, dynamic> json) {
    final allocationsJson = json['allocations'] as List<dynamic>? ?? [];
    final executionsJson = json['executions'] as List<dynamic>? ?? [];
    return AutoInvestPlanModel(
      id: json['id']?.toString() ?? '',
      riskProfile: AutoInvestRiskProfileX.fromApiValue(json['riskProfile'] as String?),
      goal: AutoInvestGoalX.fromApiValue(json['goal'] as String?),
      amountUsd: _toDouble(json['amountUsd']),
      cadence: AutoInvestCadenceX.fromApiValue(json['cadence'] as String?),
      status: AutoInvestPlanStatusX.fromApiValue(json['status'] as String?),
      roundsCompleted: _toInt(json['roundsCompleted']),
      nextRoundAt: json['nextRoundAt'] != null
          ? DateTime.tryParse(json['nextRoundAt'].toString())
          : null,
      allocations: allocationsJson
          .whereType<Map<String, dynamic>>()
          .map(AutoInvestAllocationModel.fromJson)
          .toList(),
      executions: executionsJson
          .whereType<Map<String, dynamic>>()
          .map(AutoInvestExecutionModel.fromJson)
          .toList(),
    );
  }

  AutoInvestPlanEntity toEntity() => AutoInvestPlanEntity(
        id: id,
        riskProfile: riskProfile,
        goal: goal,
        amountUsd: amountUsd,
        cadence: cadence,
        status: status,
        roundsCompleted: roundsCompleted,
        nextRoundAt: nextRoundAt,
        allocations: allocations.map((a) => a.toEntity()).toList(),
        executions: executions.map((e) => e.toEntity()).toList(),
      );
}
