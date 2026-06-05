import '../../../../core/network/api_client.dart';

class TickpayRemoteDataSource {
  final ApiClient _api;
  const TickpayRemoteDataSource(this._api);

  /// Fetch the user's TickPay account including transactions and fee installments.
  /// Returns null if no account exists; rethrows auth errors so callers can
  /// distinguish "not authenticated" from "no account yet".
  Future<Map<String, dynamic>?> getAccount() async {
    try {
      return await _api.get('/api/tickpay/accounts');
    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('unauthorized') || msg.contains('401')) {
        rethrow; // caller will show "please log in" instead of "no account"
      }
      return null;
    }
  }

  /// Create a BNPL purchase on the user's TickPay account.
  Future<Map<String, dynamic>> createPurchase({
    required double amount,
    required String merchant,
    String currency = 'USD',
    Map<String, dynamic>? meta,
  }) async {
    return _api.post('/api/tickpay/accounts/purchases', {
      'amount': amount,
      'merchant': merchant,
      'currency': currency,
      if (meta != null) 'meta': meta,
    });
  }

  /// Submit a repayment against the outstanding balance.
  Future<Map<String, dynamic>> createRepayment({
    required double amount,
    String currency = 'USD',
  }) async {
    return _api.post('/api/tickpay/accounts/repayments', {
      'amount': amount,
      'currency': currency,
    });
  }

  /// List all TickPay-specific transactions for the current user.
  Future<List<dynamic>> getTransactions() async {
    return _api.getList('/api/tickpay/accounts/transactions');
  }
}
