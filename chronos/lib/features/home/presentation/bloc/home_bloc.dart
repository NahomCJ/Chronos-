import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_summary.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeSummary getHomeSummary;

  HomeBloc(this.getHomeSummary) : super(const HomeInitial()) {
    on<HomeSummaryRequested>(_onSummaryRequested);
  }

  Future<void> _onSummaryRequested(
    HomeSummaryRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final summary = await getHomeSummary();
      emit(HomeLoaded(summary));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
