// Every 3D coin PNG in assets/crypto/ (and assets/Blockhub/extracted/bnb.png)
// has a different amount of transparent padding baked in around the coin
// itself, even though they're all rendered at roughly the same pixel size.
// At a fixed box size, BoxFit.contain/cover scale by the *canvas* dimensions,
// not the coin's own footprint — so low-padding coins (e.g. MATIC) render
// visibly larger than high-padding ones (BTC, ETH) even in an identical box.
//
// These multipliers were measured from each asset's actual non-transparent
// pixel bounds and normalize every coin to Bitcoin's apparent size, with a
// ~15% bump so Bitcoin itself renders a bit larger than before.

/// For BoxFit.contain "preview" renders (home carousel, buy/sell central
/// coin display, coin-detail sheet) — wrap the Image with
/// `Transform.scale(scale: previewScale(symbol), child: ...)`.
const kCoinPreviewScale = <String, double>{
  'BTC': 1.15,
  'ETH': 1.167,
  'BNB': 0.76,
  'SOL': 1.035,
  'XRP': 1.025,
  'ADA': 0.854,
  'DOT': 0.922,
  'MATIC': 0.747,
  'LINK': 0.852,
  'AVAX': 0.991,
  'LTC': 0.956,
  'USDT': 0.976,
  'USDC': 1.017,
};

/// For BoxFit.cover small circular icons (coin-selector strips, list rows,
/// swap chips) — without correction, high-padding coins leave visible empty
/// space around a shrunken coin inside the circle. These zoom each coin in
/// just enough to fully fill the circle; never below 1.0, so nothing shrinks
/// past its native crop.
const kCoinBadgeScale = <String, double>{
  'BTC': 1.70,
  'ETH': 1.71,
  'BNB': 1.0,
  'SOL': 1.44,
  'XRP': 1.52,
  'ADA': 1.24,
  'DOT': 1.34,
  'MATIC': 1.0,
  'LINK': 1.21,
  'AVAX': 1.44,
  'LTC': 1.36,
  'USDT': 1.33,
  'USDC': 1.39,
};

double coinPreviewScale(String symbol) => kCoinPreviewScale[symbol] ?? 1.15;
double coinBadgeScale(String symbol) => kCoinBadgeScale[symbol] ?? 1.0;
