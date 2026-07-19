import '../../../../core/network/api_client.dart';
import '../models/transfer_model.dart';

class TransferRemoteDataSource {
  final ApiClient _api;
  TransferRemoteDataSource(this._api);

  Future<TransferModel> createTransfer({
    required String sourceWalletId,
    required String destWalletId,
    required double amount,
    required String currency,
    String? reference,
  }) async {
    final json = await _api.post('/api/v1/transfer', {
      'sourceWalletId': sourceWalletId,
      'destWalletId': destWalletId,
      'amount': amount,
      'currency': currency,
      if (reference != null) 'reference': reference,
    });
    return TransferModel.fromJson(json);
  }

  Future<List<TransferModel>> getTransfers() async {
    final list = await _api.getList('/api/v1/transfer');
    return list
        .map((e) => TransferModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
