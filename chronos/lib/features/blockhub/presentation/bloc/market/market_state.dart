abstract class MarketState {}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketLoaded extends MarketState {
  final Map<String, double> prices;
  MarketLoaded(this.prices);

  double? priceFor(String asset) => prices[asset.toUpperCase()];
}

class MarketError extends MarketState {
  final String message;
  MarketError(this.message);
}
