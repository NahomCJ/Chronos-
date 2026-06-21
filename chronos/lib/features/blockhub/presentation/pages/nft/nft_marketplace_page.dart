import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_constants.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/widgets/chris_home_fab.dart';
import '../../../../../core/widgets/custom_bottom_nav.dart';
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

  // Pexels digital/abstract art for NFT images
  static const _nftImages = [
    'https://images.pexels.com/photos/5816299/pexels-photo-5816299.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/3109807/pexels-photo-3109807.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/2110951/pexels-photo-2110951.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/7130498/pexels-photo-7130498.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1183992/pexels-photo-1183992.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/3617500/pexels-photo-3617500.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 2,
        onItemSelected: (i) {
          switch (i) {
            case 0: context.go(RouteConstants.home.toPath);
            case 1: context.go(RouteConstants.pantherAi.toPath);
            case 2: context.go(RouteConstants.blockHub.toPath);
            case 3: context.go(RouteConstants.lifex.toPath);
          }
        },
      ),
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
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: const AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.15), BlendMode.darken),
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
          image: NetworkImage(
            isCollectibles
                ? 'https://images.pexels.com/photos/7130498/pexels-photo-7130498.jpeg?auto=compress&cs=tinysrgb&w=600'
                : 'https://images.pexels.com/photos/5816299/pexels-photo-5816299.jpeg?auto=compress&cs=tinysrgb&w=600',
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
              isCollectibles ? 'Azuki Collection' : 'Bored Ape Yacht Club',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isCollectibles
                  ? 'Anime-inspired NFT collection by CHIRU LABS'
                  : '10,000 unique ape NFTs on the Ethereum blockchain',
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
      _NftCollection('BAYC', '68.5 ETH', '+12.1%', _nftImages[0]),
      _NftCollection('Azuki', '14.2 ETH', '+7.4%', _nftImages[1]),
      _NftCollection('Doodles', '5.8 ETH', '+3.2%', _nftImages[2]),
      _NftCollection('CloneX', '3.1 ETH', '-2.8%', _nftImages[3]),
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
                child: Image.network(
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
      _TopVolumeItem(1, 'Bored Ape YC', '68.5 ETH', '5,966', '14,200 ETH', '+12.1%'),
      _TopVolumeItem(2, 'CryptoPunks', '49.3 ETH', '3,750', '8,900 ETH', '+5.4%'),
      _TopVolumeItem(3, 'Azuki', '14.2 ETH', '8,690', '3,100 ETH', '+18.7%'),
      _TopVolumeItem(4, 'Doodles', '5.8 ETH', '9,890', '920 ETH', '+3.2%'),
      _TopVolumeItem(5, 'Moonbirds', '4.1 ETH', '10,000', '650 ETH', '+7.9%'),
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
              child: Image.network(
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
            Expanded(child: _buildDropCard('CloneX #13295', '3.1 ETH', _nftImages[4])),
            const SizedBox(width: 12),
            Expanded(child: _buildDropCard('Pudgy Penguins', '6.4 ETH', _nftImages[5])),
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
                child: Image.network(
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
      _TopVolumeItem(1, 'Azuki #9605', '14.2 ETH', '8,690', '3,100 ETH', '+18.7%'),
      _TopVolumeItem(2, 'Doodles #6914', '5.8 ETH', '9,890', '920 ETH', '+3.2%'),
      _TopVolumeItem(3, 'Moonbirds #2647', '4.1 ETH', '10,000', '650 ETH', '+7.9%'),
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
            Expanded(child: _buildImageDropCard('World of Women', '2.1 ETH', _nftImages[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildImageDropCard('Meebits #18392', '1.8 ETH', _nftImages[3])),
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
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white.withValues(alpha: 0.08),
                child: Center(child: Icon(Icons.image_outlined, color: Colors.white38, size: 32)),
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
