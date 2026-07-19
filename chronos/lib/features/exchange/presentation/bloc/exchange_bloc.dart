import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_fx_quote.dart';
import '../../data/data_source/exchange_remote_data_source.dart';
import 'exchange_event.dart';
import 'exchange_state.dart';

class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
  final GetFxQuote getFxQuote;
  final ExecuteFx executeFx;
  final ExchangeRemoteDataSource dataSource;

  ExchangeBloc({
    required this.getFxQuote,
    required this.executeFx,
    required this.dataSource,
  }) : super(const ExchangeInitial()) {
    on<ExchangeQuoteRequested>(_onQuoteRequested);
    on<ExchangeExecuteRequested>(_onExecuteRequested);
  }

  Future<void> _onQuoteRequested(
    ExchangeQuoteRequested event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(const ExchangeLoading());
    try {
      final walletId = await dataSource.getDefaultWalletId() ?? '';
      final quote = await getFxQuote(
        sourceWalletId: walletId,
        destCurrency: event.toCurrency,
        amount: event.amount,
      );
      emit(ExchangeQuoteLoaded(quote));
    } catch (e) {
      emit(ExchangeError(e.toString()));
    }
  }

  Future<void> _onExecuteRequested(
    ExchangeExecuteRequested event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(const ExchangeLoading());
    try {
      final execution = await executeFx(event.quoteId);
      emit(ExchangeExecuted(execution));
    } catch (e) {
      emit(ExchangeError(e.toString()));
    }
  }
}
