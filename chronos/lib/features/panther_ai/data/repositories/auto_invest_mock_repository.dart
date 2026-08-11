import 'dart:math';

import '../../domain/entities/auto_invest.dart';
import '../../domain/entities/auto_invest_enums.dart';
import '../../domain/repositories/auto_invest_repository.dart';

/// Local, in-memory stand-in for [AutoInvestRepository] — makes no network
/// calls at all.
///
/// Wired in instead of `AutoInvestRepositoryImpl` via the
/// `kAutoInvestUseMockBackend` flag in `panther_ai_di.dart` while there's no
/// reachable backend for this app to call (AWS Elastic Beanstalk is being
/// retired — see root CLAUDE.md — and nothing has replaced it yet). This
/// lets the whole wizard + dashboard flow be built and tested end to end
/// against believable data with zero backend dependency. Swap the DI flag
/// back to `false` once a real backend is reachable again; nothing else in
/// this feature needs to change, since this implements the exact same
/// [AutoInvestRepository] contract.
///
/// The allocation math mirrors the backend's rule-based algorithm in
/// `Chronos-Backend-/src/modules/investing/auto-invest/auto-invest.service.ts`
/// so preview data looks the same whether it's mocked or real.
class AutoInvestMockRepository implements AutoInvestRepository {
  AutoInvestPlanEntity? _plan;
  int _nextId = 1;

