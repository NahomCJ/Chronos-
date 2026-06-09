import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/marketplace_product.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';

class ProductDiscoveryPage extends StatefulWidget {
  const ProductDiscoveryPage({super.key});

  @override
  State<ProductDiscoveryPage> createState() => _ProductDiscoveryPageState();
}

class _ProductDiscoveryPageState extends State<ProductDiscoveryPage> {
  late final MarketplaceBloc _marketplaceBloc;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _marketplaceBloc = GetIt.I<MarketplaceBloc>()
      ..add(ProductSearchRequested('electronics'));
  }

  @override
  void dispose() {
    _marketplaceBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      _marketplaceBloc.add(ProductSearchRequested(q));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _marketplaceBloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/background.png', fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSearchBar(),
                  Expanded(
                    child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
                      builder: (context, state) {
                        if (state is MarketplaceLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF59E0B),
                            ),
                          );
                        }
                        if (state is MarketplaceLoaded &&
                            state.products.isNotEmpty) {
                          return SingleChildScrollView(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _buildRealProductGrid(
                                    context, state.products),
                                const SizedBox(height: 24),
                                _buildFilterButtons(context),
                                const SizedBox(height: 40),
                              ],
                            ),
                          );
                        }
                        if (state is MarketplaceError) {
                          return _buildFallback(context, state.message);
                        }
                        return _buildFallback(context, null);
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
          Column(
            children: [
              Text(
                'Product Discovery',
                style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
              ),
              Text(
                'AI-Powered Shopping',
                style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyles.bodyMedium
                    .copyWith(color: Colors.white, fontSize: 14),
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Search products…',
                  hintStyle: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withValues(alpha: 0.5), size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _search,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealProductGrid(
      BuildContext context, List<MarketplaceProduct> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) =>
          _buildRealProductCard(context, products[i]),
    );
  }

  Widget _buildRealProductCard(
      BuildContext context, MarketplaceProduct product) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.affordabilityCheck.toPath),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 48,
                    ),
                  ),
                ),
                if (product.bnplEligible)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF05DF72),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'BNPL',
                        style: TextStyles.bodySmall.copyWith(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.black.withValues(alpha: 0.6),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: TextStyles.bodyMedium.copyWith(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                product.vendor,
                style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(BuildContext context, String? errorMessage) {
    const fallbackProducts = [
      _FallbackProduct('Samsung Galaxy Buds', '\$149', 'assets/earbud.png'),
      _FallbackProduct('Adidas Ultraboost', '\$180', 'assets/shoe1.png'),
      _FallbackProduct('Sony WH-1000XM4', '\$350', 'assets/headphone.png'),
      _FallbackProduct('Apple Watch Series 6', '\$399', 'assets/smartwatch.png'),
      _FallbackProduct('Fitbit Charge 4', '\$129', 'assets/tracker.png'),
      _FallbackProduct('Samsung Galaxy Buds', '\$149', 'assets/earbud.png'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Using sample products: $errorMessage',
                style: TextStyles.bodySmall.copyWith(
                    color: Colors.orange, fontSize: 11),
              ),
            ),
          ],
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            itemCount: fallbackProducts.length,
            itemBuilder: (context, i) =>
                _buildFallbackCard(context, fallbackProducts[i]),
          ),
          const SizedBox(height: 24),
          _buildFilterButtons(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFallbackCard(BuildContext context, _FallbackProduct product) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.affordabilityCheck.toPath),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    product.imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.shopping_bag_outlined,
                          color: Colors.white.withValues(alpha: 0.3), size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_border,
                        color: Colors.black.withValues(alpha: 0.6), size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(product.name,
              style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(product.price,
              style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('AI Recommendations',
                style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 17)),
            Text('See All',
                style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _marketplaceBloc.add(ProductSearchRequested(
                  _searchController.text.isNotEmpty
                      ? _searchController.text
                      : 'electronics'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              elevation: 0,
            ),
            child: Text('BNPL Eligible',
                style: TextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push(RouteConstants.affordabilityCheck.toPath),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            child: Text('Best Value',
                style: TextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            child: Text('Lowest Stress Purchase',
                style: TextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _FallbackProduct {
  final String name;
  final String price;
  final String imagePath;
  const _FallbackProduct(this.name, this.price, this.imagePath);
}
