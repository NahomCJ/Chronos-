import '../../../domain/entities/blockhub_entities.dart';

abstract class TradeState {}

class TradeIdle extends TradeState {}

class TradeLoading extends TradeState {}

class TradeSuccess extends TradeState {
  final TradeResult result;
  TradeSuccess(this.result);
}

class TradeFailure extends TradeState {
  final String message;
  TradeFailure(this.message);
}
