import '../entities/blockhub_entities.dart';
import '../repositories/blockhub_repository.dart';

class GetCryptoPortfolio {
  final BlockhubRepository repository;
  GetCryptoPortfolio(this.repository);
  Future<List<CryptoHolding>> call() => repository.getPortfolio();
}

class GetMarketPrices {
  final BlockhubRepository repository;
  GetMarketPrices(this.repository);
  Future<Map<String, double>> call() => repository.getMarketPrices();
}

class GetAssetPrice {
  final BlockhubRepository repository;
  GetAssetPrice(this.repository);
  Future<double> call(String asset) => repository.getAssetPrice(asset);
}

class BuyCrypto {
  final BlockhubRepository repository;
  BuyCrypto(this.repository);
  Future<TradeResult> call(String asset, double amountUsd) =>
      repository.buyCrypto(asset, amountUsd);
}

class SellCrypto {
  final BlockhubRepository repository;
  SellCrypto(this.repository);
  Future<TradeResult> call(String asset, double amountCrypto) =>
      repository.sellCrypto(asset, amountCrypto);
}

class GetNftCollections {
  final BlockhubRepository repository;
  GetNftCollections(this.repository);
  Future<List<NftCollection>> call({int page = 1}) =>
      repository.getNftCollections(page: page);
}

class BrowseNfts {
  final BlockhubRepository repository;
  BrowseNfts(this.repository);
  Future<List<NftItem>> call() => repository.browseNfts();
}
