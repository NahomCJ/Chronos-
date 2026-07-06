import '../entities/blockhub_entities.dart';

abstract class BlockhubRepository {
  Future<List<CryptoHolding>> getPortfolio();
  Future<Map<String, double>> getMarketPrices();
  Future<double> getAssetPrice(String asset);
  Future<TradeResult> buyCrypto(String asset, double amountUsd);
  Future<TradeResult> sellCrypto(String asset, double amountCrypto);
  Future<List<NftCollection>> getNftCollections({int page = 1, int limit = 20});
  Future<List<NftItem>> browseNfts();
  Future<NftCollection?> getFeaturedCollection();
  Future<List<NftCollection>> getTrendingCollections({String? category, int limit = 10});
  Future<List<NftCollection>> getTopVolumeCollections(
      {String period = '24h', String? category, int limit = 10});
  Future<List<NftItem>> getNewDrops({String? category, int limit = 10});
}
