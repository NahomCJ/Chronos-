import '../entities/ai_alert.dart';
import '../entities/chat_response.dart';
import '../entities/affordability_result.dart';
import '../entities/spending_summary.dart';
import '../entities/transaction.dart';
import '../entities/marketplace_product.dart';
import '../entities/payment_authorization.dart';

abstract class PantherAiRepository {
  Future<ChatResponse> sendMessage(
    String message, {
    List<Map<String, String>> history = const [],
  });
  Future<List<AiAlert>> getAlerts();
  Future<void> generateAlerts();
  Future<void> dismissAlert(String alertId);
  Future<AffordabilityResult> checkAffordability(double amount, String merchant);

  Future<SpendingSummary> getSpendingSummary({required int month, required int year});
  Future<List<PantherTransaction>> getTransactions({int days = 30});
  Future<List<MarketplaceProduct>> searchProducts(String query, {double? budget});
  Future<PaymentAuthorization> authorizePayment({
    required double amount,
    required String merchant,
    String paymentType,
    int? numPayments,
  });
}
