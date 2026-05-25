import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';

class TrendingAssetsPage extends StatefulWidget {
  const TrendingAssetsPage({super.key});

  @override
  State<TrendingAssetsPage> createState() => _TrendingAssetsPageState();
}

class _TrendingAssetsPageState extends State<TrendingAssetsPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<TrendingAsset> _trendingAssets = [
    TrendingAsset(
      name: 'Avalanche',
      symbol: 'AVAX',
      price: 38.7,
      change: 8.4,
      isPositive: true,
      color: const Color(0xFFE84142),
      iconLetter: 'A',
    ),
    TrendingAsset(
      name: 'Polygon',
      symbol: 'MATIC',
      price: 0.92,
      change: 6.7,
      isPositive: true,
      color: const Color(0xFF8247E5),
      iconLetter: 'P',
    ),
    TrendingAsset(
      name: 'Bitcoin',
      symbol: 'BTC',
      price: 64250,
      change: 5.2,
      isPositive: true,
      color: const Color(0xFFF59E0B),
      iconLetter: 'B',
      isFavorite: true,
    ),
    TrendingAsset(
      name: 'Chainlink',
      symbol: 'LINK',
      price: 15.84,
      change: 4.2,
      isPositive: true,
      color: const Color(0xFF2A5ADA),
      iconLetter: 'C',
    ),
    TrendingAsset(
      name: 'Ethereum',
      symbol: 'ETH',
      price: 3420.5,
      change: 3.8,
      isPositive: true,
      color: const Color(0xFF3B82F6),
      iconLetter: 'E',
      isFavorite: true,
    ),
    TrendingAsset(
      name: 'Polkadot',
      symbol: 'DOT',
      price: 7.32,
      change: -3.6,
      isPositive: false,
      color: const Color(0xFFE6007A),
      iconLetter: 'P',
    ),
    TrendingAsset(
      name: 'Tesla Inc.',
      symbol: 'tTSLA',
      price: 242.84,
      change: -2.3,
      isPositive: false,
      color: const Color(0xFF6366F1),
      iconLetter: 'T',
      isAMC: true,
    ),
    TrendingAsset(
      name: 'Solana',
      symbol: 'SOL',
      price: 145.3,
      change: -5.3,
      isPositive: false,
      color: const Color(0xFF9945FF),
      iconLetter: 'S',
    ),
    TrendingAsset(
      name: 'Cardano',
      symbol: 'ADA',
      price: 0.625,
      change: 1.5,
      isPositive: true,
      color: const Color(0xFF0033AD),
      iconLetter: 'A',
    ),
    TrendingAsset(
      name: 'S&P 500 ETF',
      symbol: 'ADA',
      price: 485.23,
      change: 1.5,
      isPositive: true,
      color: const Color(0xFF6366F1),
      iconLetter: 'S',
      isAMC: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

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

                      // Asset Count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_trendingAssets.length} trending assets',
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Asset List
                      Expanded(child: _buildAssetList(isSmallScreen)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Trending Assets',
                    style: TextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 18 : 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Most searched today',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              ),
            ],
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
            hintText: 'Search trending assets...',
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

  Widget _buildAssetList(bool isSmallScreen) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _trendingAssets.length,
      itemBuilder: (context, index) {
        return _buildAssetItem(_trendingAssets[index], isSmallScreen);
      },
    );
  }

  Widget _buildAssetItem(TrendingAsset asset, bool isSmallScreen) {
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
                Row(
                  children: [
                    Text(
                      asset.name,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                    if (asset.isFavorite) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFF59E0B),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      asset.symbol,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: isSmallScreen ? 10 : 11,
                      ),
                    ),
                    if (asset.isAMC) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AMC',
                          style: TextStyles.bodySmall.copyWith(
                            color: const Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                '\$${asset.price < 1 ? asset.price.toStringAsFixed(3) : asset.price.toStringAsFixed(asset.price > 1000 ? 0 : 1)}',
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

class TrendingAsset {
  final String name;
  final String symbol;
  final double price;
  final double change;
  final bool isPositive;
  bool isFavorite;
  final Color color;
  final String iconLetter;
  final bool isAMC;

  TrendingAsset({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
    this.isFavorite = false,
    required this.color,
    required this.iconLetter,
    this.isAMC = false,
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
