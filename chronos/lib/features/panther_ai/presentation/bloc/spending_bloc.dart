import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_spending_summary.dart';
import 'spending_event.dart';
import 'spending_state.dart';

class SpendingBloc extends Bloc<SpendingEvent, SpendingState> {
  final GetSpendingSummary _getSpendingSummary;

  SpendingBloc({required GetSpendingSummary getSpendingSummary})
      : _getSpendingSummary = getSpendingSummary,
        super(SpendingInitial()) {
    on<SpendingSummaryLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
      SpendingSummaryLoadRequested event, Emitter<SpendingState> emit) async {
    emit(SpendingLoading());
    try {
      final summary =
          await _getSpendingSummary(month: event.month, year: event.year);
      emit(SpendingLoaded(summary));
    } catch (e) {
      emit(SpendingError(e.toString()));
    }
  }
}
