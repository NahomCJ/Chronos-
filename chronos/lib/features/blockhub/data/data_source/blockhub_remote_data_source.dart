import '../../../../core/network/api_client.dart';
import '../models/blockhub_models.dart';

const _kBlockhubBase = String.fromEnvironment(
  'BLOCKHUB_BASE_URL',
  defaultValue: 'http://blockhub-env.us-east-1.elasticbeanstalk.com',
);

/// Separate API client pointing at the BlockHub NestJS service.
/// Re-uses the same JWT token from [ApiClient] via composition.
class BlockhubRemoteDataSource {
  final ApiClient _client;

  BlockhubRemoteDataSource(this._client);

  // ── Crypto Portfolio ──────────────────────────────────────

  Future<List<CryptoHoldingModel>> getPortfolio() async {
    final data = await _client.getWithBase(_kBlockhubBase, '/api/v1/portfolio');
    final items = data['holdings'] as List<dynamic>? ??
        data['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => CryptoHoldingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Market Prices (public, no prefix) ────────────────────

  Future<Map<String, double>> getMarketPrices() async {
    final data =
        await _client.getWithBase(_kBlockhubBase, '/market/prices');
    final prices = data['prices'] as Map<String, dynamic>? ?? data;
    return prices.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<double> getAssetPrice(String asset) async {
    final data = await _client.getWithBase(
        _kBlockhubBase, '/market/prices/${asset.toUpperCase()}');
    return (data['price'] as num).toDouble();
  }

  // ── Trading ───────────────────────────────────────────────

  Future<TradeResultModel> buyCrypto(String asset, double amountUsd) async {
    final data = await _client.postWithBase(
      _kBlockhubBase,
      '/api/v1/trade/buy',
      {'asset': asset.toUpperCase(), 'amount_usd': amountUsd},
    );
    return TradeResultModel.fromJson(data);
  }

  Future<TradeResultModel> sellCrypto(
      String asset, double amountCrypto) async {
    final data = await _client.postWithBase(
      _kBlockhubBase,
      '/api/v1/trade/sell',
      {'asset': asset.toUpperCase(), 'amount_crypto': amountCrypto},
    );
    return TradeResultModel.fromJson(data);
  }

  // ── NFT ───────────────────────────────────────────────────

  Future<List<NftCollectionModel>> getNftCollections(
      {int page = 1, int limit = 20}) async {
    final data = await _client.getWithBase(
        _kBlockhubBase, '/api/v1/nft/collections?page=$page&limit=$limit');
    final items = data['collections'] as List<dynamic>? ??
        data['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => NftCollectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NftItemModel>> browseNfts() async {
    final data =
        await _client.getWithBase(_kBlockhubBase, '/api/v1/nft');
    final items = data['nfts'] as List<dynamic>? ??
        data['data'] as List<dynamic>? ??
        [];
    return items
        .map((e) => NftItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
