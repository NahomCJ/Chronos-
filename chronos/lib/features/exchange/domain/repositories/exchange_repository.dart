import '../entities/exchange_entity.dart';

abstract class ExchangeRepository {
  Future<ExchangeRate> getRate(String from, String to);
  Future<FxQuote> getQuote({
    required String sourceWalletId,
    required String destCurrency,
    required double amount,
  });
  Future<FxExecution> executeQuote(String quoteId);
}
