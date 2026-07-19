import 'package:equatable/equatable.dart';
import '../../domain/entities/exchange_entity.dart';

abstract class ExchangeState extends Equatable {
  const ExchangeState();
  @override
  List<Object?> get props => [];
}

class ExchangeInitial extends ExchangeState {
  const ExchangeInitial();
}

class ExchangeLoading extends ExchangeState {
  const ExchangeLoading();
}

class ExchangeQuoteLoaded extends ExchangeState {
  final FxQuote quote;
  const ExchangeQuoteLoaded(this.quote);

  @override
  List<Object?> get props => [quote];
}

class ExchangeExecuted extends ExchangeState {
  final FxExecution execution;
  const ExchangeExecuted(this.execution);

  @override
  List<Object?> get props => [execution];
}

class ExchangeError extends ExchangeState {
  final String message;
  const ExchangeError(this.message);

  @override
  List<Object?> get props => [message];
}
