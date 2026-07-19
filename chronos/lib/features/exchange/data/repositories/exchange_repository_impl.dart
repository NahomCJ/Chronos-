import '../../domain/entities/exchange_entity.dart';
import '../../domain/repositories/exchange_repository.dart';
import '../data_source/exchange_remote_data_source.dart';

class ExchangeRepositoryImpl implements ExchangeRepository {
  final ExchangeRemoteDataSource dataSource;
  ExchangeRepositoryImpl(this.dataSource);

  @override
  Future<ExchangeRate> getRate(String from, String to) async {
    final model = await dataSource.getRate(from, to);
    return model.toEntity();
  }

  @override
  Future<FxQuote> getQuote({
    required String sourceWalletId,
    required String destCurrency,
    required double amount,
  }) async {
    final model = await dataSource.getQuote(
      sourceWalletId: sourceWalletId,
      destCurrency: destCurrency,
      amount: amount,
    );
    return model.toEntity();
  }

  @override
  Future<FxExecution> executeQuote(String quoteId) async {
    final model = await dataSource.executeQuote(quoteId);
    return model.toEntity();
  }
}
