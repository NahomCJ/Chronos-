import '../entities/exchange_entity.dart';
import '../repositories/exchange_repository.dart';

class GetFxQuote {
  final ExchangeRepository repository;
  GetFxQuote(this.repository);

  Future<FxQuote> call({
    required String sourceWalletId,
    required String destCurrency,
    required double amount,
  }) =>
      repository.getQuote(
        sourceWalletId: sourceWalletId,
        destCurrency: destCurrency,
        amount: amount,
      );
}

class ExecuteFx {
  final ExchangeRepository repository;
  ExecuteFx(this.repository);

  Future<FxExecution> call(String quoteId) => repository.executeQuote(quoteId);
}

class GetExchangeRate {
  final ExchangeRepository repository;
  GetExchangeRate(this.repository);

  Future<ExchangeRate> call(String from, String to) =>
      repository.getRate(from, to);
}
