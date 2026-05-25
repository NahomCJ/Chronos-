import '../../domain/entities/ai_alert.dart';

abstract class AlertsState {
  const AlertsState();
}

class AlertsInitial extends AlertsState {
  const AlertsInitial();
}

class AlertsLoading extends AlertsState {
  const AlertsLoading();
}

class AlertsLoaded extends AlertsState {
  final List<AiAlert> alerts;
  const AlertsLoaded(this.alerts);
}

class AlertsError extends AlertsState {
  final String message;
  const AlertsError(this.message);
}
