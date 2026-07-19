import '../../domain/entities/unit_banking_entities.dart';
import '../../domain/repositories/unit_banking_repository.dart';
import '../datasources/unit_banking_remote_datasource.dart';

class UnitBankingRepositoryImpl implements UnitBankingRepository {
  final UnitBankingRemoteDataSource _dataSource;
  UnitBankingRepositoryImpl(this._dataSource);

  @override
  Future<UnitBankingSummary> getSummary() async {
    final accounts = await _dataSource.getAccounts();
    final cards = await _dataSource.getCards();
    final transfers = await _dataSource.getTransfers();
    return UnitBankingSummary(
      accounts: accounts.map((m) => m.toEntity()).toList(),
      cards: cards.map((m) => m.toEntity()).toList(),
      transfers: transfers.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<void> freezeCard(String unitCardId) => _dataSource.freezeCard(unitCardId);

  @override
  Future<void> unfreezeCard(String unitCardId) => _dataSource.unfreezeCard(unitCardId);

  @override
  Future<UnitAccountEntity> createAccount({String? depositProduct}) async {
    final model = await _dataSource.createAccount(depositProduct: depositProduct);
    return model.toEntity();
  }

  @override
  Future<UnitCardEntity> issueCard({
    required String unitAccountId,
    Map<String, dynamic>? shippingAddress,
  }) async {
    final model = await _dataSource.issueCard(
      unitAccountId: unitAccountId,
      shippingAddress: shippingAddress,
    );
    return model.toEntity();
  }
}
