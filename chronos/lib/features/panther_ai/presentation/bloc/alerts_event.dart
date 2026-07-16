abstract class AlertsEvent {
  const AlertsEvent();
}

class AlertsLoadRequested extends AlertsEvent {
  const AlertsLoadRequested();
}

class AlertsGenerateRequested extends AlertsEvent {
  const AlertsGenerateRequested();
}

class AlertDismissRequested extends AlertsEvent {
  final String alertId;
  const AlertDismissRequested(this.alertId);
}
