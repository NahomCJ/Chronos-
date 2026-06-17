import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';

class TopLosersPage extends StatefulWidget {
  const TopLosersPage({super.key});

  @override
  State<TopLosersPage> createState() => _TopLosersPageState();
}

class _TopLosersPageState extends State<TopLosersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<LoserAsset> _loserAssets = [
    LoserAsset(
      name: 'Polkadot',
      symbol: 'DOT',
      price: 7.32,
      change: -3.6,
      color: const Color(0xFFE6007A),
      iconLetter: 'P',
    ),
    LoserAsset(
      name: 'Tesla Inc.',
      symbol: 'tTSLA',
      price: 64250,
      change: -5.2,
      color: const Color(0xFF6366F1),
      iconLetter: 'B',
      isAMC: true,
    ),
    LoserAsset(
      name: 'Solana',
      symbol: 'SOL',
      price: 145.3,
      change: -2.1,
      color: const Color(0xFF9945FF),
      iconLetter: 'S',
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
            child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
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

                      // Filter Tabs
                      _buildFilterTabs(isSmallScreen),

                      const SizedBox(height: 16),

                      // Asset Count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_loserAssets.length} top losers',
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Market Decliners Banner
                      _buildMarketDeclinersBanner(isSmallScreen),

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
                  const Icon(
                    Icons.trending_down,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Top Losers',
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
                '24h performance decliners',
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
            hintText: 'Search top gainers...',
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

  Widget _buildFilterTabs(bool isSmallScreen) {
    final filters = ['All', 'Crypto', 'AMC'];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.red
                          : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.red
                            : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyles.bodySmall.copyWith(
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketDeclinersBanner(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Market Decliners',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '3 assets with negative 24h performance',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: isSmallScreen ? 10 : 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetList(bool isSmallScreen) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _loserAssets.length,
      itemBuilder: (context, index) {
        return _buildAssetItem(_loserAssets[index], isSmallScreen);
      },
    );
  }

  Widget _buildAssetItem(LoserAsset asset, bool isSmallScreen) {
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
              painter: MiniSparklinePainter(
                isPositive: false, // All losers have negative charts
              ),
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
                '${asset.change.toStringAsFixed(1)}%',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.red,
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

class LoserAsset {
  final String name;
  final String symbol;
  final double price;
  final double change;
  bool isFavorite;
  final Color color;
  final String iconLetter;
  final bool isAMC;

  LoserAsset({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
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
