import '../entities/blockhub_entities.dart';

abstract class BlockhubRepository {
  Future<List<CryptoHolding>> getPortfolio();
  Future<Map<String, double>> getMarketPrices();
  Future<double> getAssetPrice(String asset);
  Future<TradeResult> buyCrypto(String asset, double amountUsd);
  Future<TradeResult> sellCrypto(String asset, double amountCrypto);
  Future<List<NftCollection>> getNftCollections({int page = 1, int limit = 20});
  Future<List<NftItem>> browseNfts();
}
