import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../utils/tickpay_media.dart';

class TickPaySearchPage extends StatefulWidget {
  const TickPaySearchPage({super.key});

  @override
  State<TickPaySearchPage> createState() => _TickPaySearchPageState();
}

class _TickPaySearchPageState extends State<TickPaySearchPage> {
  String _selectedCategory = 'All';
  String _selectedPrice = 'All';
  bool _bnplOnly = false;

  static const _categories = ['All', 'Electronics', 'Fashion', 'Home'];
  static const _prices = ['All', 'Under \$100', '\$100-\$500', '\$500+'];

  static const _products = [
    _Product('iPhone 15 Pro', '\$999', TickPayMedia.iphone15Pro, 'Apple'),
    _Product('Adidas Ultraboost', '\$180', TickPayMedia.adidasShoes, 'Adidas'),
    _Product('Sony WH-1000XM4', '\$350', TickPayMedia.headphonesBlack, 'Best Buy'),
    _Product('Apple Watch Series 6', '\$399', TickPayMedia.appleWatch, 'Apple'),
    _Product('Fitbit Charge 4', '\$129', TickPayMedia.smartwatch, 'Fitbit'),
    _Product('Samsung Galaxy Buds', '\$148', TickPayMedia.wirelessEarbuds, 'Samsung'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ── Dark header ───────────────────────────────────────────────────
          Container(
            color: const Color(0xFF1A0A2E),
            child: SafeArea(
              bottom: false,
              child: _buildHeader(context),
            ),
          ),
          // ── White search + filters + grid ─────────────────────────────────
          _buildSearchInput(),
          _buildFilters(),
          _buildResultsBar(),
          Expanded(child: _buildGrid(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Search & Filter',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              Text('Find your perfect product',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none,
                color: Colors.white, size: 20),
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

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF999999), size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: TextField(
                style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CATEGORY',
              style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 11,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          _chipRow(_categories, _selectedCategory,
              (v) => setState(() => _selectedCategory = v)),
          const SizedBox(height: 14),
          const Text('PRICE RANGE',
              style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 11,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          _chipRow(_prices, _selectedPrice,
              (v) => setState(() => _selectedPrice = v)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BNPL Only',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14)),
              Switch(
                value: _bnplOnly,
                onChanged: (v) => setState(() => _bnplOnly = v),
                activeColor: const Color(0xFF7C3AED),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipRow(
      List<String> options, String selected, ValueChanged<String> onTap) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((o) {
          final isSelected = o == selected;
          return GestureDetector(
            onTap: () => onTap(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A0A2E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1A0A2E)
                        : const Color(0xFFDDDDDD)),
              ),
              child: Text(o,
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
    );
  }

  Widget _buildResultsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${_products.length} products found',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
          const Row(
            children: [
              Text('Sort by',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
              Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF888888), size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _products.length,
      itemBuilder: (context, i) => _buildProductCard(context, _products[i]),
    );
  }

  Widget _buildProductCard(BuildContext context, _Product p) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayProductDetail.toPath,
          extra: {'name': p.name, 'price': p.price, 'asset': p.asset}),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                  p.asset,
                  height: 130,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(p.price,
                          style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 14,
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

class _Product {
  final String name, price, asset, store;
  const _Product(this.name, this.price, this.asset, this.store);
}
