import '../entities/transaction.dart';
import '../repositories/panther_ai_repository.dart';

class GetTransactions {
  final PantherAiRepository repository;
  GetTransactions(this.repository);

  Future<List<PantherTransaction>> call({int days = 30}) =>
      repository.getTransactions(days: days);
}
