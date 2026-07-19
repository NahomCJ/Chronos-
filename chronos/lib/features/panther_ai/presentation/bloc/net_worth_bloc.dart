import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_net_worth.dart';
import 'net_worth_event.dart';
import 'net_worth_state.dart';

class NetWorthBloc extends Bloc<NetWorthEvent, NetWorthState> {
  final GetNetWorthDashboard getNetWorthDashboard;
  final GetNetWorthProjection getNetWorthProjection;

  NetWorthBloc({
    required this.getNetWorthDashboard,
    required this.getNetWorthProjection,
  }) : super(const NetWorthInitial()) {
    on<NetWorthLoadRequested>(_onLoad);
    on<NetWorthProjectionRequested>(_onProjection);
  }

  Future<void> _onLoad(
      NetWorthLoadRequested event, Emitter<NetWorthState> emit) async {
    emit(const NetWorthLoading());
    try {
      final summary = await getNetWorthDashboard();
      emit(NetWorthLoaded(summary));
    } catch (e) {
      emit(NetWorthError(e.toString()));
      return;
    }

    // A default what-if projection is a nice-to-have on first load — if it
    // fails, the summary above stays visible rather than surfacing an error.
    try {
      final projection = await getNetWorthProjection(
        months: 12,
        monthlyContributionDelta: 300,
      );
      final current = state;
      if (current is NetWorthLoaded) {
        emit(current.copyWith(projection: projection));
      }
    } catch (_) {
      // Ignore — projection is supplementary to the core summary.
    }
  }

  Future<void> _onProjection(
      NetWorthProjectionRequested event, Emitter<NetWorthState> emit) async {
    final current = state;
    if (current is! NetWorthLoaded) return;
    emit(current.copyWith(projectionLoading: true));
    try {
      final projection = await getNetWorthProjection(
        months: event.months,
        monthlyContributionDelta: event.monthlyContributionDelta,
      );
      emit(current.copyWith(projection: projection, projectionLoading: false));
    } catch (_) {
      emit(current.copyWith(projectionLoading: false));
    }
  }
}
