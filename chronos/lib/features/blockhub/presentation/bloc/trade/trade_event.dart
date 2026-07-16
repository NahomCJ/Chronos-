abstract class TradeEvent {}

class BuyCryptoRequested extends TradeEvent {
  final String asset;
  final double amountUsd;
  BuyCryptoRequested(this.asset, this.amountUsd);
}

class SellCryptoRequested extends TradeEvent {
  final String asset;
  final double amountCrypto;
  SellCryptoRequested(this.asset, this.amountCrypto);
}

class TradeReset extends TradeEvent {}
