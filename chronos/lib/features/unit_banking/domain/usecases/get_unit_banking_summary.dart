import '../entities/unit_banking_entities.dart';
import '../repositories/unit_banking_repository.dart';

class GetUnitBankingSummary {
  final UnitBankingRepository _repository;
  GetUnitBankingSummary(this._repository);

  Future<UnitBankingSummary> call() => _repository.getSummary();
}
