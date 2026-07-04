import '../../../../core/network/api_client.dart';
import '../../../../features/auth/data/services/token_storage_service.dart';
import '../models/panther_ai_models.dart';

const _kPantherBase = String.fromEnvironment(
  'PANTHER_AI_BASE_URL',
  defaultValue: 'http://panther-env.us-east-1.elasticbeanstalk.com',
);

// Chris chat is served by the Vercel serverless function (api/chat.js)
// which holds the Anthropic API key securely server-side.
const _kChrisChatBase = 'https://chronosapp-nahomp.vercel.app';

/// Panther AI FastAPI service  uses user_id in request bodies (no JWT required).
/// Falls back to demo user "user_marcus" if no persisted userId is available.
class PantherAiRemoteDataSource {
  final ApiClient _client;
  final TokenStorageService _tokenStorage;

  PantherAiRemoteDataSource(this._client, this._tokenStorage);

  String get _userId => _tokenStorage.userId ?? 'user_marcus';

  // ── Chat ──────────────────────────────────────────────────────────────────

  Future<ChatResponseModel> sendMessage(
    String message, {
    List<Map<String, String>> history = const [],
  }) async {
    final data = await _client.postWithBase(_kChrisChatBase, '/api/chat', {
      'user_id': _userId,
      'message': message,
      if (history.isNotEmpty) 'history': history,
    });
    return ChatResponseModel.fromJson({
      'reply': data['response'] as String? ?? data['reply'] as String? ?? '',
      'domain': data['domain'] ?? 'GENERAL',
      'userLevel': data['userLevel'] ?? 'BEGINNER',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ── Warnings (mapped from /api/insights/warnings-history) ────────────────

  Future<List<WarningItemModel>> getWarnings({int limit = 10}) async {
    final data = await _client.getWithBase(
      _kPantherBase,
      '/api/insights/warnings-history?user_id=$_userId&limit=$limit',
    );
    final items = data['warnings'] as List<dynamic>? ?? [];
    return items
        .map((e) => WarningItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Spending ──────────────────────────────────────────────────────────────

  Future<SpendingSummaryModel> getSpendingSummary({
    required int month,
    required int year,
  }) async {
    final data = await _client.getWithBase(
      _kPantherBase,
      '/api/insights/spending-summary?user_id=$_userId&month=$month&year=$year',
    );
    return SpendingSummaryModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getTopCategories({int days = 30}) async {
    return _client.getWithBase(
      _kPantherBase,
      '/api/insights/top-categories?user_id=$_userId&days=$days',
    );
  }

  // ── Transactions ──────────────────────────────────────────────────────────

  Future<List<TransactionModel>> getTransactions({int days = 30}) async {
    final data = await _client.getWithBase(
      _kPantherBase,
      '/api/transactions?user_id=$_userId&days=$days',
    );
    final items = data is List ? data : (data['transactions'] as List<dynamic>? ?? []);
    return (items as List<dynamic>)
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Marketplace ───────────────────────────────────────────────────────────

  Future<List<MarketplaceProductModel>> searchProducts(
    String query, {
    double? budget,
    int maxResults = 10,
  }) async {
    final body = <String, dynamic>{
      'user_id': _userId,
      'query': query,
      'max_results': maxResults,
    };
    if (budget != null) body['budget'] = budget;

    final data = await _client.postWithBase(
      _kPantherBase,
      '/api/marketplace/search',
      body,
    );
    final items = data['results'] as List<dynamic>? ?? [];
    return items
        .map((e) =>
            MarketplaceProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Payment Authorization ─────────────────────────────────────────────────

  Future<PaymentAuthorizationModel> authorizePayment({
    required double amount,
    required String merchant,
    String paymentType = 'standard',
    int? numPayments,
  }) async {
    final body = <String, dynamic>{
      'user_id': _userId,
      'amount': amount,
      'merchant': merchant,
      'payment_type': paymentType,
    };
    if (numPayments != null) body['num_payments'] = numPayments;

    final data = await _client.postWithBase(
      _kPantherBase,
      '/api/authorize-payment',
      body,
    );
    return PaymentAuthorizationModel.fromJson(data);
  }

  // ── Affordability (legacy, maps to authorize-payment) ────────────────────

  Future<AffordabilityResultModel> checkAffordability(
      double amount, String merchant) async {
    final auth = await authorizePayment(amount: amount, merchant: merchant);
    final cashFlow = auth.cashFlow;
    return AffordabilityResultModel(
      verdict: (auth.cashFlow == null || !auth.cashFlow!.isRisky)
          ? 'APPROVED'
          : 'DENIED',
      summary: auth.combinedMessage.isNotEmpty
          ? auth.combinedMessage
          : (cashFlow?.warningMessage ?? 'Analysis complete'),
      safeAmount: cashFlow?.projectedBalance,
    );
  }
}
