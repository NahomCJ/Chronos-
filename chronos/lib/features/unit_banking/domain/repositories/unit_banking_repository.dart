import '../entities/unit_banking_entities.dart';

abstract class UnitBankingRepository {
  Future<UnitBankingSummary> getSummary();
  Future<void> freezeCard(String unitCardId);
  Future<void> unfreezeCard(String unitCardId);
  Future<UnitAccountEntity> createAccount({String? depositProduct});
  Future<UnitCardEntity> issueCard({
    required String unitAccountId,
    Map<String, dynamic>? shippingAddress,
  });
}
