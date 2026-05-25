import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';
import '../../domain/entities/wallet_entity.dart';

class WalletRemoteDataSource {
  final ApiClient _api;
  WalletRemoteDataSource(this._api);

  Future<List<WalletModel>> getWallets(String accountId) async {
    final list = await _api.getList('/api/wallet/list/$accountId');
    return list
        .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CardModel>> getCards() async {
    final list = await _api.getList('/api/cards');
    return list
        .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TransactionModel>> getTransactions() async {
    final list = await _api.getList('/api/transactions');
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> getFirstAccountId() async {
    try {
      final list = await _api.getList('/api/core/accounts');
      if (list.isEmpty) return null;
      final first = list.first as Map<String, dynamic>;
      return first['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<WalletSummary> getWalletSummary() async {
    final accountId = await getFirstAccountId();
    final wallets = accountId != null ? await getWallets(accountId) : <WalletModel>[];
    final cards = await getCards();
    final transactions = await getTransactions();

    return WalletSummary(
      wallets: wallets.map((w) => w.toEntity()).toList(),
      cards: cards.map((c) => c.toEntity()).toList(),
      recentTransactions: transactions.map((t) => t.toEntity()).toList(),
    );
  }
}
