import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_alerts.dart';
import 'alerts_event.dart';
import 'alerts_state.dart';

class AlertsBloc extends Bloc<AlertsEvent, AlertsState> {
  final GetAlerts getAlerts;
  final GenerateAlerts generateAlerts;
  final DismissAlert dismissAlert;

  AlertsBloc({
    required this.getAlerts,
    required this.generateAlerts,
    required this.dismissAlert,
  }) : super(const AlertsInitial()) {
    on<AlertsLoadRequested>(_onLoad);
    on<AlertsGenerateRequested>(_onGenerate);
    on<AlertDismissRequested>(_onDismiss);
  }

  Future<void> _onLoad(
      AlertsLoadRequested event, Emitter<AlertsState> emit) async {
    emit(const AlertsLoading());
    try {
      final alerts = await getAlerts();
      emit(AlertsLoaded(alerts));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  Future<void> _onGenerate(
      AlertsGenerateRequested event, Emitter<AlertsState> emit) async {
    try {
      await generateAlerts();
      final alerts = await getAlerts();
      emit(AlertsLoaded(alerts));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }

  Future<void> _onDismiss(
      AlertDismissRequested event, Emitter<AlertsState> emit) async {
    final current = state;
    if (current is! AlertsLoaded) {
      // No optimistic base to show/roll back to — fall back to the old
      // await-then-refresh behavior.
      try {
        await dismissAlert(event.alertId);
        final alerts = await getAlerts();
        emit(AlertsLoaded(alerts));
      } catch (e) {
        emit(AlertsError(e.toString()));
      }
      return;
    }

    // Optimistic update: remove the alert immediately so the tap feels
    // instant, then confirm with the server in the background. Roll back to
    // the pre-dismiss list if the server call fails, so a failed dismiss
    // doesn't silently hide an alert the user still has.
    final previousAlerts = current.alerts;
    final optimisticAlerts =
        previousAlerts.where((a) => a.id != event.alertId).toList();
    emit(AlertsLoaded(optimisticAlerts));

    try {
      await dismissAlert(event.alertId);
    } catch (e) {
      emit(AlertsLoaded(previousAlerts));
    }
  }
}
