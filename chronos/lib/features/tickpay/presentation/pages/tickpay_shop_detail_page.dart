import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../utils/tickpay_media.dart';

class TickPayShopDetailPage extends StatefulWidget {
  const TickPayShopDetailPage({super.key});

  @override
  State<TickPayShopDetailPage> createState() => _TickPayShopDetailPageState();
}

class _TickPayShopDetailPageState extends State<TickPayShopDetailPage> {
  int _tabIndex = 0;
  static const _tabs = ['All Products', 'iPhone (24)', 'Mac'];

  static const _products = [
    ('iPhone 15 Pro', '\$999', TickPayMedia.iphone15Pro),
    ('MacBook Air M3', '\$1,099', TickPayMedia.macbook),
    ('iPad Pro 12.9"', '\$1,099', TickPayMedia.ipad),
    ('Sony WH-1000XM4', '\$349', TickPayMedia.headphonesBlack),
    ('Apple Watch Ultra', '\$799', TickPayMedia.appleWatchBlack),
    ('Wireless Earbuds', '\$149', TickPayMedia.wirelessEarbuds),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
            slivers: [
              _buildSliverHeader(context),
              SliverToBoxAdapter(child: _buildStoreInfo()),
              SliverToBoxAdapter(child: _buildTabs()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('All Products',
                          style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Row(
                        children: [
                          Text('Sort by',
                              style: TextStyle(
                                  color: Color(0xFF888888), fontSize: 13)),
                          Icon(Icons.keyboard_arrow_down,
                              color: Color(0xFF888888), size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildProductCard(context, _products[i]),
                    childCount: _products.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF0D0D1A),
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child:
              IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                  onPressed: () {}),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
              onPressed: () {}),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            TickPayImage(TickPayMedia.iphone15Pro, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Apple Store',
                  style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: Color(0xFF3B82F6), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFB800), size: 14),
              const SizedBox(width: 4),
              const Text('4.9',
                  style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const Text(' (13,xxx reviews)',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
              const SizedBox(width: 12),
              const Text('2.4M products',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Official Apple products and accessories. Authorized retailer offering the latest iPhones, MacBooks, iPads, and more with manufacturer warranty.',
            style: TextStyle(
                color: Color(0xFF666666), fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.asMap().entries.map((e) {
            final isSelected = _tabIndex == e.key;
            return GestureDetector(
              onTap: () => setState(() => _tabIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0D0D1A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0D0D1A)
                        : const Color(0xFFDDDDDD),
                  ),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF555555),
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, (String, String, String) p) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayProductDetail.toPath,
          extra: {'name': p.$1, 'price': p.$2, 'asset': p.$3}),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TickPayImage(
                  p.$3,
                  height: 120,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(p.$2,
                          style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border,
                    color: Color(0xFF444444), size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
