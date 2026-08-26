import '../../../../core/network/api_client.dart';

/// Live quote for one supported stock/ETF (Chronos-Backend-'s
/// `/api/v1/stocks/quotes`, priced from Yahoo Finance, no API key needed).
class StockQuoteModel {
  final String symbol;
  final String name;
  final String kind; // "STOCK" | "ETF"
  final double? price;
  final double? changePct;

  const StockQuoteModel({
    required this.symbol,
    required this.name,
    required this.kind,
    required this.price,
    required this.changePct,
  });

  factory StockQuoteModel.fromJson(Map<String, dynamic> json) => StockQuoteModel(
        symbol: json['symbol'] as String? ?? '',
        name: json['name'] as String? ?? '',
        kind: json['kind'] as String? ?? 'STOCK',
        price: (json['price'] as num?)?.toDouble(),
        changePct: (json['changePct'] as num?)?.toDouble(),
      );
}

/// One DB-backed position (paper trading — no live brokerage is connected,
/// see root CLAUDE.md — priced with the same live market data above).
class StockHoldingModel {
  final String symbol;
  final double shares;
  final double avgPrice;
  final double currentPrice;
  final double currentValue;
  final double unrealizedPnl;
  final double pnlPct;

  const StockHoldingModel({
    required this.symbol,
    required this.shares,
    required this.avgPrice,
    required this.currentPrice,
    required this.currentValue,
    required this.unrealizedPnl,
    required this.pnlPct,
  });

  factory StockHoldingModel.fromJson(Map<String, dynamic> json) => StockHoldingModel(
        symbol: json['symbol'] as String? ?? '',
        shares: (json['shares'] as num?)?.toDouble() ?? 0,
        avgPrice: (json['avg_price'] as num?)?.toDouble() ?? 0,
        currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0,
        currentValue: (json['current_value'] as num?)?.toDouble() ?? 0,
        unrealizedPnl: (json['unrealized_pnl'] as num?)?.toDouble() ?? 0,
        pnlPct: (json['pnl_pct'] as num?)?.toDouble() ?? 0,
      );
}

class StockPortfolioModel {
  final List<StockHoldingModel> holdings;
  final double totalValueUsd;
  final double totalPnl;
  final double totalPnlPct;

  const StockPortfolioModel({
    required this.holdings,
    required this.totalValueUsd,
    required this.totalPnl,
    required this.totalPnlPct,
  });

  factory StockPortfolioModel.fromJson(Map<String, dynamic> json) => StockPortfolioModel(
        holdings: ((json['holdings'] as List<dynamic>?) ?? [])
            .map((e) => StockHoldingModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalValueUsd: (json['total_value_usd'] as num?)?.toDouble() ?? 0,
        totalPnl: (json['total_pnl'] as num?)?.toDouble() ?? 0,
        totalPnlPct: (json['total_pnl_pct'] as num?)?.toDouble() ?? 0,
      );
}

class StockOrderResultModel {
  final String orderId;
  final String symbol;
  final String side;
  final double shares;
  final double price;
  final double amountUsd;

  const StockOrderResultModel({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.shares,
    required this.price,
    required this.amountUsd,
  });

  factory StockOrderResultModel.fromJson(Map<String, dynamic> json) => StockOrderResultModel(
        orderId: json['orderId'] as String? ?? '',
        symbol: json['symbol'] as String? ?? '',
        side: json['side'] as String? ?? '',
        shares: (json['shares'] as num?)?.toDouble() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        amountUsd: (json['amountUsd'] as num?)?.toDouble() ?? 0,
      );
}

/// Chronos-Backend-'s own `/api/v1/stocks` module — same backend/JWT as the
/// rest of the app (see ApiClient), no separate base URL needed. Paper
/// trading: real DB positions and real cash movement against the user's
/// wallet ledger, priced with live market data; no live brokerage is
/// connected behind it (root CLAUDE.md).
class StocksRemoteDataSource {
  final ApiClient _client;

  StocksRemoteDataSource(this._client);

  Future<List<StockQuoteModel>> getQuotes() async {
    final data = await _client.getWithBase(_client.baseUrl, '/api/v1/stocks/quotes');
    final items = data['stocks'] as List<dynamic>? ?? [];
    return items.map((e) => StockQuoteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StockPortfolioModel> getPortfolio() async {
    final data = await _client.getWithBase(_client.baseUrl, '/api/v1/stocks/portfolio');
    return StockPortfolioModel.fromJson(data);
  }

  Future<StockOrderResultModel> buy(String symbol, double shares) async {
    final data = await _client.postWithBase(
      _client.baseUrl,
      '/api/v1/stocks/orders/buy',
      {'symbol': symbol, 'shares': shares},
    );
    return StockOrderResultModel.fromJson(data);
  }

  Future<StockOrderResultModel> sell(String symbol, double shares) async {
    final data = await _client.postWithBase(
      _client.baseUrl,
      '/api/v1/stocks/orders/sell',
      {'symbol': symbol, 'shares': shares},
    );
    return StockOrderResultModel.fromJson(data);
  }
}
