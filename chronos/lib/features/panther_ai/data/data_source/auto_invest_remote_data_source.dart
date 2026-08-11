import '../../../../core/network/api_client.dart';
import '../../domain/entities/auto_invest_enums.dart';
import '../models/auto_invest_models.dart';

const _kAutoInvestBase = '/api/v1/auto-invest';

/// Talks to the main Express backend's auto-invest endpoints (lives on
/// `API_BASE_URL`, same host as every other `panther_ai` call that goes
/// through [ApiClient] rather than the standalone Panther AI FastAPI
/// service). All routes require the JWT [ApiClient] already attaches.
class AutoInvestRemoteDataSource {
  final ApiClient _client;
  AutoInvestRemoteDataSource(this._client);

  Future<AutoInvestPreviewModel> getAllocationPreview({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
  }) async {
    final data = await _client.post('$_kAutoInvestBase/allocation-preview', {
      'riskProfile': riskProfile.toApiValue(),
      'goal': goal.toApiValue(),
      'amountUsd': amountUsd,
    });
    return AutoInvestPreviewModel.fromJson(data);
  }

  Future<AutoInvestPlanModel> createPlan({
    required AutoInvestRiskProfile riskProfile,
    required AutoInvestGoal goal,
    required double amountUsd,
    required AutoInvestCadence cadence,
    required List<AutoInvestAllocationModel> allocations,
  }) async {
    final data = await _client.post('$_kAutoInvestBase/plans', {
      'riskProfile': riskProfile.toApiValue(),
      'goal': goal.toApiValue(),
      'amountUsd': amountUsd,
      'cadence': cadence.toApiValue(),
      'allocations': allocations.map((a) => a.toJson()).toList(),
    });
    return AutoInvestPlanModel.fromJson(data);
  }

  Future<AutoInvestPlanModel> confirmPlan(String planId) async {
    final data = await _client.post('$_kAutoInvestBase/plans/$planId/confirm', const {});
    return AutoInvestPlanModel.fromJson(data);
  }

  Future<AutoInvestPlanModel?> getActivePlan() async {
    try {
      final data = await _client.get('$_kAutoInvestBase/plans/active');
      if (data.isEmpty || data['id'] == null) return null;
      return AutoInvestPlanModel.fromJson(data);
    } catch (e) {
      if (_isNotFound(e)) return null;
      rethrow;
    }
  }

  Future<AutoInvestPlanModel> getPlan(String planId) async {
    final data = await _client.get('$_kAutoInvestBase/plans/$planId');
    return AutoInvestPlanModel.fromJson(data);
  }

  Future<AutoInvestPlanModel> pausePlan(String planId) async {
    final data = await _client.patch('$_kAutoInvestBase/plans/$planId/pause', const {});
    return AutoInvestPlanModel.fromJson(data);
  }

  Future<AutoInvestPlanModel> resumePlan(String planId) async {
    final data = await _client.patch('$_kAutoInvestBase/plans/$planId/resume', const {});
    return AutoInvestPlanModel.fromJson(data);
  }

  Future<AutoInvestPlanModel> cancelPlan(String planId) async {
    final data = await _client.delete('$_kAutoInvestBase/plans/$planId');
    return AutoInvestPlanModel.fromJson(data);
  }

  Future<AutoInvestPlanModel> triggerNextRound(String planId) async {
    final data = await _client.post('$_kAutoInvestBase/plans/$planId/rounds', const {});
    return AutoInvestPlanModel.fromJson(data);
  }

  Future<List<AutoInvestExecutionModel>> getExecutions(String planId) async {
    // ApiClient wraps a bare JSON array response as {'data': [...]} (see
    // ApiClient._handleMapResponse), so accept that shape as well as a
    // {'executions': [...]} wrapper in case the backend nests it.
    final data = await _client.get('$_kAutoInvestBase/plans/$planId/executions');
    final raw = data['executions'] ?? data['data'] ?? const [];
    final items = raw is List ? raw : const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(AutoInvestExecutionModel.fromJson)
        .toList();
  }

  bool _isNotFound(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('404') || msg.contains('not found');
  }
}
