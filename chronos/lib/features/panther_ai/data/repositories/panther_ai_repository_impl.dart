import '../../domain/entities/ai_alert.dart';
import '../../domain/entities/chat_response.dart';
import '../../domain/entities/affordability_result.dart';
import '../../domain/entities/spending_summary.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/marketplace_product.dart';
import '../../domain/entities/payment_authorization.dart';
import '../../domain/repositories/panther_ai_repository.dart';
import '../data_source/panther_ai_remote_data_source.dart';

class PantherAiRepositoryImpl implements PantherAiRepository {
  final PantherAiRemoteDataSource dataSource;
  PantherAiRepositoryImpl(this.dataSource);

  @override
  Future<ChatResponse> sendMessage(
    String message, {
    List<Map<String, String>> history = const [],
  }) async {
    final model = await dataSource.sendMessage(message, history: history);
    return model.toEntity();
  }

  @override
  Future<List<AiAlert>> getAlerts() async {
    final models = await dataSource.getWarnings();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> generateAlerts() async {}

  @override
  Future<void> dismissAlert(String alertId) async {}

  @override
  Future<AffordabilityResult> checkAffordability(
      double amount, String merchant) async {
    final model = await dataSource.checkAffordability(amount, merchant);
    return model.toEntity();
  }

  @override
  Future<SpendingSummary> getSpendingSummary(
      {required int month, required int year}) async {
    final model =
        await dataSource.getSpendingSummary(month: month, year: year);
    return model.toEntity();
  }

  @override
  Future<List<PantherTransaction>> getTransactions({int days = 30}) async {
    final models = await dataSource.getTransactions(days: days);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MarketplaceProduct>> searchProducts(String query,
      {double? budget}) async {
    final models = await dataSource.searchProducts(query, budget: budget);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PaymentAuthorization> authorizePayment({
    required double amount,
    required String merchant,
    String paymentType = 'standard',
    int? numPayments,
  }) async {
    final model = await dataSource.authorizePayment(
      amount: amount,
      merchant: merchant,
      paymentType: paymentType,
      numPayments: numPayments,
    );
    return model.toEntity();
  }
}
