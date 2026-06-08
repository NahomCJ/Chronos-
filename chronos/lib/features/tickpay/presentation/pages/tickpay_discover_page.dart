import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
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
    (Icons.sports_esports_outlined, 'Gaming'),
    (Icons.flight_outlined, 'Travel'),
    (Icons.restaurant_outlined, 'Food'),
    (Icons.pets_outlined, 'Pets'),
    (Icons.health_and_safety_outlined, 'Health'),
    (Icons.directions_car_outlined, 'Auto'),
    (Icons.music_note_outlined, 'Music'),
    (Icons.child_care_outlined, 'Toys'),
  ];

  static final _fashionProducts = [
    ('Summer Dress', '\$89', TickPayMedia.fashionDress, 0.20),
    ('Leather Handbag', '\$145', TickPayMedia.handbag, 0.15),
    ('White Sneakers', '\$95', TickPayMedia.whiteSneakers, 0.10),
    ('Nike Running', '\$130', TickPayMedia.nikeShoes, 0.25),
  ];

  static final _electronicsProducts = [
    ('Samsung Buds', '\$149', TickPayMedia.wirelessEarbuds, 0.15),
    ('Adidas Ultraboost', '\$180', TickPayMedia.adidasShoes, 0.20),
    ('Sony WH-1000XM4', '\$350', TickPayMedia.headphonesBlack, 0.10),
    ('Apple Watch', '\$799', TickPayMedia.appleWatchBlack, 0.05),
    ('MacBook Air', '\$1,099', TickPayMedia.macbook, 0.08),
    ('iPad Pro', '\$799', TickPayMedia.ipad, 0.12),
  ];

  static final _sportsProducts = [
    ('Nike Shoes', '\$130', TickPayMedia.nikeShoes, 0.20),
    ('Gym Bag', '\$55', TickPayMedia.gymBag, 0.10),
    ('Yoga Mat', '\$35', TickPayMedia.yogaMat, 0.15),
    ('Fitbit Charge', '\$129', TickPayMedia.smartwatch, 0.10),
  ];

  static final _homeProducts = [
    ('Coffee Maker', '\$79', TickPayMedia.coffeeMaker, 0.20),
    ('Table Lamp', '\$45', TickPayMedia.tableLamp, 0.10),
    ('Apple Watch', '\$399', TickPayMedia.appleWatch, 0.05),
    ('JBL Speaker', '\$89', TickPayMedia.bluetoothSpeaker, 0.15),
  ];

  static final _beautyProducts = [
    ('Perfume Set', '\$75', TickPayMedia.perfume, 0.20),
    ('Skincare Kit', '\$99', TickPayMedia.skincare, 0.15),
    ('Headphones', '\$120', TickPayMedia.headphonesWhite, 0.10),
    ('Smartwatch', '\$249', TickPayMedia.smartwatch, 0.08),
  ];

  static final _gamingProducts = [
    ('Game Controller', '\$69', TickPayMedia.gameController, 0.15),
    ('Gaming Headset', '\$129', TickPayMedia.headphonesBlack, 0.10),
    ('Smart Speaker', '\$89', TickPayMedia.bluetoothSpeaker, 0.20),
    ('Phone Stand', '\$29', TickPayMedia.smartphone, 0.05),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context.push(RouteConstants.tickpayAiPicks.toPath),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D1A),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Color(0xFF8B5CF6), size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ask AI to find anything...',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Ask',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          CustomBottomNav(
            selectedIndex: 4,
            onItemSelected: (i) {
              switch (i) {
                case 0: context.go(RouteConstants.home.toPath);
                case 1: context.go(RouteConstants.pantherAi.toPath);
                case 2: context.go(RouteConstants.blockHub.toPath);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/tickpay/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.30)),
          ),
          // Content
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.20),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      _buildSearchBar(context),
                      const SizedBox(height: 16),
                      _buildCategoriesRow(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildFeaturedDeals(context),
                          const SizedBox(height: 28),
                          _buildSection(context, 'Fashion Picks', _fashionProducts, const Color(0xFFFF2D87)),
                          const SizedBox(height: 28),
                          _buildSection(context, 'Sports & Fitness', _sportsProducts, const Color(0xFF00A693)),
                          const SizedBox(height: 28),
                          _buildSection(context, 'Home & Living', _homeProducts, const Color(0xFFDC8F4A)),
                          const SizedBox(height: 28),
                          _buildSection(context, 'Beauty & Care', _beautyProducts, const Color(0xFFFF6EB4)),
                          const SizedBox(height: 28),
                          _buildSection(context, 'Gaming', _gamingProducts, const Color(0xFF8B5CF6)),
                          const SizedBox(height: 28),
                          _buildRecommended(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Discover',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Marketplace',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push(RouteConstants.tickpayNotifications.toPath),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Color(0xFFDC8F4A), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GestureDetector(
        onTap: () => context.push(RouteConstants.tickpaySearch.toPath),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade500, size: 20),
              const SizedBox(width: 10),
              Text('Search products...',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesRow(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          return GestureDetector(
            onTap: () => context.push(
              RouteConstants.tickpaySearch.toPath,
              extra: {'category': cat.$2},
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(cat.$1, color: Colors.black87, size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.$2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
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
                  style: TextStyle(color: Color(0xFF111111), fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => context.push(RouteConstants.tickpaySearch.toPath),
                child: const Row(children: [
                  Text('View All', style: TextStyle(color: Color(0xFFFF2D87), fontSize: 13)),
                  Icon(Icons.arrow_forward, color: Color(0xFFFF2D87), size: 14),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _electronicsProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = _electronicsProducts[i];
              return _productCard(context, p.$1, p.$2, p.$3, p.$4);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title,
      List<(String, String, String, double)> products, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF111111), fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => context.push(RouteConstants.tickpaySearch.toPath),
                child: Row(children: [
                  Text('View All', style: TextStyle(color: accentColor, fontSize: 13)),
                  Icon(Icons.arrow_forward, color: accentColor, size: 14),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = products[i];
              return _productCard(context, p.$1, p.$2, p.$3, p.$4);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommended(BuildContext context) {
    final picks = [
      ('Fitbit Charge 4', '\$129', TickPayMedia.smartwatch),
      ('Samsung Galaxy Buds', '\$149', TickPayMedia.wirelessEarbuds),
      ('Apple Watch Ultra', '\$799', TickPayMedia.appleWatchBlack),
      ('MacBook Air M3', '\$1,099', TickPayMedia.macbook),
      ('iPad Pro', '\$799', TickPayMedia.ipad),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6), size: 13),
                ),
                const SizedBox(width: 6),
                const Text('Recommended for You',
                    style: TextStyle(color: Color(0xFF111111), fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              GestureDetector(
                onTap: () => context.push(RouteConstants.tickpayAiPicks.toPath),
                child: const Text('View', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: picks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = picks[i];
              return _aiProductCard(context, p.$1, p.$2, p.$3);
            },
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
        width: 152,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TickPayImage(asset,
                    height: 115,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(price,
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
                    color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border, color: Color(0xFF888888), size: 14),
              ),
            ),
            if (discount > 0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF2D87),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text('-${(discount * 100).toInt()}%',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _aiProductCard(BuildContext context, String name, String price, String asset) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayProductDetail.toPath,
          extra: {'name': name, 'price': price, 'asset': asset}),
      child: Container(
        width: 152,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TickPayImage(asset,
                    height: 115,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(price,
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
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('AI',
                    style: TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border, color: Color(0xFF888888), size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
