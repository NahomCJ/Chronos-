import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/blockhub_usecases.dart';
import 'trade_event.dart';
import 'trade_state.dart';

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  final BuyCrypto _buyCrypto;
  final SellCrypto _sellCrypto;

  TradeBloc({required BuyCrypto buyCrypto, required SellCrypto sellCrypto})
      : _buyCrypto = buyCrypto,
        _sellCrypto = sellCrypto,
        super(TradeIdle()) {
    on<BuyCryptoRequested>(_onBuy);
    on<SellCryptoRequested>(_onSell);
    on<TradeReset>((_, emit) => emit(TradeIdle()));
  }

  Future<void> _onBuy(
      BuyCryptoRequested event, Emitter<TradeState> emit) async {
    emit(TradeLoading());
    try {
      final result = await _buyCrypto(event.asset, event.amountUsd);
      emit(TradeSuccess(result));
    } catch (e) {
      emit(TradeFailure(e.toString()));
    }
  }

  Future<void> _onSell(
      SellCryptoRequested event, Emitter<TradeState> emit) async {
    emit(TradeLoading());
    try {
      final result = await _sellCrypto(event.asset, event.amountCrypto);
      emit(TradeSuccess(result));
    } catch (e) {
      emit(TradeFailure(e.toString()));
    }
  }
}
