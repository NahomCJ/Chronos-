import '../entities/payment_authorization.dart';
import '../repositories/panther_ai_repository.dart';

class AuthorizePayment {
  final PantherAiRepository repository;
  AuthorizePayment(this.repository);

  Future<PaymentAuthorization> call({
    required double amount,
    required String merchant,
    String paymentType = 'standard',
    int? numPayments,
  }) =>
      repository.authorizePayment(
        amount: amount,
        merchant: merchant,
        paymentType: paymentType,
        numPayments: numPayments,
      );
}
