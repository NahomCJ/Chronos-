import '../../../../core/network/api_client.dart';
import '../models/exchange_model.dart';

class ExchangeRemoteDataSource {
  final ApiClient _api;
  ExchangeRemoteDataSource(this._api);

  Future<ExchangeRateModel> getRate(String from, String to) async {
    final json = await _api.get('/api/currency/latest?from=$from&to=$to');
    return ExchangeRateModel.fromJson(json);
  }

  Future<FxQuoteModel> getQuote({
    required String sourceWalletId,
    required String destCurrency,
    required double amount,
  }) async {
    final json = await _api.post('/api/fx/quote', {
      'sourceWalletId': sourceWalletId,
      'destCurrency': destCurrency,
      'amount': amount,
    });
    return FxQuoteModel.fromJson(json);
  }

  Future<FxExecutionModel> executeQuote(String quoteId) async {
    final json = await _api.post('/api/fx/execute', {'quoteId': quoteId});
    return FxExecutionModel.fromJson(json);
  }

  Future<String?> getDefaultWalletId() async {
    try {
      final accounts = await _api.getList('/api/core/accounts');
      if (accounts.isEmpty) return null;
      final accountId =
          (accounts.first as Map<String, dynamic>)['id']?.toString();
      if (accountId == null) return null;
      final wallets = await _api.getList('/api/wallet/list/$accountId');
      if (wallets.isEmpty) return null;
      return (wallets.first as Map<String, dynamic>)['id']?.toString();
    } catch (_) {
      return null;
    }
  }
}
