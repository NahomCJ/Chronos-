import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../utils/tickpay_media.dart';

class TickPayDiscoverPage extends StatelessWidget {
  const TickPayDiscoverPage({super.key});

  static const _categories = [
    (Icons.devices_outlined, 'Electronics'),
    (Icons.checkroom_outlined, 'Fashion'),
    (Icons.home_outlined, 'Home'),
    (Icons.fitness_center_outlined, 'Sports'),
    (Icons.spa_outlined, 'Beauty'),
    (Icons.menu_book_outlined, 'Books'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withValues(alpha: 0.45)),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(context),
                        const SizedBox(height: 24),
                        _buildCategories(context),
                        const SizedBox(height: 28),
                        _buildFeaturedDeals(context),
                        const SizedBox(height: 28),
                        _buildRecommended(context),
                        const SizedBox(height: 80),
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

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Discover',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Marketplace',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                context.push(RouteConstants.tickpayNotifications.toPath),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: Color(0xFFDC8F4A), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => context.push(RouteConstants.tickpaySearch.toPath),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(Icons.search,
                  color: Colors.white.withValues(alpha: 0.4), size: 20),
              const SizedBox(width: 10),
              Text('Search products...',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categories',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: _categories.map((c) {
              return GestureDetector(
                onTap: () => context.push(
                  RouteConstants.tickpaySearch.toPath,
                  extra: {'category': c.$2},
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(c.$1, color: Colors.white70, size: 26),
                      const SizedBox(height: 6),
                      Text(c.$2,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedDeals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured Deals',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => context.push(RouteConstants.tickpaySearch.toPath),
                child: Row(
                  children: [
                    Text('View All',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13)),
                    Icon(Icons.arrow_forward,
                        color: Colors.white.withValues(alpha: 0.5), size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _productCard(context, 'Samsung Galaxy Buds', '\$149',
                  TickPayMedia.wirelessEarbuds, 0.15),
              const SizedBox(width: 12),
              _productCard(context, 'Adidas Ultraboost', '\$180',
                  TickPayMedia.adidasShoes, 0.20),
              const SizedBox(width: 12),
              _productCard(context, 'Sony WH-1000XM4', '\$350',
                  TickPayMedia.headphonesBlack, 0.10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommended(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Color(0xFF7C3AED), size: 12),
                  ),
                  const SizedBox(width: 6),
                  const Text('Recommended for You',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: () =>
                    context.push(RouteConstants.tickpayAiPicks.toPath),
                child: Text('View',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _aiProductCard(context, 'Fitbit Charge 4', '\$129',
                  TickPayMedia.smartwatch),
              const SizedBox(width: 12),
              _aiProductCard(context, 'Samsung Galaxy Buds', '\$149',
                  TickPayMedia.wirelessEarbuds),
              const SizedBox(width: 12),
              _aiProductCard(context, 'Apple Watch Ultra', '\$799',
                  TickPayMedia.appleWatchBlack),
            ],
          ),
        ),
      ],
    );
  }

  Widget _productCard(BuildContext context, String name, String price,
      String asset, double discount) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayProductDetail.toPath,
          extra: {'name': name, 'price': price, 'asset': asset}),
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TickPayImage(
                  asset,
                  height: 110,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(price,
                          style: const TextStyle(
                              color: Colors.white,
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
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border,
                    color: Colors.white, size: 14),
              ),
            ),
            if (discount > 0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF2D87),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                      '-${(discount * 100).toInt()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _aiProductCard(BuildContext context, String name, String price,
      String asset) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayProductDetail.toPath,
          extra: {'name': name, 'price': price, 'asset': asset}),
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TickPayImage(
                  asset,
                  height: 110,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(price,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('AI',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border,
                    color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
