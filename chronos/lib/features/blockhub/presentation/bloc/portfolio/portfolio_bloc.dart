import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/blockhub_usecases.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetCryptoPortfolio _getPortfolio;

  PortfolioBloc({required GetCryptoPortfolio getPortfolio})
      : _getPortfolio = getPortfolio,
        super(PortfolioInitial()) {
    on<PortfolioLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
      PortfolioLoadRequested event, Emitter<PortfolioState> emit) async {
    emit(PortfolioLoading());
    try {
      final holdings = await _getPortfolio();
      emit(PortfolioLoaded(holdings));
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }
}
