import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../domain/entities/blockhub_entities.dart';
import '../../bloc/nft/nft_bloc.dart';
import '../../bloc/nft/nft_event.dart';
import '../../bloc/nft/nft_state.dart';
import 'nft_detail_page.dart';

class NftCollectionsPage extends StatefulWidget {
  const NftCollectionsPage({super.key});

  @override
  State<NftCollectionsPage> createState() => _NftCollectionsPageState();
}

class _NftCollectionsPageState extends State<NftCollectionsPage> {
  String _sortBy = 'Volume';
  final _sortOptions = ['Volume', 'Floor Price', 'Owners'];
  late final NftBloc _nftBloc;

  @override
  void initState() {
    super.initState();
    _nftBloc = GetIt.I<NftBloc>()..add(NftCollectionsLoadRequested());
  }

  @override
  void dispose() {
    _nftBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _nftBloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6D28D9).withValues(alpha: 0.18),
                      Colors.transparent,
                      const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSortRow(),
                  Expanded(
                    child: BlocBuilder<NftBloc, NftState>(
                      builder: (context, state) {
                        if (state is NftLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF59E0B),
                            ),
                          );
                        }
                        if (state is NftError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: TextStyles.bodyMedium
                                  .copyWith(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        if (state is NftCollectionsLoaded &&
                            state.collections.isNotEmpty) {
                          return ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 12, 16, 40),
                            itemCount: state.collections.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                _buildCollectionCard(
                                    context, state.collections[i]),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                          itemCount: _fallbackCollections.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              _buildFallbackCard(context, _fallbackCollections[i]),
                        );
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Text(
            'Collections',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.tune,
                    color: Colors.white.withValues(alpha: 0.7), size: 16),
                const SizedBox(width: 5),
                Text(
                  'Sort',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
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
                children: _sortOptions.map((opt) {
                  final selected = _sortBy == opt;
                  return GestureDetector(
                    onTap: () => setState(() => _sortBy = opt),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        opt,
                        style: TextStyles.bodySmall.copyWith(
                          color: selected
                              ? Colors.black
                              : Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, NftCollection c) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NftDetailPage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.07),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: c.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        c.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderIcon(),
                      ),
                    )
                  : _placeholderIcon(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Color(0xFF3B82F6), size: 16),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${c.itemCount} items',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _statItem('Floor Price',
                            '\$${c.floorPrice.toStringAsFixed(2)}',
                            const Color(0xFF00D4FF)),
                      ),
                      Expanded(
                        child: _statItem('24h Volume',
                            '\$${c.volume.toStringAsFixed(0)}',
                            Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCard(BuildContext context, _FallbackCollection c) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NftDetailPage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.07),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: c.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  c.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderIcon(),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Color(0xFF3B82F6), size: 16),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(c.blockchain,
                      style: TextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _statItem('Floor Price', c.floorPrice,
                              const Color(0xFF00D4FF))),
                      Expanded(
                          child: _statItem(
                              '24h Volume', c.volume, Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child:
                              _statItem('Owners', c.owners, Colors.white)),
                      Expanded(
                          child: _statItem(
                              '24h Change', c.change, const Color(0xFF22C55E))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() => Center(
        child: Icon(Icons.image_outlined,
            color: Colors.white.withValues(alpha: 0.3), size: 32),
      );

  Widget _statItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyles.bodySmall.copyWith(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  final _fallbackCollections = [
    _FallbackCollection('Chromatic Dreams', 'Ethereum', '2.5 ETH', '1250 ETH',
        '3,420', '+12.4%', const Color(0xFF374151), 'assets/Chromatic Dreams.png'),
    _FallbackCollection('Holographic Futures', 'Polygon', '2.5 ETH',
        '1250 ETH', '3,420', '+12.4%', Colors.black, 'assets/MarketplaceHome.png'),
    _FallbackCollection('Neon Beats', 'Floor Price', '2.5 ETH', '1250 ETH',
        '3,420', '+12.4%', const Color(0xFFEA580C), 'assets/MarketplaceHome1.png'),
    _FallbackCollection('Digital Keys', 'Solana', '2.5 ETH', '1250 ETH',
        '3,420', '+12.4%', const Color(0xFF064E3B), 'assets/Abstract Dimensions.png'),
  ];
}

class _FallbackCollection {
  final String name, blockchain, floorPrice, volume, owners, change, imagePath;
  final Color bgColor;
  const _FallbackCollection(this.name, this.blockchain, this.floorPrice,
      this.volume, this.owners, this.change, this.bgColor, this.imagePath);
}
