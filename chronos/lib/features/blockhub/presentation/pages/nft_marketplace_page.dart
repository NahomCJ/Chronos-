import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/services/pexels_service.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import 'nft/nft_collections_page.dart';
import 'nft/nft_detail_page.dart';

// Static fallback if the live Pexels search returns nothing (offline, API
// hiccup) — distinct photo IDs so cards still look different from each
// other rather than all showing the same placeholder.
const _kFallbackNftPhotoIds = [
  1103970, 3861458, 2681319, 1591447, 3308588, 3078831,
  1509534, 2387793, 1054218, 1287145,
];

class NftMarketplacePage extends StatefulWidget {
  const NftMarketplacePage({super.key});

  @override
  State<NftMarketplacePage> createState() => _NftMarketplacePageState();
}

class _NftMarketplacePageState extends State<NftMarketplacePage> {
  String _selectedFilter = 'All';
  String _volumePeriod = '24h';
  List<PexelsPhoto> _photos = [];

  final _filters = ['All', 'Art', 'Collectibles', 'Music'];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final photos = await PexelsService.searchPhotos(
      'abstract digital art',
      perPage: 20,
    );
    if (mounted && photos.isNotEmpty) setState(() => _photos = photos);
  }

  /// A distinct image URL for NFT slot [index] — pulled from the live
  /// Pexels search when available, otherwise a static fallback so every
  /// slot still gets a different picture instead of a blank/reused one.
  String _photoUrl(int index) {
    if (_photos.isNotEmpty) {
      return _photos[index % _photos.length].large;
    }
    final id = _kFallbackNftPhotoIds[index % _kFallbackNftPhotoIds.length];
    return PexelsService.photoUrl(id, w: 600, h: 600);
  }

  void _openDetail(
    BuildContext context, {
    required String name,
    required String collection,
    required String price,
    required int imageIndex,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NftDetailPage(
          tokenName: name,
          collection: collection,
          priceEth: price,
          imageUrl: _photoUrl(imageIndex),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080F),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 2,
        onItemSelected: (i) {
          switch (i) {
            case 0: context.go(RouteConstants.home.toPath); break;
            case 1: context.go(RouteConstants.pantherAi.toPath); break;
            case 2: context.go(RouteConstants.blockHub.toPath); break;
            case 3: context.go(RouteConstants.lifex.toPath); break;
          }
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF1A2A3A)),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.20)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildFeaturedCard(),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'BlockHub NFTs',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Discover curated digital assets',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard() {
    final isCollectibles = _selectedFilter == 'Collectibles';
    final name = isCollectibles ? 'Abstract Dimensions' : 'Chromatic Dreams';
    final price = isCollectibles ? '0.95 ETH' : '2.5 ETH';
    final imageIndex = isCollectibles ? 1 : 0;
    return _TapScale(
      onTap: () => _openDetail(context,
          name: name,
          collection: 'Featured',
          price: price,
          imageIndex: imageIndex),
      child: Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.08),
        image: DecorationImage(
          image: NetworkImage(_photoUrl(imageIndex)),
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
      _NftCollection('Ces', '3.5 ETH', '-23.1%'),
      _NftCollection('Cyber Punks Elite', '5.8 ETH', '-3.2%'),
      _NftCollection('Digital...', '2.1 ETH', '+8.4%'),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NftCollectionsPage()),
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
            itemBuilder: (context, i) => _TapScale(
              onTap: () => _openDetail(context,
                  name: collections[i].name,
                  collection: collections[i].name,
                  price: collections[i].floor,
                  imageIndex: 2 + i),
              child: _buildTrendingCard(collections[i], 2 + i),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(_NftCollection c, int imageIndex) {
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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                color: Colors.white.withValues(alpha: 0.1),
                child: Image.network(
                  _photoUrl(imageIndex),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_outlined,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 32,
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
                    _buildVolumeRow(e.value, 5 + e.key),
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

  Widget _buildVolumeRow(_TopVolumeItem item, int imageIndex) {
    final isPositive = item.change.startsWith('+');
    return GestureDetector(
      onTap: () => _openDetail(context,
          name: item.name,
          collection: item.name,
          price: item.floor,
          imageIndex: imageIndex),
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
          ClipOval(
            child: Container(
              width: 40,
              height: 40,
              color: Colors.white.withValues(alpha: 0.1),
              child: Image.network(
                _photoUrl(imageIndex),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
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
              child: _TapScale(
                onTap: () => _openDetail(context,
                    name: 'Chromatic Dreams',
                    collection: 'New Drops',
                    price: '2.5 ETH',
                    imageIndex: 10),
                child: _buildDropCard('Chromatic Dreams', '2.5 ETH', 10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TapScale(
                onTap: () => _openDetail(context,
                    name: 'Geometric Visions',
                    collection: 'New Drops',
                    price: '1.8 ETH',
                    imageIndex: 11),
                child: _buildDropCard('Geometric Visions', '1.8 ETH', 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropCard(String name, String price, int imageIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Image.network(
                  _photoUrl(imageIndex),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_outlined,
                    color: Colors.white.withValues(alpha: 0.25),
                    size: 40,
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
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NftCollectionsPage()),
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
                      _buildCollectibleRow(e.value, 12 + e.key),
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

  Widget _buildCollectibleRow(_TopVolumeItem item, int imageIndex) {
    final isPositive = item.change.startsWith('+');
    return GestureDetector(
      onTap: () => _openDetail(context,
          name: item.name,
          collection: item.name,
          price: item.floor,
          imageIndex: imageIndex),
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Stack(
            children: [
              ClipOval(
                child: Container(
                  width: 52,
                  height: 52,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: Image.network(
                    _photoUrl(imageIndex),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_outlined,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 24,
                    ),
                  ),
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
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF08080F), width: 1.5),
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
              child: _TapScale(
                onTap: () => _openDetail(context,
                    name: 'Abstract Dimensions',
                    collection: 'New Drops',
                    price: '0.95 ETH',
                    imageIndex: 14),
                child: _buildImageDropCard('Abstract Dimensions', '0.95 ETH', 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TapScale(
                onTap: () => _openDetail(context,
                    name: 'Crypto Punks Legacy',
                    collection: 'New Drops',
                    price: '5.2 ETH',
                    imageIndex: 15),
                child: _buildImageDropCard('Crypto Punks Legacy', '5.2 ETH', 15),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageDropCard(String name, String price, int imageIndex) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              image: DecorationImage(
                image: NetworkImage(_photoUrl(imageIndex)),
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
  final String name, floor, change;
  _NftCollection(this.name, this.floor, this.change);
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

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _TapScale({required this.child, this.onTap});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
