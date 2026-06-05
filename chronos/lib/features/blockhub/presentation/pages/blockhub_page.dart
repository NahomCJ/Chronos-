import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/text_theme.dart';
import 'buy/buy_btc_page.dart';
import 'bitcoin_detail_page.dart';
import '../widgets/more_options_modal.dart';
import 'onboarding/blockhub_welcome_page.dart';
import 'onboarding/setup_wallet_page.dart';

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
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          // Background Image (only visible in dark sections)
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          // White overlay for top section (covers status bar + header + portfolio)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).padding.top,
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // White background container for all content including header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        // Header (now with white background)
                        Padding(
                          padding: EdgeInsets.all(horizontalPadding),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu,
                                color: Colors.grey[700],
                                size: 24,
                              ),
                              const Spacer(),
                              Text(
                                'BlockHub',
                                style: TextStyles.titleLarge.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 20 : 24,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 10 : 16),

                        // Portfolio Card
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          padding: EdgeInsets.only(
                            top: isSmallScreen ? 20 : 24,
                            left: isSmallScreen ? 20 : 24,
                            right: isSmallScreen ? 20 : 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Total Portfolio Value',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.visibility_outlined,
                                    color: Colors.grey[700],
                                    size: 26,
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              Column(
                                children: [
                                  Text(
                                    '\$24,521.83',
                                    style: TextStyles.headlineLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 28 : 32,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 6 : 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 6 : 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '24H Change: +\$2,521.83 (+11.6%)',
                                      style: TextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF10B981),
                                        fontWeight: FontWeight.w600,
                                        fontSize: isSmallScreen ? 10 : 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Portfolio Chart
                              Image.asset(
                                'assets/Frame blochub.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 24),

                        // Action Buttons
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(
                                Icons.add,
                                'Buy',
                                isSmallScreen,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BuyBtcPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildActionButton(
                                Icons.trending_down,
                                'Sell',
                                isSmallScreen,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const BitcoinDetailPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildActionButton(
                                Icons.swap_horiz,
                                'Swap',
                                isSmallScreen,
                              ),
                              _buildActionButton(
                                Icons.send,
                                'Send',
                                isSmallScreen,
                              ),
                              _buildActionButton(
                                Icons.more_horiz,
                                'More',
                                isSmallScreen,
                                onTap: () {
                                  MoreOptionsModal.show(context);
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 28 : 32),
                      ],
                    ),
                  ),

                  // Top Movers Section - Full Width Dark Container
                  Container(
                    width: double.infinity, // edge-to-edge
                    margin: EdgeInsets.zero, // No margin for full width
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Movers',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),

                        // Horizontal coin slideshow
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.72),
                            itemCount: _coins.length,
                            itemBuilder: (context, index) {
                              final coin = _coins[index];
                              return GestureDetector(
                                onTap: () => _showCoinDetail(context, coin),
                                child: _buildCoinCard(coin),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 12 : 16),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Watchlist Section (keeping dark theme)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      // Darker background to match image
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Watchlist',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),

                        ..._watchlist.map(
                          (asset) => _buildWatchlistItem(asset, isSmallScreen),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
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
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Icon(
              icon,
              color: Colors.grey[700],
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.grey[600],
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── 3-D coin card ──────────────────────────────────────────────────────────
  Widget _buildCoinCard(_CoinData coin) {
    final priceStr = coin.price >= 1000
        ? '\$${(coin.price / 1000).toStringAsFixed(1)}k'
        : coin.price >= 1
            ? '\$${coin.price.toStringAsFixed(coin.price < 10 ? 2 : 1)}'
            : '\$${coin.price.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: coin.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3-D coin
            CustomPaint(
              size: const Size(90, 90),
              painter: _CoinPainter(coin: coin),
            ),
            const SizedBox(height: 10),
            // Symbol
            Text(
              coin.symbol,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              coin.name,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            // Price row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  priceStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: coin.isPositive
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${coin.isPositive ? '+' : '-'}${coin.change.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: coin.isPositive ? const Color(0xFF10B981) : Colors.red,
                      fontWeight: FontWeight.w600,
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
                CustomPaint(
                  size: const Size(56, 56),
                  painter: _CoinPainter(coin: coin),
                ),
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
                        gradient: LinearGradient(
                          colors: [coin.primaryColor, coin.secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Buy',
                        style: TextStyle(
                          color: Colors.white,
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
                        MaterialPageRoute(builder: (_) => const BitcoinDetailPage()),
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

  Widget _buildWatchlistItem(CryptoAsset asset, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Crypto Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(
              _getCryptoIcon(asset.symbol),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Name and Symbol
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asset.symbol,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Price and Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${asset.price.toStringAsFixed(2)}k',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${asset.isPositive ? '+' : ''}${asset.change.toStringAsFixed(2)}%',
                style: TextStyles.bodySmall.copyWith(
                  color:
                      asset.isPositive ? const Color(0xFF10B981) : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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

// ── 3-D coin painter ──────────────────────────────────────────────────────────
class _CoinPainter extends CustomPainter {
  final _CoinData coin;
  const _CoinPainter({required this.coin});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 4;

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.15), width: r * 1.6, height: r * 0.45),
      shadowPaint,
    );

    // Base fill — radial gradient: primary center → secondary → dark edge
    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.35),
        radius: 1.1,
        colors: [
          Color.lerp(coin.primaryColor, Colors.white, 0.25)!,
          coin.primaryColor,
          coin.secondaryColor,
          Color.lerp(coin.secondaryColor, Colors.black, 0.55)!,
        ],
        stops: const [0.0, 0.35, 0.72, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, basePaint);

    // Depth ring — dark border gradient
    final ringPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.15),
          Colors.black.withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.35),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08;
    canvas.drawCircle(Offset(cx, cy), r - r * 0.04, ringPaint);

    // Metallic shine — upper-left oval highlight
    final shinePath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx - r * 0.22, cy - r * 0.28),
          width: r * 0.85,
          height: r * 0.42,
        ),
      );
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          Colors.white.withValues(alpha: 0.62),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(cx - r * 0.22, cy - r * 0.28),
          width: r * 0.85,
          height: r * 0.42,
        ),
      );
    canvas.drawPath(shinePath, shinePaint);
    canvas.restore();

    // Symbol text
    final tp = TextPainter(
      text: TextSpan(
        text: coin.symbol.length > 3 ? coin.symbol.substring(0, 3) : coin.symbol,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: r * (coin.symbol.length <= 2 ? 0.48 : 0.36),
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CoinPainter old) => old.coin != coin;
}
