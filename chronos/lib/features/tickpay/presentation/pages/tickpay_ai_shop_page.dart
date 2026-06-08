import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../utils/tickpay_catalog.dart';

class TickPayAiShopPage extends StatefulWidget {
  const TickPayAiShopPage({super.key});

  @override
  State<TickPayAiShopPage> createState() => _TickPayAiShopPageState();
}

class _TickPayAiShopPageState extends State<TickPayAiShopPage>
    with TickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _speech = stt.SpeechToText();
  bool _voiceActive = false;
  bool _searching = false;
  List<TProduct> _results = [];
  String _query = '';
  bool _hasSearched = false;

  // Filter state
  double _maxPrice = 2000;
  String _selectedCat = 'all';
  bool _onlyBnpl = false;

  static const _teal = Color(0xFF14B8A6);
  static const _bg = Color(0xFF0D0D1A);
  static const _pink = Color(0xFFFF2D87);

  final _categories = const [
    ('all', 'All'),
    ('electronics', 'Electronics'),
    ('fashion', 'Fashion'),
    ('home', 'Home'),
    ('sports', 'Sports'),
    ('beauty', 'Beauty'),
    ('gaming', 'Gaming'),
    ('health', 'Health'),
    ('music', 'Music'),
    ('travel', 'Travel'),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _searching = true; _query = query; _hasSearched = true; });
    // Simulate crawl delay
    await Future.delayed(const Duration(milliseconds: 800));
    var results = query.toLowerCase() == 'all' || query.isEmpty
        ? kAllProducts
        : searchProducts(query);
    // Apply filters
    results = results
        .where((p) =>
            p.priceNum <= _maxPrice &&
            (_selectedCat == 'all' || p.category == _selectedCat) &&
            (!_onlyBnpl || p.bnpl.isNotEmpty))
        .toList();
    setState(() { _results = results; _searching = false; });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Future<void> _toggleVoice() async {
    if (_voiceActive) {
      await _speech.stop();
      setState(() => _voiceActive = false);
      return;
    }
    final ok = await _speech.initialize();
    if (!ok) return;
    setState(() => _voiceActive = true);
    await _speech.listen(
      onResult: (r) {
        _ctrl.text = r.recognizedWords;
        if (r.finalResult) {
          _speech.stop();
          setState(() => _voiceActive = false);
          _search(r.recognizedWords);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 0,
        onItemSelected: (i) {
          switch (i) {
            case 0: context.go(RouteConstants.home.toPath); break;
            case 1: context.go(RouteConstants.pantherAi.toPath); break;
            case 2: context.go(RouteConstants.blockHub.toPath); break;
          }
        },
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.65))),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _teal.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _teal.withValues(alpha: 0.4)),
                                ),
                                child: const Text('AI', style: TextStyle(color: _teal, fontSize: 10, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 6),
                              const Text('AI Shop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            ],
                          ),
                          Text('Powered by FireCrawl', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showFilters(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.tune_rounded, color: Colors.white.withValues(alpha: 0.7), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Category chips
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final active = _selectedCat == cat.$1;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCat = cat.$1);
                          if (_hasSearched) _search(_query);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? _teal : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active ? _teal : Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(cat.$2,
                              style: TextStyle(
                                color: active ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                              )),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Main content
                Expanded(
                  child: !_hasSearched
                      ? _buildEmptyState()
                      : _searching
                          ? _buildSearching()
                          : _buildResults(),
                ),

                // Search bar
                _buildSearchBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final suggestions = ['iPhone 15 Pro', 'Nike sneakers', 'Gaming headset', 'Skincare set', 'MacBook Air'];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _teal.withValues(alpha: 0.25), width: 1.5),
            ),
            child: const Icon(Icons.search_rounded, color: _teal, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Search anything', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('AI scours the web to find you\nthe best prices in real time',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13, height: 1.5)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((s) => GestureDetector(
              onTap: () { _ctrl.text = s; _search(s); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Text(s, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearching() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40, height: 40,
            child: CircularProgressIndicator(color: _teal, strokeWidth: 2),
          ),
          const SizedBox(height: 16),
          Text('Searching for "$_query"...', style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 6),
          Text('Crawling live prices across the web', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: Colors.white.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 12),
            Text('No results for "$_query"', style: const TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () { _ctrl.clear(); setState(() { _hasSearched = false; _results = []; }); },
              child: const Text('Clear search', style: TextStyle(color: _teal)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              Text('${_results.length} results', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('for "$_query"', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: _results.length,
            itemBuilder: (_, i) => _productCard(_results[i]),
          ),
        ),
      ],
    );
  }

  Widget _productCard(TProduct p) {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.tickpayProductDetail.toPath,
          extra: {'name': p.name, 'price': p.price, 'asset': p.imageUrl}),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.white.withValues(alpha: 0.05)),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.white.withValues(alpha: 0.05),
                        child: const Icon(Icons.image_outlined, color: Colors.white24),
                      ),
                    ),
                  ),
                  if (p.discount > 0)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: _pink, borderRadius: BorderRadius.circular(6)),
                        child: Text('-${(p.discount * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (p.bnpl.isNotEmpty)
                    Positioned(
                      bottom: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _teal.withValues(alpha: 0.5)),
                        ),
                        child: Text('BNPL', style: const TextStyle(color: _teal, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(p.brand, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.price, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      if (p.bnpl.isNotEmpty)
                        Text(p.bnpl, style: const TextStyle(color: _teal, fontSize: 9)),
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

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.4), size: 18),
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _voiceActive
                      ? 'Listening...'
                      : 'Search products, brands, categories...',
                  hintStyle: TextStyle(
                    color: _voiceActive ? _teal.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.28),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                onSubmitted: _search,
              ),
            ),
            GestureDetector(
              onTap: _toggleVoice,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _voiceActive ? _teal.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: _voiceActive ? _teal.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(
                  _voiceActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                  color: _voiceActive ? _teal : Colors.white.withValues(alpha: 0.5),
                  size: 16,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _search(_ctrl.text),
              child: Container(
                margin: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                width: 34, height: 34,
                decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Filters', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Text('Max price: \$${_maxPrice.toInt()}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
              Slider(
                value: _maxPrice,
                min: 25,
                max: 2000,
                divisions: 50,
                activeColor: _teal,
                inactiveColor: Colors.white.withValues(alpha: 0.15),
                onChanged: (v) => setModal(() => _maxPrice = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setModal(() => _onlyBnpl = !_onlyBnpl),
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: _onlyBnpl ? _teal : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _onlyBnpl ? _teal : Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: _onlyBnpl ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('BNPL available only', style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    if (_hasSearched) _search(_query);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(50)),
                    child: const Center(child: Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
