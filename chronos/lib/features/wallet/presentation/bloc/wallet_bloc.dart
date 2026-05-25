import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_wallet_summary.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletSummary getWalletSummary;

  WalletBloc(this.getWalletSummary) : super(const WalletInitial()) {
    on<WalletSummaryRequested>(_onSummaryRequested);
  }

  Future<void> _onSummaryRequested(
    WalletSummaryRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final summary = await getWalletSummary();
      emit(WalletLoaded(summary));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
