import 'package:equatable/equatable.dart';

abstract class ExchangeEvent extends Equatable {
  const ExchangeEvent();
  @override
  List<Object?> get props => [];
}

class ExchangeQuoteRequested extends ExchangeEvent {
  final String fromCurrency;
  final String toCurrency;
  final double amount;

  const ExchangeQuoteRequested({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, amount];
}

class ExchangeExecuteRequested extends ExchangeEvent {
  final String quoteId;
  const ExchangeExecuteRequested(this.quoteId);

  @override
  List<Object?> get props => [quoteId];
}
