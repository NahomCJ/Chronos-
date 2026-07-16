import '../../../../core/network/api_client.dart';
import '../models/unit_banking_models.dart';

class UnitBankingRemoteDataSource {
  final ApiClient _api;
  UnitBankingRemoteDataSource(this._api);

  Future<List<UnitAccountModel>> getAccounts() async {
    final json = await _api.get('/api/unit/accounts');
    final list = json['accounts'] as List<dynamic>? ?? [];
    return list
        .map((e) => UnitAccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UnitCardModel>> getCards() async {
    final json = await _api.get('/api/unit/cards');
    final list = json['cards'] as List<dynamic>? ?? [];
    return list
        .map((e) => UnitCardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UnitTransferModel>> getTransfers() async {
    final json = await _api.get('/api/unit/transfers');
    final list = json['transfers'] as List<dynamic>? ?? [];
    return list
        .map((e) => UnitTransferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> input) async {
    return _api.post('/api/unit/customers', input);
  }

  Future<UnitAccountModel> createAccount({String? depositProduct}) async {
    final json = await _api.post('/api/unit/accounts', {
      if (depositProduct != null) 'depositProduct': depositProduct,
    });
    return UnitAccountModel.fromJson(
        json['account'] as Map<String, dynamic>? ?? json);
  }

  Future<UnitCardModel> issueCard({
    required String unitAccountId,
    Map<String, dynamic>? shippingAddress,
  }) async {
    final json = await _api.post('/api/unit/cards', {
      'unitAccountId': unitAccountId,
      if (shippingAddress != null) 'shippingAddress': shippingAddress,
    });
    return UnitCardModel.fromJson(
        json['card'] as Map<String, dynamic>? ?? json);
  }

  Future<void> freezeCard(String unitCardId) async {
    await _api.post('/api/unit/cards/$unitCardId/freeze', {});
  }

  Future<void> unfreezeCard(String unitCardId) async {
    await _api.post('/api/unit/cards/$unitCardId/unfreeze', {});
  }

  Future<UnitTransferModel> createTransfer(Map<String, dynamic> input) async {
    final json = await _api.post('/api/unit/transfers', input);
    return UnitTransferModel.fromJson(
        json['transfer'] as Map<String, dynamic>? ?? json);
  }
}
