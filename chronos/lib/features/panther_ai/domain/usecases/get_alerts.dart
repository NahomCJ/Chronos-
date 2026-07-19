import '../entities/ai_alert.dart';
import '../repositories/panther_ai_repository.dart';

class GetAlerts {
  final PantherAiRepository repository;
  GetAlerts(this.repository);
  Future<List<AiAlert>> call() => repository.getAlerts();
}

class GenerateAlerts {
  final PantherAiRepository repository;
  GenerateAlerts(this.repository);
  Future<void> call() => repository.generateAlerts();
}

class DismissAlert {
  final PantherAiRepository repository;
  DismissAlert(this.repository);
  Future<void> call(String alertId) => repository.dismissAlert(alertId);
}
