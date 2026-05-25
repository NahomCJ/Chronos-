import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'nft_detail_page.dart';
import 'nft_collections_page.dart';
import '../portfolio/nft_portfolio_page.dart';

class NftMarketplacePage extends StatefulWidget {
  const NftMarketplacePage({super.key});

  @override
  State<NftMarketplacePage> createState() => _NftMarketplacePageState();
}

class _NftMarketplacePageState extends State<NftMarketplacePage> {
  String _selectedFilter = 'All';
  String _volumePeriod = '24h';

  final _filters = ['All', 'Art', 'Collectibles', 'Music'];

  static const _nftImages = [
    'assets/Chromatic Dreams.png',
    'assets/Geometric Visions.png',
    'assets/Abstract Dimensions.png',
    'assets/MarketplaceHome.png',
    'assets/MarketplaceHome1.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── White top: header + featured card ────────────────────────
            Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _buildFeaturedCard(),
                    ),
                  ],
                ),
              ),
            ),
            // ── Dark section: filters + content ───────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildFilterTabs(),
                    const SizedBox(height: 22),
                    if (_selectedFilter == 'Collectibles') ...[
                      _buildTrendingCollectibles(),
                      const SizedBox(height: 22),
                      _buildPantherInsightCard(),
                      const SizedBox(height: 22),
                      _buildNewDropsCollectibles(),
                    ] else ...[
                      _buildTrendingCollections(),
                      const SizedBox(height: 22),
                      _buildTopVolume(),
                      const SizedBox(height: 22),
                      _buildNewDrops(),
                    ],
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 90,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.menu, color: Colors.grey[700], size: 24),
          Expanded(
            child: Column(
              children: [
                Text(
                  'BlockHub NFTs',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Discover curated digital assets',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NftPortfolioPage()),
                ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline,
                color: Colors.grey[700],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    final isCollectibles = _selectedFilter == 'Collectibles';
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.08),
        image: DecorationImage(
          image: AssetImage(
            isCollectibles
                ? 'assets/Abstract Dimensions.png'
                : 'assets/Chromatic Dreams.png',
          ),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isCollectibles
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Featured',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Text(
              isCollectibles ? 'Abstract Dimensions' : 'Chromatic Dreams',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isCollectibles
                  ? '3D rendered abstract collectibles'
                  : 'Abstract digital art exploring color and form',
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Floor: ',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  isCollectibles ? '0.95 ETH' : '2.5 ETH',
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFF00D4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isCollectibles ? '+8.1%' : '+12.4%',
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFF22C55E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tune,
                color: Colors.white.withValues(alpha: 0.7),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Filters',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _filters.map((f) {
                    final selected = _selectedFilter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          f,
                          style: TextStyles.bodySmall.copyWith(
                            color:
                                selected
                                    ? Colors.black
                                    : Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── ALL tab content ──────────────────────────────────────────────────────

  Widget _buildTrendingCollections() {
    final collections = [
      _NftCollection('Ces', '3.5 ETH', '-23.1%', 'assets/Chromatic Dreams.png'),
      _NftCollection(
        'Cyber Punks Elite',
        '5.8 ETH',
        '-3.2%',
        'assets/Geometric Visions.png',
      ),
      _NftCollection(
        'Digital...',
        '2.1 ETH',
        '+8.4%',
        'assets/Abstract Dimensions.png',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(0xFFB366FF),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Trending Collections',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NftCollectionsPage(),
                    ),
                  ),
              child: Text(
                'View All',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFFB366FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: collections.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _buildTrendingCard(collections[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(_NftCollection c) {
    final isPositive = c.change.startsWith('+');
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  c.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder:
                      (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 32,
                        ),
                      ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Floor: ${c.floor}',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
                Text(
                  c.change,
                  style: TextStyles.bodySmall.copyWith(
                    color:
                        isPositive
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopVolume() {
    final items = [
      _TopVolumeItem(
        1,
        'Geometric Vision',
        '1.8 ETH',
        '2,100',
        '890 ETH',
        '-3.2%',
      ),
      _TopVolumeItem(
        2,
        'Holographic Future',
        '3.2 ETH',
        '1,850',
        '2100 ETH',
        '+24.8%',
      ),
      _TopVolumeItem(
        3,
        'Abstract Dimension',
        '0.95 ETH',
        '4,200',
        '450 ETH',
        '+8.1%',
      ),
      _TopVolumeItem(
        4,
        'Crypto Punks Legacy',
        '5.2 ETH',
        '1,290',
        '3500 ETH',
        '+15.7%',
      ),
      _TopVolumeItem(5, 'Neon Beats', '1.5 ETH', '2,800', '880 ETH', '+9.3%'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Volume',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Row(
              children:
                  ['24h', '7d'].map((p) {
                    final sel = _volumePeriod == p;
                    return GestureDetector(
                      onTap: () => setState(() => _volumePeriod = p),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              sel
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p,
                          style: TextStyles.bodySmall.copyWith(
                            color:
                                sel
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              ...items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(
                  children: [
                    _buildVolumeRow(e.value),
                    if (!isLast)
                      Divider(
                        color: Colors.white.withValues(alpha: 0.06),
                        height: 1,
                        thickness: 0.5,
                        indent: 14,
                        endIndent: 14,
                      ),
                  ],
                );
              }),
              _buildPantherInsightCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeRow(_TopVolumeItem item) {
    final isPositive = item.change.startsWith('+');
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NftDetailPage()),
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              child: Text(
                '${item.rank}',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                _nftImages[item.rank % _nftImages.length],
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 20,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF3B82F6),
                        size: 13,
                      ),
                    ],
                  ),
                  Text(
                    'Floor: ${item.floor}  ${item.owners} owners',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'Vol: ${item.volume}',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              item.change,
              style: TextStyles.bodySmall.copyWith(
                color:
                    isPositive
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewDrops() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Drops',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropCard(
                'Chromatic Dreams',
                '2.5 ETH',
                'assets/Chromatic Dreams.png',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropCard(
                'Geometric Visions',
                '1.8 ETH',
                'assets/Geometric Visions.png',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropCard(String name, String price, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 130,
                  errorBuilder:
                      (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.white.withValues(alpha: 0.25),
                          size: 40,
                        ),
                      ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'NEW',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          price,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ── COLLECTIBLES tab content ─────────────────────────────────────────────

  Widget _buildTrendingCollectibles() {
    final items = [
      _TopVolumeItem(
        5,
        'Crypto Punks Legacy',
        '5.2 ETH',
        '1,200',
        '3500 ETH',
        '+15.7%',
      ),
      _TopVolumeItem(
        10,
        'Rare Collectible Cards',
        '1.2 ETH',
        '3,800',
        '560 ETH',
        '+5.8%',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(0xFFDC8F4A),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Trending in Collectibles',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              'View All',
              style: TextStyles.bodySmall.copyWith(
                color: const Color(0xFFB366FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children:
                items.asMap().entries.map((e) {
                  final isLast = e.key == items.length - 1;
                  return Column(
                    children: [
                      _buildCollectibleRow(e.value),
                      if (!isLast)
                        Divider(
                          color: Colors.white.withValues(alpha: 0.06),
                          height: 1,
                          thickness: 0.5,
                          indent: 14,
                          endIndent: 14,
                        ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectibleRow(_TopVolumeItem item) {
    final isPositive = item.change.startsWith('+');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 24,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${item.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF3B82F6),
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Floor: ${item.floor}  ${item.owners} owners',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Vol: ${item.volume}  ',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.change,
            style: TextStyles.bodySmall.copyWith(
              color:
                  isPositive
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewDropsCollectibles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Drops',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildImageDropCard(
                'Abstract Dimensions',
                '0.95 ETH',
                'assets/Abstract Dimensions.png',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImageDropCard(
                'Crypto Punks Legacy',
                '5.2 ETH',
                'assets/Geometric Visions.png',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageDropCard(String name, String price, String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
            ),
          ),
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'NEW',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  price,
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFF00D4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPantherInsightCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0B100).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF0B100).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF0B100),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panther Insight',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'The Geometric Visions collection shows higher than average wash-trade activity. Exercise caution.',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NftCollection {
  final String name, floor, change, imagePath;
  _NftCollection(this.name, this.floor, this.change, this.imagePath);
}

class _TopVolumeItem {
  final int rank;
  final String name, floor, owners, volume, change;
  _TopVolumeItem(
    this.rank,
    this.name,
    this.floor,
    this.owners,
    this.volume,
    this.change,
  );
}
