import '../../domain/entities/blockhub_entities.dart';

class CryptoHoldingModel {
  final String asset;
  final double amount;
  final double avgPrice;
  final double currentPrice;

  const CryptoHoldingModel({
    required this.asset,
    required this.amount,
    required this.avgPrice,
    required this.currentPrice,
  });

  factory CryptoHoldingModel.fromJson(Map<String, dynamic> json) =>
      CryptoHoldingModel(
        asset: json['asset'] as String? ?? json['symbol'] as String? ?? '',
        amount: (json['amount'] as num? ?? json['quantity'] as num? ?? 0).toDouble(),
        avgPrice: (json['avg_price'] as num? ?? json['avgPrice'] as num? ?? 0).toDouble(),
        currentPrice: (json['current_price'] as num? ?? json['currentPrice'] as num? ?? 0).toDouble(),
      );

  CryptoHolding toEntity() => CryptoHolding(
        asset: asset,
        amount: amount,
        avgPrice: avgPrice,
        currentPrice: currentPrice,
      );
}

class TradeResultModel {
  final String orderId;
  final String asset;
  final String side;
  final double filledAmount;
  final double filledPrice;
  final double fee;
  final String status;

  const TradeResultModel({
    required this.orderId,
    required this.asset,
    required this.side,
    required this.filledAmount,
    required this.filledPrice,
    required this.fee,
    required this.status,
  });

  factory TradeResultModel.fromJson(Map<String, dynamic> json) =>
      TradeResultModel(
        orderId: json['order_id'] as String? ?? json['orderId'] as String? ?? '',
        asset: json['asset'] as String? ?? '',
        side: json['side'] as String? ?? '',
        filledAmount: (json['filled_amount'] as num? ?? json['filledAmount'] as num? ?? 0).toDouble(),
        filledPrice: (json['filled_price'] as num? ?? json['filledPrice'] as num? ?? 0).toDouble(),
        fee: (json['fee'] as num? ?? 0).toDouble(),
        status: json['status'] as String? ?? '',
      );

  TradeResult toEntity() => TradeResult(
        orderId: orderId,
        asset: asset,
        side: side,
        filledAmount: filledAmount,
        filledPrice: filledPrice,
        fee: fee,
        status: status,
      );
}

class NftCollectionModel {
  final String id;
  final String name;
  final double floorPrice;
  final double volume;
  final int itemCount;
  final String? imageUrl;

  const NftCollectionModel({
    required this.id,
    required this.name,
    required this.floorPrice,
    required this.volume,
    required this.itemCount,
    this.imageUrl,
  });

  factory NftCollectionModel.fromJson(Map<String, dynamic> json) =>
      NftCollectionModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        floorPrice: (json['floor_price'] as num? ?? json['floorPrice'] as num? ?? 0).toDouble(),
        volume: (json['volume'] as num? ?? 0).toDouble(),
        itemCount: (json['item_count'] as int? ?? json['itemCount'] as int? ?? 0),
        imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      );

  NftCollection toEntity() => NftCollection(
        id: id,
        name: name,
        floorPrice: floorPrice,
        volume: volume,
        itemCount: itemCount,
        imageUrl: imageUrl,
      );
}

class NftItemModel {
  final String id;
  final String name;
  final String collectionName;
  final String? imageUrl;
  final double price;

  const NftItemModel({
    required this.id,
    required this.name,
    required this.collectionName,
    this.imageUrl,
    required this.price,
  });

  factory NftItemModel.fromJson(Map<String, dynamic> json) => NftItemModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        collectionName: json['collection_name'] as String? ??
            json['collectionName'] as String? ??
            '',
        imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
        price: (json['price'] as num? ?? 0).toDouble(),
      );

  NftItem toEntity() => NftItem(
        id: id,
        name: name,
        collectionName: collectionName,
        imageUrl: imageUrl,
        price: price,
      );
}
