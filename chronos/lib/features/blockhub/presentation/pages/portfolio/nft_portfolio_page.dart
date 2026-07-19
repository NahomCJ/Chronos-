import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'nft_analytics_page.dart';
import 'nft_pnl_page.dart';
import '../nft/nft_collections_page.dart';

class NftPortfolioPage extends StatefulWidget {
  const NftPortfolioPage({super.key});

  @override
  State<NftPortfolioPage> createState() => _NftPortfolioPageState();
}

class _NftPortfolioPageState extends State<NftPortfolioPage> {
  String _activeTab = 'pnl';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          Positioned.fill(
            child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildPortfolioValueCard(),
                  const SizedBox(height: 16),
                  _buildStatChips(),
                  const SizedBox(height: 16),
                  _buildTabButtons(),
                  const SizedBox(height: 22),
                  _buildYourNFTs(),
                  const SizedBox(height: 22),
                  _buildCollectionAllocation(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'NFT Portfolio',
          textAlign: TextAlign.center,
          style: TextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your digital asset collection',
          textAlign: TextAlign.center,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioValueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Portfolio Value',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '7.40 ETH',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$17760.00',
            style: TextStyles.bodySmall.copyWith(
              color: const Color(0xFF00D4FF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF22C55E), size: 16),
              const SizedBox(width: 4),
              Text(
                '+3.2% 24h',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF22C55E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.trending_up, color: Color(0xFF22C55E), size: 16),
              const SizedBox(width: 4),
              Text(
                '+19.35% Total P&L',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF22C55E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChips() {
    return Row(
      children: [
        Expanded(child: _statChip(Icons.attach_money, 'Items', '3', null)),
        const SizedBox(width: 10),
        Expanded(
          child: _statChip(
            Icons.trending_up,
            'Profit',
            '1.20 ETH',
            const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statChip(
            Icons.collections_outlined,
            'Collections',
            '3',
            null,
          ),
        ),
      ],
    );
  }

  Widget _statChip(
    IconData icon,
    String label,
    String value,
    Color? valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFAB7FF8), size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_activeTab == 'pnl') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NftPnlPage()),
                );
              } else {
                setState(() => _activeTab = 'pnl');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    _activeTab == 'pnl'
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                'View P&L',
                textAlign: TextAlign.center,
                style: TextStyles.labelMedium.copyWith(
                  color: _activeTab == 'pnl' ? Colors.black : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_activeTab == 'analytics') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NftAnalyticsPage()),
                );
              } else {
                setState(() => _activeTab = 'analytics');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    _activeTab == 'analytics'
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                'Analytics',
                textAlign: TextAlign.center,
                style: TextStyles.labelMedium.copyWith(
                  color:
                      _activeTab == 'analytics' ? Colors.black : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYourNFTs() {
    final nfts = [
      _NftItem(
        'Chromatic Dreams',
        'Chromatic #1234',
        '2.8 ETH',
        '2.2 ETH',
        '+27.3%',
        const Color(0xFF374151),
        'assets/Chromatic Dreams.png',
      ),
      _NftItem(
        'Holographic Futures',
        'Holographic #9012',
        '3.5 ETH',
        '2.8 ETH',
        '+25.0%',
        Colors.black,
        'assets/MarketplaceHome.png',
      ),
      _NftItem(
        'Abstract Dimensions',
        'Abstract...',
        '1.1 ETH',
        '0.9 ETH',
        '+22.2%',
        const Color(0xFF1F2937),
        'assets/Abstract Dimensions.png',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your NFTs',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NftCollectionsPage()),
              ),
              child: Text(
                'View All',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFFDC8F4A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: nfts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _buildNftCard(nfts[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildNftCard(_NftItem nft) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: nft.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          // Image with gradient overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    nft.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                nft.bgColor,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // % badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                nft.change,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nft.collection,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    nft.name,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current',
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              nft.current,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cost',
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              nft.cost,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionAllocation() {
    final collections = [
      _CollectionAlloc(
        'Chromatic Dreams',
        0.40,
        '40%',
        const Color(0xFF7C3AED),
      ),
      _CollectionAlloc(
        'Holographic Futures',
        0.35,
        '35%',
        const Color(0xFF3B82F6),
      ),
      _CollectionAlloc(
        'Abstract Dimensions',
        0.25,
        '25%',
        const Color(0xFF22C55E),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collection Allocation',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...collections.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c.name,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        c.percent,
                        style: TextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: c.value,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(c.color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NftItem {
  final String collection, name, current, cost, change, imagePath;
  final Color bgColor;
  const _NftItem(
    this.collection,
    this.name,
    this.current,
    this.cost,
    this.change,
    this.bgColor,
    this.imagePath,
  );
}

class _CollectionAlloc {
  final String name, percent;
  final double value;
  final Color color;
  const _CollectionAlloc(this.name, this.value, this.percent, this.color);
}
