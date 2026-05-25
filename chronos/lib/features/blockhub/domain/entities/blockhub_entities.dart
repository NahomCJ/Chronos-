class CryptoHolding {
  final String asset;
  final double amount;
  final double avgPrice;
  final double currentPrice;

  const CryptoHolding({
    required this.asset,
    required this.amount,
    required this.avgPrice,
    required this.currentPrice,
  });

  double get totalValue => amount * currentPrice;
  double get unrealizedPnl => (currentPrice - avgPrice) * amount;
  double get pnlPercent =>
      avgPrice > 0 ? ((currentPrice - avgPrice) / avgPrice) * 100 : 0;
}

class MarketPrice {
  final String asset;
  final double price;
  final String updatedAt;

  const MarketPrice({
    required this.asset,
    required this.price,
    required this.updatedAt,
  });
}

class TradeResult {
  final String orderId;
  final String asset;
  final String side;
  final double filledAmount;
  final double filledPrice;
  final double fee;
  final String status;

  const TradeResult({
    required this.orderId,
    required this.asset,
    required this.side,
    required this.filledAmount,
    required this.filledPrice,
    required this.fee,
    required this.status,
  });
}

class NftCollection {
  final String id;
  final String name;
  final double floorPrice;
  final double volume;
  final int itemCount;
  final String? imageUrl;

  const NftCollection({
    required this.id,
    required this.name,
    required this.floorPrice,
    required this.volume,
    required this.itemCount,
    this.imageUrl,
  });
}

class NftItem {
  final String id;
  final String name;
  final String collectionName;
  final String? imageUrl;
  final double price;

  const NftItem({
    required this.id,
    required this.name,
    required this.collectionName,
    this.imageUrl,
    required this.price,
  });
}