  String _newId(String prefix) => '$prefix-mock-${_nextId++}';

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 450));

  @override
  Future<AutoInvestPreviewEntity> getAllocationPreview({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
  }) async {
    await _simulateLatency();
    final allocations = _generateAllocations(riskProfile, goal, amountUsd);
    double sumPct(AutoInvestAssetClass assetClass) => allocations
        .where((a) => a.assetClass == assetClass)
        .fold(0.0, (sum, a) => sum + a.percentage);
    return AutoInvestPreviewEntity(
      allocations: allocations,
      summary: AutoInvestSummaryEntity(
        cryptoPct: sumPct(AutoInvestAssetClass.crypto),
        stockPct: sumPct(AutoInvestAssetClass.stock),
        etfPct: sumPct(AutoInvestAssetClass.etf),
      ),
    );
  }

  @override
  Future<AutoInvestPlanEntity> createPlan({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
    required AutoInvestCadence cadence,
    required List<AutoInvestAllocationEntity> allocations,
  }) async {
    await _simulateLatency();
    final plan = AutoInvestPlanEntity(
      id: _newId('plan'),
      riskProfile: riskProfile,
      goal: goal,
      amountUsd: amountUsd,
      cadence: cadence,
      status: AutoInvestPlanStatus.pendingConfirmation,
      roundsCompleted: 0,
      allocations: allocations,
      executions: const [],
    );
    _plan = plan;
    return plan;
  }

  @override
  Future<AutoInvestPlanEntity> confirmPlan(String planId) async {
    await _simulateLatency();
    final plan = _requirePlan(planId);
    final isOneTime = plan.cadence == AutoInvestCadence.oneTime;
    _plan = _copyWith(
      plan,
      status: isOneTime ? AutoInvestPlanStatus.completed : AutoInvestPlanStatus.active,
      roundsCompleted: 1,
      nextRoundAt: isOneTime ? null : _nextRoundDate(plan.cadence),
      executions: _executeRound(plan, roundNumber: 1),
    );
    return _plan!;
  }

  @override
  Future<AutoInvestPlanEntity?> getActivePlan() async {
    await _simulateLatency();
    return _plan;
  }

  @override
  Future<AutoInvestPlanEntity> getPlan(String planId) async {
    await _simulateLatency();
    return _requirePlan(planId);
  }

  @override
  Future<AutoInvestPlanEntity> pausePlan(String planId) async {
    await _simulateLatency();
    _plan = _copyWith(_requirePlan(planId), status: AutoInvestPlanStatus.paused);
    return _plan!;
  }

  @override
  Future<AutoInvestPlanEntity> resumePlan(String planId) async {
    await _simulateLatency();
    _plan = _copyWith(_requirePlan(planId), status: AutoInvestPlanStatus.active);
    return _plan!;
  }

  @override
  Future<AutoInvestPlanEntity> cancelPlan(String planId) async {
    await _simulateLatency();
    _plan = _copyWith(_requirePlan(planId), status: AutoInvestPlanStatus.cancelled);
    return _plan!;
  }

  @override
  Future<AutoInvestPlanEntity> triggerNextRound(String planId) async {
    await _simulateLatency();
    final plan = _requirePlan(planId);
    final round = plan.roundsCompleted + 1;
    _plan = _copyWith(
      plan,
      roundsCompleted: round,
      nextRoundAt: _nextRoundDate(plan.cadence),
      executions: [...plan.executions, ..._executeRound(plan, roundNumber: round)],
    );
    return _plan!;
  }

  @override
  Future<List<AutoInvestExecutionEntity>> getExecutions(String planId) async {
    await _simulateLatency();
    return _requirePlan(planId).executions;
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  AutoInvestPlanEntity _requirePlan(String planId) {
    final plan = _plan;
    if (plan == null || plan.id != planId) {
      throw Exception('No mock Auto-Invest plan found — the plan may not have been created yet.');
    }
    return plan;
  }

  AutoInvestPlanEntity _copyWith(
    AutoInvestPlanEntity plan, {
    AutoInvestPlanStatus? status,
    int? roundsCompleted,
    DateTime? nextRoundAt,
    List<AutoInvestExecutionEntity>? executions,
  }) {
    return AutoInvestPlanEntity(
      id: plan.id,
      riskProfile: plan.riskProfile,
      goal: plan.goal,
      amountUsd: plan.amountUsd,
      cadence: plan.cadence,
      status: status ?? plan.status,
      roundsCompleted: roundsCompleted ?? plan.roundsCompleted,
      nextRoundAt: nextRoundAt ?? plan.nextRoundAt,
      allocations: plan.allocations,
      executions: executions ?? plan.executions,
    );
  }

  DateTime? _nextRoundDate(AutoInvestCadence cadence) {
    final days = switch (cadence) {
      AutoInvestCadence.weekly => 7,
      AutoInvestCadence.biweekly => 14,
      AutoInvestCadence.monthly => 30,
      AutoInvestCadence.oneTime => null,
    };
    return days == null ? null : DateTime.now().add(Duration(days: days));
  }

  List<AutoInvestExecutionEntity> _executeRound(AutoInvestPlanEntity plan, {required int roundNumber}) {
    return plan.allocations.map((a) {
      final executesLive = a.assetClass.executesLive;
      return AutoInvestExecutionEntity(
        id: _newId('exec'),
        roundNumber: roundNumber,
        assetClass: a.assetClass,
        symbol: a.symbol,
        amountUsd: a.amountUsd,
        status: executesLive ? AutoInvestExecutionStatus.executed : AutoInvestExecutionStatus.planned,
        tradeId: executesLive ? _newId('trade') : null,
        executedAt: DateTime.now(),
      );
    }).toList();
  }

  // ── deterministic allocation generator (mirrors the backend's rules) ────

  List<AutoInvestAllocationEntity> _generateAllocations(
    AutoInvestRiskProfile risk,
    AutoInvestGoal goal,
    double amountUsd,
  ) {
    var cryptoWeight = switch (risk) {
      AutoInvestRiskProfile.conservative => 0.10,
      AutoInvestRiskProfile.balanced => 0.20,
      AutoInvestRiskProfile.aggressive => 0.35,
    };
    var etfWeight = switch (risk) {
      AutoInvestRiskProfile.conservative => 0.60,
      AutoInvestRiskProfile.balanced => 0.40,
      AutoInvestRiskProfile.aggressive => 0.20,
    };
    final stockWeight = switch (risk) {
      AutoInvestRiskProfile.conservative => 0.30,
      AutoInvestRiskProfile.balanced => 0.40,
      AutoInvestRiskProfile.aggressive => 0.45,
    };

    if (goal == AutoInvestGoal.shortTerm || goal == AutoInvestGoal.retirement) {
      final shift = min(0.10, cryptoWeight - 0.05);
      if (shift > 0) {
        cryptoWeight -= shift;
        etfWeight += shift;
      }
    }

    final allocations = <AutoInvestAllocationEntity>[];

    void addSleeve(
      double sleeveWeight,
      AutoInvestAssetClass assetClass,
      List<(String symbol, String name, double share, String rationale)> basket,
    ) {
      for (final (symbol, name, share, rationale) in basket) {
        final pct = sleeveWeight * share * 100;
        allocations.add(AutoInvestAllocationEntity(
          assetClass: assetClass,
          symbol: symbol,
          name: name,
          percentage: pct,
          amountUsd: amountUsd * (pct / 100),
          rationale: rationale,
        ));
      }
    }

    addSleeve(cryptoWeight, AutoInvestAssetClass.crypto, [
      ('BTC', 'Bitcoin', 0.60, 'Bitcoin for high-growth diversification.'),
      ('ETH', 'Ethereum', 0.40, 'Ethereum for smart-contract ecosystem exposure.'),
    ]);
    addSleeve(stockWeight, AutoInvestAssetClass.stock, [
      ('AAPL', 'Apple Inc.', 0.25, 'Mega-cap consumer tech stability.'),
      ('MSFT', 'Microsoft Corp.', 0.25, 'Cloud and enterprise software growth.'),
      ('AMZN', 'Amazon.com Inc.', 0.25, 'E-commerce and cloud infrastructure exposure.'),
      ('GOOGL', 'Alphabet Inc.', 0.25, 'Search, ads and AI platform exposure.'),
    ]);
    addSleeve(etfWeight, AutoInvestAssetClass.etf, [
      ('VOO', 'Vanguard S&P 500 ETF', 0.50, 'Core U.S. equity exposure for long-term growth.'),
      ('VTI', 'Vanguard Total Stock Market ETF', 0.30, 'Broad U.S. market diversification.'),
      ('QQQ', 'Invesco QQQ Trust', 0.20, 'Large-cap tech and growth tilt.'),
    ]);

    return allocations;
  }
}
