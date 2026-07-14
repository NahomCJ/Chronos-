import 'package:flutter/material.dart';
import 'coin_icon_scale.dart';

/// The real 3D coin renders BlockHub already ships in `assets/crypto/` —
/// reused here so Panther's trading/portfolio pages show the same Bitcoin,
/// Ethereum, Solana, etc. artwork instead of generic circle-with-a-letter
/// placeholders. Symbols without a local 3D asset fall back to a colored
/// initials badge rather than breaking the row.
const Map<String, String> _kCoin3dAssets = {
  'BTC': 'assets/crypto/btc.png',
  'ETH': 'assets/crypto/eth.png',
  'SOL': 'assets/crypto/sol.png',
  'ADA': 'assets/crypto/ada.png',
  'DOT': 'assets/crypto/dot.png',
  'XRP': 'assets/crypto/xrp.png',
  'AVAX': 'assets/crypto/avax.png',
  'USDC': 'assets/crypto/usdc.png',
  'USDT': 'assets/crypto/usdt.png',
  'LINK': 'assets/crypto/link.png',
  'MATIC': 'assets/crypto/matic.png',
  'LTC': 'assets/crypto/ltc.png',
  'INJ': 'assets/crypto/inj.png',
};

const Map<String, Color> _kCoinFallbackColor = {
  'BTC': Color(0xFFF7931A),
  'ETH': Color(0xFF7C6EF0),
  'SOL': Color(0xFF14F195),
  'ADA': Color(0xFF3B82F6),
  'DOT': Color(0xFFE6007A),
  'XRP': Color(0xFF23292F),
  'AVAX': Color(0xFFE84142),
  'USDC': Color(0xFF3B82F6),
  'USDT': Color(0xFF22C55E),
  'LINK': Color(0xFF3B82F6),
  'MATIC': Color(0xFF7C6EF0),
};

class CryptoCoinIcon extends StatelessWidget {
  final String symbol;
  final double size;

  const CryptoCoinIcon({super.key, required this.symbol, this.size = 38});

  @override
  Widget build(BuildContext context) {
    final sym = symbol.toUpperCase();
    final asset = _kCoin3dAssets[sym];
    if (asset == null) {
      final color = _kCoinFallbackColor[sym] ?? const Color(0xFF6B7080);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            sym.isNotEmpty ? sym[0] : '?',
            style: TextStyle(
              color: color,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final fillScale = coinBadgeScale(sym);
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFF3F4F6),
        child: Transform.scale(
          scale: fillScale,
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
