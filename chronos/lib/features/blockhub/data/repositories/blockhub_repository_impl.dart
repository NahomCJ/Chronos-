import '../../domain/entities/blockhub_entities.dart';
import '../../domain/repositories/blockhub_repository.dart';
import '../data_source/blockhub_remote_data_source.dart';

class BlockhubRepositoryImpl implements BlockhubRepository {
  final BlockhubRemoteDataSource _remote;

  BlockhubRepositoryImpl(this._remote);

  @override
  Future<List<CryptoHolding>> getPortfolio() async {
    final models = await _remote.getPortfolio();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Map<String, double>> getMarketPrices() => _remote.getMarketPrices();

  @override
  Future<double> getAssetPrice(String asset) => _remote.getAssetPrice(asset);

  @override
  Future<TradeResult> buyCrypto(String asset, double amountUsd) async {
    final model = await _remote.buyCrypto(asset, amountUsd);
    return model.toEntity();
  }

  @override
  Future<TradeResult> sellCrypto(String asset, double amountCrypto) async {
    final model = await _remote.sellCrypto(asset, amountCrypto);
    return model.toEntity();
  }

  @override
  Future<List<NftCollection>> getNftCollections(
      {int page = 1, int limit = 20}) async {
    final models = await _remote.getNftCollections(page: page, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<NftItem>> browseNfts() async {
    final models = await _remote.browseNfts();
    return models.map((m) => m.toEntity()).toList();
  }
}
