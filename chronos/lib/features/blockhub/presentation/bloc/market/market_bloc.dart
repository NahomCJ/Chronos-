import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/blockhub_usecases.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final GetMarketPrices _getMarketPrices;

  MarketBloc({required GetMarketPrices getMarketPrices})
      : _getMarketPrices = getMarketPrices,
        super(MarketInitial()) {
    on<MarketPricesLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
      MarketPricesLoadRequested event, Emitter<MarketState> emit) async {
    emit(MarketLoading());
    try {
      final prices = await _getMarketPrices();
      emit(MarketLoaded(prices));
    } catch (e) {
      emit(MarketError(e.toString()));
    }
  }
}
