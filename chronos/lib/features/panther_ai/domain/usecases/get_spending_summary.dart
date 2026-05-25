import '../entities/spending_summary.dart';
import '../repositories/panther_ai_repository.dart';

class GetSpendingSummary {
  final PantherAiRepository repository;
  GetSpendingSummary(this.repository);

  Future<SpendingSummary> call({required int month, required int year}) =>
      repository.getSpendingSummary(month: month, year: year);
}
