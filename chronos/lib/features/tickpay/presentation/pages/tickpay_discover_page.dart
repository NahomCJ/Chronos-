import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../constants/tickpay_colors.dart';
import '../utils/tickpay_catalog.dart';
import '../utils/tickpay_media.dart';

class TickPayDiscoverPage extends StatefulWidget {
  const TickPayDiscoverPage({super.key});

  @override
  State<TickPayDiscoverPage> createState() => _TickPayDiscoverPageState();
}

class _TickPayDiscoverPageState extends State<TickPayDiscoverPage> {
  final TextEditingController _ctrl = TextEditingController();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _isAiMode = false;
  bool _searching = false;
  bool _voiceActive = false;
  List<TProduct> _aiResults = [];

  // Checkout flow state
  TProduct? _selectedProduct;
  bool _showCheckout = false;
  int _installments = 4;

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
    ('Resistance Bands', '\$29', TickPayMedia.gymBag, 0.15),
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _isAiMode = false; _aiResults = []; });
      return;
    }
    setState(() { _searching = true; _isAiMode = true; });
    await Future.delayed(const Duration(milliseconds: 400));
    final results = searchProducts(query);
    if (mounted) setState(() { _aiResults = results; _searching = false; });
  }

  Future<void> _toggleVoice() async {
    if (_voiceActive) {
      await _stt.stop();
      setState(() => _voiceActive = false);
      return;
    }
    final available = await _stt.initialize();
    if (!available) return;
    setState(() => _voiceActive = true);
    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          _ctrl.text = result.recognizedWords;
          setState(() => _voiceActive = false);
          _search(result.recognizedWords);
        }
      },
    );
  }

  void _clearSearch() {
    _ctrl.clear();
    setState(() { _isAiMode = false; _aiResults = []; _searching = false; });
  }

  void _selectProduct(TProduct product) {
    setState(() {
      _selectedProduct = product;
      _installments = 4;
      _showCheckout = true;
    });
    _showCheckoutSheet(product);
  }

  void _showCheckoutSheet(TProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(
        product: product,
        initialInstallments: _installments,
        onConfirm: (installments) {
          Navigator.pop(context);
          context.push(RouteConstants.tickpayBnplCheckout.toPath, extra: {
            'name': product.name,
            'price': product.price,
            'asset': product.imageUrl,
            'installments': installments,
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: ChrisHomeFab(
        onTap: () => context.push(RouteConstants.pantherAiChat.toPath),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 4,
        onItemSelected: (i) {
          switch (i) {
            case 0: context.go(RouteConstants.home.toPath);
            case 1: context.go(RouteConstants.pantherAi.toPath);
            case 2: context.go(RouteConstants.blockHub.toPath);
          }
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/tickpay/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
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
                      const SizedBox(height: 12),
                      _buildCategoriesRow(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: TickpayColors.scaffoldLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: _buildDefaultContent(),
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
            decoration: const BoxDecoration(color: TickpayColors.warning, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
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
            const SizedBox(width: 18),
            Icon(Icons.search, color: TickpayColors.textMutedLight, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onSubmitted: _search,
                onChanged: (v) {
                  if (v.isEmpty) _clearSearch();
                },
                style: const TextStyle(color: TickpayColors.textPrimaryLight, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask Chris to find anything...',
                  hintStyle: TextStyle(color: TickpayColors.textMutedLight, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_isAiMode)
              GestureDetector(
                onTap: _clearSearch,
                child: Icon(Icons.close, color: TickpayColors.textMutedLight, size: 18),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _toggleVoice,
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: _voiceActive
                      ? const Color(0xFFFF2D87)
                      : TickpayColors.accentPurple,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _voiceActive ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
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
            onTap: () {
              _ctrl.text = cat.$2;
              _search(cat.$2);
            },
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

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
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
          _buildSection(context, 'Home & Living', _homeProducts, TickpayColors.warning),
          const SizedBox(height: 28),
          _buildSection(context, 'Beauty & Care', _beautyProducts, const Color(0xFFFF6EB4)),
          const SizedBox(height: 28),
          _buildSection(context, 'Gaming', _gamingProducts, TickpayColors.accentPurple),
          const SizedBox(height: 28),
          _buildRecommended(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeaturedDeals(BuildContext context) {
    final title = !_isAiMode
        ? 'Featured Deals'
        : (_ctrl.text.isNotEmpty ? 'Results for "${_ctrl.text}"' : 'Search Results');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: TickpayColors.textPrimaryLight, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (_isAiMode)
                GestureDetector(
                  onTap: _clearSearch,
                  child: const Row(children: [
                    Icon(Icons.close_rounded, color: Color(0xFFFF2D87), size: 14),
                    SizedBox(width: 4),
                    Text('Clear', style: TextStyle(color: Color(0xFFFF2D87), fontSize: 13)),
                  ]),
                )
              else
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
        if (_isAiMode && _searching)
          const SizedBox(
            height: 210,
            child: Center(child: CircularProgressIndicator(color: Color(0xFFFF2D87), strokeWidth: 2)),
          )
        else if (_isAiMode && _aiResults.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('No results for "${_ctrl.text}" — try another search',
                style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 13)),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _isAiMode ? _aiResults.length : _electronicsProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                if (_isAiMode) {
                  final p = _aiResults[i];
                  return _productCard(context, p.name, p.price, p.imageUrl, p.discount,
                      onTap: () => _selectProduct(p));
                }
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
                      color: TickpayColors.textPrimaryLight, fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  _ctrl.text = title;
                  _search(title);
                },
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
                    color: TickpayColors.accentPurple.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: TickpayColors.accentPurple, size: 13),
                ),
                const SizedBox(width: 6),
                const Text('Recommended for You',
                    style: TextStyle(color: TickpayColors.textPrimaryLight, fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              GestureDetector(
                onTap: () {
                  _ctrl.text = 'recommended';
                  _search('recommended');
                },
                child: const Text('View', style: TextStyle(color: TickpayColors.accentPurple, fontSize: 13)),
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
              return _staticAiCard(context, p.$1, p.$2, p.$3);
            },
          ),
        ),
      ],
    );
  }

  Widget _productCard(BuildContext context, String name, String price,
      String asset, double discount, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => context.push(RouteConstants.tickpayProductDetail.toPath,
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
                              color: TickpayColors.textPrimaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(price,
                          style: const TextStyle(
                              color: TickpayColors.textPrimaryLight,
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
                child: const Icon(Icons.favorite_border, color: TickpayColors.textMutedLight, size: 14),
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

  Widget _staticAiCard(BuildContext context, String name, String price, String asset) {
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
                              color: TickpayColors.textPrimaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(price,
                          style: const TextStyle(
                              color: TickpayColors.textPrimaryLight,
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
                    color: TickpayColors.accentPurple,
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
                child: const Icon(Icons.favorite_border, color: TickpayColors.textMutedLight, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  final TProduct product;
  final int initialInstallments;
  final void Function(int installments) onConfirm;

  const _CheckoutSheet({
    required this.product,
    required this.initialInstallments,
    required this.onConfirm,
  });

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  late int _installments;

  @override
  void initState() {
    super.initState();
    _installments = widget.initialInstallments;
  }

  double get _perInstallment => widget.product.priceNum / _installments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: TickpayColors.scaffoldLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: TickpayColors.textPrimaryLight.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: TickpayColors.textPrimaryLight, size: 12),
              ),
              const SizedBox(width: 8),
              const Text('Chris says:',
                  style: TextStyle(color: TickpayColors.textPrimaryLight, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'I found "${widget.product.name}" for ${widget.product.price}. How would you like to pay?',
            style: const TextStyle(color: TickpayColors.textPrimaryLight, fontSize: 15),
          ),
          const SizedBox(height: 20),
          const Text('Choose your plan:',
              style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            children: [2, 3, 4, 6].map((n) {
              final selected = _installments == n;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _installments = n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? TickpayColors.textPrimaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? TickpayColors.textPrimaryLight
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('$n',
                            style: TextStyle(
                                color: selected ? Colors.white : TickpayColors.textPrimaryLight,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text('payments',
                            style: TextStyle(
                                color: selected ? Colors.white.withValues(alpha: 0.8) : TickpayColors.textMutedLight,
                                fontSize: 9)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TickpayColors.textPrimaryLight.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Per payment', style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 12)),
                    Text(
                      '\$${_perInstallment.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: TickpayColors.textPrimaryLight,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total', style: TextStyle(color: TickpayColors.textMutedLight, fontSize: 12)),
                    Text(
                      widget.product.price,
                      style: const TextStyle(
                          color: TickpayColors.textPrimaryLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => widget.onConfirm(_installments),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: TickpayColors.textPrimaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Confirm & Checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
