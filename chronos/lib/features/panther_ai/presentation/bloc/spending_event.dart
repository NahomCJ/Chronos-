abstract class SpendingEvent {}

class SpendingSummaryLoadRequested extends SpendingEvent {
  final int month;
  final int year;
  SpendingSummaryLoadRequested({required this.month, required this.year});
}
