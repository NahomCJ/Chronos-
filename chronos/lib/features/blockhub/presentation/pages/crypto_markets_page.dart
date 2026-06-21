import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/text_theme.dart';
import '../bloc/market/market_bloc.dart';
import '../bloc/market/market_event.dart';
import '../bloc/market/market_state.dart';

class CryptoMarketsPage extends StatefulWidget {
  const CryptoMarketsPage({super.key});

  @override
  State<CryptoMarketsPage> createState() => _CryptoMarketsPageState();
}

class _CryptoMarketsPageState extends State<CryptoMarketsPage> {
  late final MarketBloc _marketBloc;
  final String _selectedSort = 'Market cap';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _marketBloc = GetIt.I<MarketBloc>()..add(MarketPricesLoadRequested());
  }

  final List<CryptoAsset> _cryptoAssets = [
    CryptoAsset(
      name: 'Bitcoin',
      symbol: 'BTC',
      price: 64250,
      volume: 35.4,
      change: 5.2,
      isPositive: true,
      isFavorite: true,
      color: const Color(0xFFF59E0B),
      iconLetter: 'B',
    ),
    CryptoAsset(
      name: 'Ethereum',
      symbol: 'ETH',
      price: 3420.5,
      volume: 18.2,
      change: 3.8,
      isPositive: true,
      isFavorite: true,
      color: const Color(0xFF3B82F6),
      iconLetter: 'E',
    ),
    CryptoAsset(
      name: 'Solana',
      symbol: 'SOL',
      price: 145.3,
      volume: 3.2,
      change: -2.1,
      isPositive: false,
      isFavorite: false,
      color: const Color(0xFF9945FF),
      iconLetter: 'S',
    ),
    CryptoAsset(
      name: 'Cardano',
      symbol: 'ADA',
      price: 0.625,
      volume: 0.88,
      change: 1.5,
      isPositive: true,
      isFavorite: false,
      color: const Color(0xFF0033AD),
      iconLetter: 'A',
    ),
    CryptoAsset(
      name: 'Avalanche',
      symbol: 'AVAX',
      price: 38.7,
      volume: 0.9,
      change: 8.4,
      isPositive: true,
      isFavorite: false,
      color: const Color(0xFFE84142),
      iconLetter: 'A',
    ),
    CryptoAsset(
      name: 'Polkadot',
      symbol: 'DOT',
      price: 7.32,
      volume: 0.28,
      change: -3.6,
      isPositive: false,
      isFavorite: false,
      color: const Color(0xFFE6007A),
      iconLetter: 'P',
    ),
    CryptoAsset(
      name: 'Chainlink',
      symbol: 'LINK',
      price: 15.84,
      volume: 0.45,
      change: 4.2,
      isPositive: true,
      isFavorite: false,
      color: const Color(0xFF2A5ADA),
      iconLetter: 'L',
    ),
    CryptoAsset(
      name: 'Polygon',
      symbol: 'MATIC',
      price: 0.92,
      volume: 0.35,
      change: -6.7,
      isPositive: false,
      isFavorite: false,
      color: const Color(0xFF8247E5),
      iconLetter: 'P',
    ),
  ];

  @override
  void dispose() {
    _marketBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return BlocProvider.value(
      value: _marketBloc,
      child: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, marketState) {
          final livePrices =
              marketState is MarketLoaded ? marketState.prices : null;
          return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.65))),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, isSmallScreen),

                // Content
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Search Bar
                      _buildSearchBar(isSmallScreen),

                      const SizedBox(height: 16),

                      // Sort Options
                      _buildSortOptions(isSmallScreen),

                      const SizedBox(height: 16),

                      // Crypto Count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_cryptoAssets.length} cryptocurrencies',
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Crypto List
                      Expanded(child: _buildCryptoList(isSmallScreen, livePrices)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Crypto Markets',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: isSmallScreen ? 13 : 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search cryptocurrencies...',
            hintStyle: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: isSmallScreen ? 13 : 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptions(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedSort,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 12 : 13,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoList(bool isSmallScreen, Map<String, double>? livePrices) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _cryptoAssets.length,
      itemBuilder: (context, index) {
        final asset = _cryptoAssets[index];
        final livePrice = livePrices?[asset.symbol.toUpperCase()];
        return _buildCryptoItem(asset, isSmallScreen, livePrice);
      },
    );
  }

  Widget _buildCryptoItem(CryptoAsset asset, bool isSmallScreen, double? livePrice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: isSmallScreen ? 40 : 44,
            height: isSmallScreen ? 40 : 44,
            decoration: BoxDecoration(
              color: asset.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                asset.iconLetter,
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
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
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${asset.symbol} • Vol \$${asset.volume}B',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isSmallScreen ? 10 : 11,
                  ),
                ),
              ],
            ),
          ),

          // Mini Chart
          SizedBox(
            width: 60,
            height: 30,
            child: CustomPaint(
              painter: MiniSparklinePainter(isPositive: asset.isPositive),
            ),
          ),

          const SizedBox(width: 12),

          // Price and Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(livePrice ?? asset.price) < 1 ? (livePrice ?? asset.price).toStringAsFixed(3) : (livePrice ?? asset.price).toStringAsFixed(0)}',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${asset.isPositive ? '+' : ''}${asset.change.toStringAsFixed(1)}%',
                style: TextStyles.bodySmall.copyWith(
                  color:
                      asset.isPositive ? const Color(0xFF10B981) : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 10 : 11,
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Favorite Icon
          GestureDetector(
            onTap: () {
              setState(() {
                asset.isFavorite = !asset.isFavorite;
              });
            },
            child: Icon(
              asset.isFavorite ? Icons.star : Icons.star_border,
              color:
                  asset.isFavorite
                      ? const Color(0xFFF59E0B)
                      : Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class CryptoAsset {
  final String name;
  final String symbol;
  final double price;
  final double volume;
  final double change;
  final bool isPositive;
  bool isFavorite;
  final Color color;
  final String iconLetter;

  CryptoAsset({
    required this.name,
    required this.symbol,
    required this.price,
    required this.volume,
    required this.change,
    required this.isPositive,
    required this.isFavorite,
    required this.color,
    required this.iconLetter,
  });
}

class MiniSparklinePainter extends CustomPainter {
  final bool isPositive;

  MiniSparklinePainter({required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isPositive ? const Color(0xFF10B981) : Colors.red
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    final path = Path();

    if (isPositive) {
      path.moveTo(0, size.height * 0.8);
      path.lineTo(size.width * 0.2, size.height * 0.6);
      path.lineTo(size.width * 0.4, size.height * 0.7);
      path.lineTo(size.width * 0.6, size.height * 0.4);
      path.lineTo(size.width * 0.8, size.height * 0.5);
      path.lineTo(size.width, size.height * 0.2);
    } else {
      path.moveTo(0, size.height * 0.2);
      path.lineTo(size.width * 0.2, size.height * 0.4);
      path.lineTo(size.width * 0.4, size.height * 0.3);
      path.lineTo(size.width * 0.6, size.height * 0.6);
      path.lineTo(size.width * 0.8, size.height * 0.5);
      path.lineTo(size.width, size.height * 0.8);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
