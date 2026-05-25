import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_affordability.dart';
import 'affordability_event.dart';
import 'affordability_state.dart';

class AffordabilityBloc extends Bloc<AffordabilityEvent, AffordabilityState> {
  final CheckAffordability checkAffordability;

  AffordabilityBloc({required this.checkAffordability})
      : super(const AffordabilityInitial()) {
    on<AffordabilityCheckRequested>(_onCheck);
  }

  Future<void> _onCheck(
      AffordabilityCheckRequested event, Emitter<AffordabilityState> emit) async {
    emit(const AffordabilityLoading());
    try {
      final result =
          await checkAffordability(event.amount, event.merchant);
      emit(AffordabilityLoaded(result));
    } catch (e) {
      emit(AffordabilityError(e.toString()));
    }
  }
}
