import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/route_constants.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/widgets/chris_home_fab.dart';
import '../../../../../core/widgets/custom_bottom_nav.dart';
import '../../../domain/entities/blockhub_entities.dart';
import '../../bloc/nft_marketplace/nft_marketplace_bloc.dart';
import '../../bloc/nft_marketplace/nft_marketplace_event.dart';
import '../../bloc/nft_marketplace/nft_marketplace_state.dart';
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
  late final NftMarketplaceBloc _marketplaceBloc;

  final _filters = ['All', 'Art', 'Collectibles', 'Music'];

  // Pexels digital/abstract art — used only as a fallback image when a real
  // collection/NFT has no imageUrl yet.
  static const _nftImages = [
    'https://images.pexels.com/photos/5816299/pexels-photo-5816299.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/3109807/pexels-photo-3109807.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/2110951/pexels-photo-2110951.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/7130498/pexels-photo-7130498.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1183992/pexels-photo-1183992.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/3617500/pexels-photo-3617500.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  String? get _categoryParam => switch (_selectedFilter) {
        'Art' => 'ART',
        'Collectibles' => 'COLLECTIBLES',
        'Music' => 'MUSIC',
        _ => null,
      };

  @override
  void initState() {
    super.initState();
    _marketplaceBloc = GetIt.I<NftMarketplaceBloc>()
      ..add(NftMarketplaceLoadRequested(category: _categoryParam));
  }

  @override
  void dispose() {
    _marketplaceBloc.close();
    super.dispose();
  }

  void _selectFilter(String filter) {
    setState(() => _selectedFilter = filter);
    _marketplaceBloc.add(NftMarketplaceLoadRequested(category: _categoryParam));
  }

  String _fmtEth(double v) => '${v.toStringAsFixed(2)} ETH';
  String _fmtChange(double pct) =>
      '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';

  void _openDetail(
    BuildContext context, {
    required String name,
    required String collection,
    required String price,
    required String imageUrl,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NftDetailPage(
          tokenName: name,
          collection: collection,
          priceEth: price,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _marketplaceBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080F),
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
                    child: BlocBuilder<NftMarketplaceBloc, NftMarketplaceState>(
                      builder: (context, state) {
                        if (state is NftMarketplaceLoading ||
                            state is NftMarketplaceInitial) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFB366FF),
                            ),
                          );
                        }
                        final loaded =
                            state is NftMarketplaceLoaded && !state.isEmpty
                                ? state
                                : null;
                        return _buildContent(loaded);
                      },
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

  Widget _buildContent(NftMarketplaceLoaded? loaded) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildFeaturedCard(loaded?.featured),
          const SizedBox(height: 16),
          _buildFilterTabs(),
          const SizedBox(height: 22),
          if (_selectedFilter == 'Collectibles') ...[
            _buildTrendingCollectibles(loaded?.trending),
            const SizedBox(height: 22),
            _buildNewDropsCollectibles(loaded?.newDrops),
          ] else ...[
            _buildTrendingCollections(loaded?.trending),
            const SizedBox(height: 22),
            _buildTopVolume(loaded?.topVolume),
            const SizedBox(height: 22),
            _buildNewDrops(loaded?.newDrops),
          ],
          const SizedBox(height: 40),
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
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NftPortfolioPage()),
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pie_chart_outline,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(NftCollection? featured) {
    final isCollectibles = _selectedFilter == 'Collectibles';
    final name = featured?.name ??
        (isCollectibles ? 'Abstract Dimensions' : 'Chromatic Dreams');
    final description = featured?.description ??
        (isCollectibles
            ? '3D rendered abstract collectibles'
            : 'Abstract digital art exploring color and form');
    final floorPrice = featured != null
        ? _fmtEth(featured.floorPrice)
        : (isCollectibles ? '0.95 ETH' : '2.5 ETH');
    final changePct = featured != null
        ? _fmtChange(featured.volumeChangePct)
        : (isCollectibles ? '+8.1%' : '+12.4%');
    final isPositive = !changePct.startsWith('-');
    final imageUrl = featured?.imageUrl ??
        (isCollectibles ? _nftImages[3] : _nftImages[0]);

    return GestureDetector(
      onTap: () => _openDetail(context,
          name: name, collection: 'Featured', price: floorPrice, imageUrl: imageUrl),
      child: Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.08),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
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
              name,
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
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
                  floorPrice,
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFF00D4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  changePct,
                  style: TextStyles.bodySmall.copyWith(
                    color: isPositive
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
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
                      onTap: () => _selectFilter(f),
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

  Widget _buildTrendingCollections(List<NftCollection>? real) {
    final collections = (real != null && real.isNotEmpty)
        ? real
            .asMap()
            .entries
            .map((e) => _NftCollection(
                  e.value.name,
                  _fmtEth(e.value.floorPrice),
                  _fmtChange(e.value.volumeChangePct),
                  e.value.imageUrl ?? _nftImages[e.key % _nftImages.length],
                ))
            .toList()
        : [
            _NftCollection('Ces', '3.5 ETH', '-23.1%', _nftImages[0]),
            _NftCollection('Cyber Punks Elite', '5.8 ETH', '-3.2%', _nftImages[1]),
            _NftCollection('Digital...', '2.1 ETH', '+8.4%', _nftImages[2]),
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
            itemBuilder: (context, i) => GestureDetector(
              onTap: () => _openDetail(context,
                  name: collections[i].name,
                  collection: collections[i].name,
                  price: collections[i].floor,
                  imageUrl: collections[i].imagePath),
              child: _buildTrendingCard(collections[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(_NftCollection c) {
    final isPositive = !c.change.startsWith('-');
    return Container(
      width: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
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

  Widget _buildTopVolume(List<NftCollection>? real) {
    final items = (real != null && real.isNotEmpty)
        ? real
            .asMap()
            .entries
            .map((e) => _TopVolumeItem(
                  e.value.rank != 0 ? e.value.rank : e.key + 1,
                  e.value.name,
                  _fmtEth(e.value.floorPrice),
                  e.value.ownerCount.toString(),
                  '${e.value.volume.toStringAsFixed(0)} ETH',
                  _fmtChange(e.value.volumeChangePct),
                  e.value.imageUrl,
                ))
            .toList()
        : [
            _TopVolumeItem(1, 'Geometric Vision', '1.8 ETH', '2,100', '890 ETH',
                '-3.2%', null),
            _TopVolumeItem(2, 'Holographic Future', '3.2 ETH', '1,850',
                '2100 ETH', '+24.8%', null),
            _TopVolumeItem(3, 'Abstract Dimension', '0.95 ETH', '4,200',
                '450 ETH', '+8.1%', null),
            _TopVolumeItem(4, 'Crypto Punks Legacy', '5.2 ETH', '1,290',
                '3500 ETH', '+15.7%', null),
            _TopVolumeItem(
                5, 'Neon Beats', '1.5 ETH', '2,800', '880 ETH', '+9.3%', null),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            children: [
              ...items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(
                  children: [
                    _buildVolumeRow(e.value, e.key),
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

  Widget _buildVolumeRow(_TopVolumeItem item, int fallbackIndex) {
    final isPositive = !item.change.startsWith('-');
    final imageUrl =
        item.imageUrl ?? _nftImages[fallbackIndex % _nftImages.length];
    return GestureDetector(
      onTap: () => _openDetail(context,
          name: item.name,
          collection: item.name,
          price: item.floor,
          imageUrl: imageUrl),
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
                imageUrl,
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

  Widget _buildNewDrops(List<NftItem>? real) {
    final drops = (real != null && real.isNotEmpty) ? real.take(2).toList() : null;
    final name0 = drops != null ? drops[0].name : 'Chromatic Dreams';
    final price0 = drops != null ? _fmtEth(drops[0].price) : '2.5 ETH';
    final image0 = drops != null ? (drops[0].imageUrl ?? _nftImages[4]) : _nftImages[4];
    final has1 = drops != null && drops.length > 1;
    final name1 = has1 ? drops[1].name : 'Geometric Visions';
    final price1 = has1 ? _fmtEth(drops[1].price) : '1.8 ETH';
    final image1 = has1 ? (drops[1].imageUrl ?? _nftImages[5]) : _nftImages[5];
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
              child: GestureDetector(
                onTap: () => _openDetail(context,
                    name: name0, collection: 'New Drops', price: price0, imageUrl: image0),
                child: _buildDropCard(name0, price0, image0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _openDetail(context,
                    name: name1, collection: 'New Drops', price: price1, imageUrl: image1),
                child: _buildDropCard(name1, price1, image1),
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

  Widget _buildTrendingCollectibles(List<NftCollection>? real) {
    final items = (real != null && real.isNotEmpty)
        ? real
            .asMap()
            .entries
            .map((e) => _TopVolumeItem(
                  e.value.rank != 0 ? e.value.rank : e.key + 1,
                  e.value.name,
                  _fmtEth(e.value.floorPrice),
                  e.value.ownerCount.toString(),
                  '${e.value.volume.toStringAsFixed(0)} ETH',
                  _fmtChange(e.value.volumeChangePct),
                  e.value.imageUrl,
                ))
            .toList()
        : [
            _TopVolumeItem(5, 'Crypto Punks Legacy', '5.2 ETH', '1,200',
                '3500 ETH', '+15.7%', null),
            _TopVolumeItem(10, 'Rare Collectible Cards', '1.2 ETH', '3,800',
                '560 ETH', '+5.8%', null),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            children:
                items.asMap().entries.map((e) {
                  final isLast = e.key == items.length - 1;
                  return Column(
                    children: [
                      _buildCollectibleRow(e.value, e.key),
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

  Widget _buildCollectibleRow(_TopVolumeItem item, int fallbackIndex) {
    final isPositive = !item.change.startsWith('-');
    final imageUrl =
        item.imageUrl ?? _nftImages[fallbackIndex % _nftImages.length];
    return GestureDetector(
      onTap: () => _openDetail(context,
          name: item.name,
          collection: item.name,
          price: item.floor,
          imageUrl: imageUrl),
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
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
      ),
    );
  }

  Widget _buildNewDropsCollectibles(List<NftItem>? real) {
    final drops = (real != null && real.isNotEmpty) ? real.take(2).toList() : null;
    final name0 = drops != null ? drops[0].name : 'Abstract Dimensions';
    final price0 = drops != null ? _fmtEth(drops[0].price) : '0.95 ETH';
    final image0 = drops != null ? (drops[0].imageUrl ?? _nftImages[2]) : _nftImages[2];
    final has1 = drops != null && drops.length > 1;
    final name1 = has1 ? drops[1].name : 'Crypto Punks Legacy';
    final price1 = has1 ? _fmtEth(drops[1].price) : '5.2 ETH';
    final image1 = has1 ? (drops[1].imageUrl ?? _nftImages[3]) : _nftImages[3];
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
              child: GestureDetector(
                onTap: () => _openDetail(context,
                    name: name0, collection: 'New Drops', price: price0, imageUrl: image0),
                child: _buildImageDropCard(name0, price0, image0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _openDetail(context,
                    name: name1, collection: 'New Drops', price: price1, imageUrl: image1),
                child: _buildImageDropCard(name1, price1, image1),
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
  final String? imageUrl;
  _TopVolumeItem(
    this.rank,
    this.name,
    this.floor,
    this.owners,
    this.volume,
    this.change,
    this.imageUrl,
  );
}
