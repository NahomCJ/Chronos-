import 'package:flutter/material.dart';
import '../../domain/entities/auto_invest_enums.dart';

/// Bundled locally — same reasoning as blockhub_page.dart's coin art:
/// logo.clearbit.com (used for stock-brand logos elsewhere) was discontinued
/// as a free API, so crypto renders from `assets/crypto/` instead of a URL.
const _kCryptoLogoAssets = <String, String>{
  'BTC': 'assets/crypto/btc.png',
  'ETH': 'assets/crypto/eth.png',
  'SOL': 'assets/crypto/sol.png',
  'XRP': 'assets/crypto/xrp.png',
  'ADA': 'assets/crypto/ada.png',
  'DOT': 'assets/crypto/dot.png',
  'MATIC': 'assets/crypto/matic.png',
  'LINK': 'assets/crypto/link.png',
  'AVAX': 'assets/crypto/avax.png',
  'LTC': 'assets/crypto/ltc.png',
  'USDT': 'assets/crypto/usdt.png',
  'USDC': 'assets/crypto/usdc.png',
};

class _StockGlyph {
  final IconData icon;
  final Color color;
  const _StockGlyph(this.icon, this.color);
}

// Recognizable glyph + real brand color per well-known ticker. No bundled
// logo art exists for stocks, so this stands in for one — closer to a real
// mark than a plain letter, without depending on a discontinued logo API.
const _kStockGlyphs = <String, _StockGlyph>{
  'AAPL': _StockGlyph(Icons.apple, Color(0xFF1D1D1F)),
  'MSFT': _StockGlyph(Icons.grid_view, Color(0xFF00A4EF)),
  'AMZN': _StockGlyph(Icons.shopping_bag, Color(0xFFFF9900)),
  'GOOGL': _StockGlyph(Icons.search, Color(0xFF4285F4)),
};

/// Per-symbol icon for an Auto-Invest allocation row: the real coin image
/// for crypto, a recognizable brand glyph for well-known stock tickers, and
/// an asset-class icon as the fallback (index ETFs don't have a single
/// owning brand to show a logo for).
class AutoInvestAssetIcon extends StatelessWidget {
  final String symbol;
  final AutoInvestAssetClass assetClass;
  final Color accent;
  final double size;

  const AutoInvestAssetIcon({
    super.key,
    required this.symbol,
    required this.assetClass,
    required this.accent,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final cryptoAsset = _kCryptoLogoAssets[symbol];
    if (cryptoAsset != null) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: 0.10),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
        ),
        child: Image.asset(cryptoAsset, fit: BoxFit.contain),
      );
    }

    final glyph = _kStockGlyphs[symbol];
    if (glyph != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: glyph.color.withValues(alpha: 0.12),
          border: Border.all(color: glyph.color.withValues(alpha: 0.22)),
        ),
        child: Icon(glyph.icon, color: glyph.color, size: size * 0.5),
      );
    }

    final classIcon = switch (assetClass) {
      AutoInvestAssetClass.crypto => Icons.currency_bitcoin,
      AutoInvestAssetClass.stock => Icons.show_chart,
      AutoInvestAssetClass.etf => Icons.donut_large,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Icon(classIcon, color: accent, size: size * 0.46),
    );
  }
}

/// Class-level icon used on the summary ring's legend (Crypto / Stocks /
/// ETFs slices), distinct from the per-symbol icon above.
IconData autoInvestClassIcon(AutoInvestAssetClass assetClass) {
  switch (assetClass) {
    case AutoInvestAssetClass.crypto:
      return Icons.currency_bitcoin;
    case AutoInvestAssetClass.stock:
      return Icons.show_chart;
    case AutoInvestAssetClass.etf:
      return Icons.donut_large;
  }
}
