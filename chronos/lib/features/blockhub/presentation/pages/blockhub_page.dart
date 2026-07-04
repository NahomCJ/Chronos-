import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import 'buy/buy_btc_page.dart';
import 'sell/sell_btc_page.dart';
import 'wallets/send_crypto_page.dart';
import '../widgets/more_options_modal.dart';
import 'onboarding/blockhub_welcome_page.dart';
import 'onboarding/setup_wallet_page.dart';
import 'markets_page.dart';
import 'trade_page.dart';
import 'nft/nft_marketplace_page.dart';

// ── Coin data model ────────────────────────────────────────────────────────────
class _CoinData {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final bool isPositive;
  final Color primaryColor;
  final Color secondaryColor;
  const _CoinData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isPositive,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

const List<_CoinData> _coins = [
  _CoinData(
    symbol: 'BTC', name: 'Bitcoin', price: 67.4, change: 2.3, isPositive: true,
    primaryColor: Color(0xFFF7931A), secondaryColor: Color(0xFFFF9900),
  ),
  _CoinData(
    symbol: 'ETH', name: 'Ethereum', price: 3.8, change: 1.8, isPositive: true,
    primaryColor: Color(0xFF627EEA), secondaryColor: Color(0xFF8A9FF0),
  ),
  _CoinData(
    symbol: 'SOL', name: 'Solana', price: 178, change: 0.9, isPositive: false,
    primaryColor: Color(0xFF9945FF), secondaryColor: Color(0xFF14F195),
  ),
  _CoinData(
    symbol: 'BNB', name: 'BNB', price: 608, change: 3.1, isPositive: true,
    primaryColor: Color(0xFFF3BA2F), secondaryColor: Color(0xFFFFD700),
  ),
  _CoinData(
    symbol: 'ADA', name: 'Cardano', price: 0.62, change: 1.2, isPositive: false,
    primaryColor: Color(0xFF0033AD), secondaryColor: Color(0xFF4A90D9),
  ),
  _CoinData(
    symbol: 'DOT', name: 'Polkadot', price: 9.8, change: 0.7, isPositive: true,
    primaryColor: Color(0xFFE6007A), secondaryColor: Color(0xFFFF4DA1),
  ),
  _CoinData(
    symbol: 'MATIC', name: 'Polygon', price: 1.05, change: 4.2, isPositive: true,
    primaryColor: Color(0xFF8247E5), secondaryColor: Color(0xFFA855F7),
  ),
  _CoinData(
    symbol: 'LINK', name: 'Chainlink', price: 18.2, change: 2.9, isPositive: true,
    primaryColor: Color(0xFF2A5ADA), secondaryColor: Color(0xFF4B7BF5),
  ),
  _CoinData(
    symbol: 'AVAX', name: 'Avalanche', price: 42.1, change: 1.5, isPositive: true,
    primaryColor: Color(0xFFE84142), secondaryColor: Color(0xFFFF6B6B),
  ),
];

class BlockHubPage extends StatefulWidget {
  const BlockHubPage({super.key});

