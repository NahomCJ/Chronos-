import '../../domain/entities/spending_summary.dart';

abstract class SpendingState {}

class SpendingInitial extends SpendingState {}

class SpendingLoading extends SpendingState {}

class SpendingLoaded extends SpendingState {
  final SpendingSummary summary;
  SpendingLoaded(this.summary);
}

class SpendingError extends SpendingState {
  final String message;
  SpendingError(this.message);
}
