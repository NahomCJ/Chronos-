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
    try {
      await dismissAlert(event.alertId);
      final alerts = await getAlerts();
      emit(AlertsLoaded(alerts));
    } catch (e) {
      emit(AlertsError(e.toString()));
    }
  }
}