  @override
  State<BlockHubPage> createState() => _BlockHubPageState();
}

class _BlockHubPageState extends State<BlockHubPage> {
  bool _isLoading = true;
  bool _hasCheckedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Only check onboarding status once when the page first loads
    if (_hasCheckedOnboarding) {
      setState(() => _isLoading = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('blockhub_onboarding_completed') ?? false;
    final hasCompletedWalletSetup =
        prefs.getBool('blockhub_wallet_setup_completed') ?? false;

    _hasCheckedOnboarding = true;

    if (!hasCompletedOnboarding && mounted) {
      // Navigate to onboarding using root navigator (hides bottom nav)
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => const BlockHubWelcomePage()),
      );
      // After returning, just show the page (don't check again)
      setState(() => _isLoading = false);
    } else if (!hasCompletedWalletSetup && mounted) {
      // Navigate to wallet setup using root navigator (hides bottom nav)
      await Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (context) => const SetupWalletPage()));
      // After returning, just show the page (don't check again)
      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoading = false);
    }
  }

  final List<CryptoAsset> _watchlist = [
    CryptoAsset(
      name: 'Bitcoin',
      symbol: 'BTC',
      price: 67.43,
      change: 2.34,
      isPositive: true,
    ),
    CryptoAsset(
      name: 'Ethereum',
      symbol: 'ETH',
      price: 67.43,
      change: 2.34,
      isPositive: true,
    ),
    CryptoAsset(
      name: 'Solana',
      symbol: 'SOL',
      price: 67.43,
      change: 2.34,
      isPositive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF08080F),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B))),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final hp = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Photo (header → wallet boxes → nav icons → action btns) ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900',
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: const Color(0xFF1A3A5E)),
                      errorWidget: (_, __, ___) =>
                          Container(color: const Color(0xFF1A3A5E)),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.40),
                            Colors.black.withValues(alpha: 0.72),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hp, 14, hp, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row
                          Row(
                            children: [
                              const Text('BlockHub',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              const Spacer(),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: const Icon(Icons.search_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.45)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                    Icon(Icons.currency_bitcoin,
                                        color: Color(0xFFF59E0B), size: 12),
                                    SizedBox(width: 5),
                                    Text('CRYPTO & NFT MARKETPLACE',
                                        style: TextStyle(
                                            color: Color(0xFFF59E0B),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8)),
                                  ],
                                ),
                          ),
                          const SizedBox(height: 6),
                          const Text('Your Digital\nAsset Hub',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1)),
                          const SizedBox(height: 20),
                          // Wallet boxes
                          Row(
                            children: [
                              Expanded(child: _buildWalletBox(
                                label: 'Crypto',
                                value: '\$24,521',
                                sublabel: 'Portfolio Value',
                                icon: Icons.currency_bitcoin,
                                color: const Color(0xFFF59E0B),
                                bg: Colors.white.withValues(alpha: 0.10),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketsPage())),
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: _buildWalletBox(
                                label: 'NFT',
                                value: '12 Items',
                                sublabel: 'Collection',
                                icon: Icons.collections_rounded,
                                color: const Color(0xFF8B5CF6),
                                bg: Colors.white.withValues(alpha: 0.08),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NftMarketplacePage())),
                              )),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Action buttons (Buy/Sell/Swap/Send/More) — top
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(Icons.add, 'Buy', isSmallScreen,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyBtcPage()))),
                              _buildActionButton(Icons.trending_down, 'Sell', isSmallScreen,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellBtcPage()))),
                              _buildActionButton(Icons.swap_horiz, 'Swap', isSmallScreen,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TradePage()))),
                              _buildActionButton(Icons.send, 'Send', isSmallScreen,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendCryptoPage()))),
                              _buildActionButton(Icons.more_horiz, 'More', isSmallScreen,
                                  onTap: () => MoreOptionsModal.show(context)),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Light-theme bottom section ─────────────────────────────────
            Container(
              color: const Color(0xFFF5F7FA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // Top Movers
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hp),
                    child: const Text('Top Movers',
                        style: TextStyle(
                            color: Color(0xFF12122A),
                            fontWeight: FontWeight.w800,
                            fontSize: 17)),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 210,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.72),
                      itemCount: _coins.length,
                      itemBuilder: (context, index) {
                        final coin = _coins[index];
                        return GestureDetector(
                          onTap: () => _showCoinDetail(context, coin),
                          child: _buildCoinCardLight(coin),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Watchlist
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Watchlist',
                            style: TextStyle(
                                color: Color(0xFF12122A),
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                        const SizedBox(height: 14),
                        ..._watchlist.map((asset) =>
                            _buildWatchlistItemLight(asset, isSmallScreen)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    bool isSmallScreen, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 44 : 48,
            height: isSmallScreen ? 44 : 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── Local 3-D coin assets (assets/Blockhub/extracted/) ──────────────────
  // Scale X by 1/cos(30°) ≈ 1.22 inside ClipOval to counter the baked-in
  // 30° Y-rotation so the coin face appears straight-on to the viewer.
  static const _coin3dAssets = {
    'BTC': 'assets/Blockhub/extracted/bitcoin.png',
    'ETH': 'assets/Blockhub/extracted/ethereum.png',
    'BNB': 'assets/Blockhub/extracted/bnb.png',
    'SOL': 'assets/Blockhub/extracted/solana.png',
    'XRP': 'assets/Blockhub/extracted/xrp.png',
  };

  // Fallback CDN logos for coins without a local 3-D asset
  static const _coinLogos = {
    'ADA':  'https://assets.coingecko.com/coins/images/975/large/cardano.png',
    'DOT':  'https://assets.coingecko.com/coins/images/12171/large/polkadot.png',
    'MATIC':'https://assets.coingecko.com/coins/images/4713/large/matic-token-icon.png',
    'LINK': 'https://assets.coingecko.com/coins/images/877/large/chainlink-new-logo.png',
    'AVAX': 'https://assets.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png',
  };

  // ── 3-D coin icon — face corrected to straight-on ────────────────────────
  Widget _buildFlatCoinIcon(_CoinData coin, double size) {
    final localAsset = _coin3dAssets[coin.symbol];
    final cdnUrl = _coinLogos[coin.symbol];

    Widget coinImage;
    if (localAsset != null) {
      // Stretch horizontally to undo the ~30° Y-tilt baked into the 3D render.
      // ClipOval trims the protruding rim so only the front face shows.
      coinImage = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(1.22, 1.0),
        child: Image.asset(
          localAsset,
          fit: BoxFit.contain,
          width: size * 1.0,
          height: size * 1.0,
        ),
      );
    } else if (cdnUrl != null) {
      coinImage = CachedNetworkImage(
        imageUrl: cdnUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => _coinSymbolFallback(coin, size),
        errorWidget: (_, __, ___) => _coinSymbolFallback(coin, size),
      );
    } else {
      coinImage = _coinSymbolFallback(coin, size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: coin.primaryColor.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: coin.primaryColor.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: coin.primaryColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: ClipOval(child: coinImage),
    );
  }

  Widget _coinSymbolFallback(_CoinData coin, double size) {
    final label = coin.symbol.length > 3 ? coin.symbol.substring(0, 3) : coin.symbol;
    return Center(
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.3,
        ),
      ),
    );
  }

  // ── Light-theme coin card (used in bottom white section) ──────────────────
  Widget _buildCoinCardLight(_CoinData coin) {
    final priceStr = coin.price >= 1000
        ? '\$${(coin.price / 1000).toStringAsFixed(1)}k'
        : coin.price >= 1
            ? '\$${coin.price.toStringAsFixed(coin.price < 10 ? 2 : 1)}'
            : '\$${coin.price.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: coin.primaryColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFlatCoinIcon(coin, 72),
            const SizedBox(height: 10),
            Text(
              coin.symbol,
              style: const TextStyle(
                color: Color(0xFF12122A),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              coin.name,
              style: const TextStyle(color: Color(0xFF888899), fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  priceStr,
                  style: const TextStyle(
                    color: Color(0xFF12122A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: coin.isPositive
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${coin.isPositive ? '+' : '-'}${coin.change.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: coin.isPositive
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Light-theme watchlist item ────────────────────────────────────────────
  Widget _buildWatchlistItemLight(CryptoAsset asset, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0EE), width: 1),
            ),
            child: ClipOval(
              child: _coinLogos.containsKey(asset.symbol)
                  ? CachedNetworkImage(
                      imageUrl: _coinLogos[asset.symbol]!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Icon(
                        _getCryptoIcon(asset.symbol),
                        color: const Color(0xFF4A4A6A),
                        size: 20,
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        _getCryptoIcon(asset.symbol),
                        color: const Color(0xFF4A4A6A),
                        size: 20,
                      ),
                    )
                  : Icon(
                      _getCryptoIcon(asset.symbol),
                      color: const Color(0xFF4A4A6A),
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    color: Color(0xFF12122A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  asset.symbol,
                  style: const TextStyle(
                    color: Color(0xFF888899),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${asset.price.toStringAsFixed(2)}k',
                style: const TextStyle(
                  color: Color(0xFF12122A),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${asset.isPositive ? '+' : ''}${asset.change.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: asset.isPositive
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Coin detail bottom sheet ────────────────────────────────────────────────
  void _showCoinDetail(BuildContext context, _CoinData coin) {
    final priceStr = coin.price >= 1000
        ? '\$${(coin.price / 1000).toStringAsFixed(1)}k'
        : coin.price >= 1
            ? '\$${coin.price.toStringAsFixed(coin.price < 10 ? 2 : 1)}'
            : '\$${coin.price.toStringAsFixed(2)}';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Coin icon + name row
            Row(
              children: [
                _buildFlatCoinIcon(coin, 56),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coin.symbol,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      priceStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: coin.isPositive
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${coin.isPositive ? '+' : '-'}${coin.change.toStringAsFixed(1)}% 24h',
                        style: TextStyle(
                          color: coin.isPositive ? const Color(0xFF10B981) : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Buy / Sell buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyBtcPage()),
                      );
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Buy',
                        style: TextStyle(
                          color: Color(0xFF0D0D1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SellBtcPage()),
                      );
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Sell',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletBox({
    required String label,
    required String value,
    required String sublabel,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.25), size: 12),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(sublabel,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  IconData _getCryptoIcon(String symbol) {
    switch (symbol) {
      case 'BTC':
        return Icons.currency_bitcoin;
      case 'ETH':
        return Icons.diamond;
      case 'SOL':
        return Icons.wb_sunny;
      default:
        return Icons.currency_bitcoin;
    }
  }
}

class CryptoAsset {
  final String name;
  final String symbol;
  final double price;
  final double change;
  final bool isPositive;

  CryptoAsset({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
  });
}

class PortfolioChartPainter extends CustomPainter {
  final bool isSmallScreen;

  PortfolioChartPainter({required this.isSmallScreen});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - (isSmallScreen ? 8 : 10);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSmallScreen ? 6 : 8;

    // Draw colored segments to match the image exactly
    // Yellow-green segment (largest - top right)
    paint.color = const Color(0xFFBEF264); // Light green-yellow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.2,
      2.0,
      false,
      paint,
    );

    // Orange segment (medium - right)
    paint.color = const Color(0xFFF59E0B); // Bright orange
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.8,
      1.5,
      false,
      paint,
    );

    // Purple segment (smallest - bottom)
    paint.color = const Color(0xFF8B5CF6); // Purple
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.3,
      1.0,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniChartPainter extends CustomPainter {
  final bool isPositive;

  MiniChartPainter({required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isPositive ? const Color(0xFF10B981) : Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();

    // Simple zigzag pattern
    if (isPositive) {
      path.moveTo(0, size.height);
      path.lineTo(size.width * 0.3, size.height * 0.7);
      path.lineTo(size.width * 0.6, size.height * 0.4);
      path.lineTo(size.width, size.height * 0.1);
    } else {
      path.moveTo(0, size.height * 0.3);
      path.lineTo(size.width * 0.3, size.height * 0.5);
      path.lineTo(size.width * 0.6, size.height * 0.8);
      path.lineTo(size.width, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

