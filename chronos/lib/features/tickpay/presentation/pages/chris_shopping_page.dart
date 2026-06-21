import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../utils/tickpay_media.dart';

// ── Product model ─────────────────────────────────────────────────────────────
class _Product {
  final String name, price, category, imageUrl;
  final double priceNum;
  const _Product(this.name, this.price, this.priceNum, this.category, this.imageUrl);
}

const _allProducts = [
  _Product('iPhone 15 Pro', '\$1,199', 1199, 'phone', TickPayMedia.iphone15Pro),
  _Product('Wireless Headphones', '\$299', 299, 'headphones', TickPayMedia.headphonesBlack),
  _Product('Apple Watch Series 9', '\$399', 399, 'watch', TickPayMedia.appleWatch),
  _Product('Nike Air Max', '\$120', 120, 'shoes', TickPayMedia.nikeShoes),
  _Product('Adidas Ultraboost', '\$89', 89, 'shoes', TickPayMedia.adidasShoes),
  _Product('MacBook Air M2', '\$1,099', 1099, 'laptop', TickPayMedia.macbook),
  _Product('iPad Pro', '\$799', 799, 'tablet', TickPayMedia.ipad),
  _Product('JBL Speaker', '\$149', 149, 'speaker', TickPayMedia.bluetoothSpeaker),
  _Product('Wireless Earbuds', '\$79', 79, 'earbuds', TickPayMedia.wirelessEarbuds),
  _Product('Smartwatch Fitness', '\$199', 199, 'watch', TickPayMedia.smartwatch),
  _Product('Gaming Controller', '\$69', 69, 'gaming', TickPayMedia.gameController),
  _Product('Coffee Maker', '\$89', 89, 'home', TickPayMedia.coffeeMaker),
];

// ── Chat message model ────────────────────────────────────────────────────────
enum _MsgType { user, chris, products, checkout }

class _ChatMsg {
  final _MsgType type;
  final String? text;
  final List<_Product>? products;
  final _Product? selectedProduct;
  _ChatMsg.text(this.type, this.text)
      : products = null, selectedProduct = null;
  _ChatMsg.products(this.products)
      : type = _MsgType.products, text = null, selectedProduct = null;
  _ChatMsg.checkout(this.selectedProduct)
      : type = _MsgType.checkout, text = null, products = null;
}

// ── Chat state machine ────────────────────────────────────────────────────────
enum _ChatState { greeting, waitingProduct, waitingBudget, showingProducts, confirming, done }

class ChrisShoppingPage extends StatefulWidget {
  const ChrisShoppingPage({super.key});

  @override
  State<ChrisShoppingPage> createState() => _ChrisShoppingPageState();
}

class _ChrisShoppingPageState extends State<ChrisShoppingPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _speech = stt.SpeechToText();
  bool _voiceActive = false;
  bool _isTyping = false;

  _ChatState _state = _ChatState.greeting;
  String _detectedCategory = '';
  double _budget = double.infinity;
  bool _hasBills = false;
  _Product? _pendingProduct;

  final List<_ChatMsg> _msgs = [];

  static const _teal = Color(0xFF14B8A6);
  static const _bg = Color(0xFF0D0D1A);

  @override
  void initState() {
    super.initState();
    // Initial greeting after short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      _addChris('Hey! I\'m Chris 👋\nWhat would you like to buy today? Just tell me and I\'ll find the best deals for you.');
      setState(() => _state = _ChatState.waitingProduct);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _speech.stop();
    super.dispose();
  }

  void _addChris(String text) {
    setState(() => _msgs.add(_ChatMsg.text(_MsgType.chris, text)));
    _scrollToBottom();
  }

  void _addUser(String text) {
    setState(() => _msgs.add(_ChatMsg.text(_MsgType.user, text)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _showTyping() {
    setState(() => _isTyping = true);
    _scrollToBottom();
  }

  void _hideTyping() {
    setState(() => _isTyping = false);
  }

  Future<void> _processUserInput(String input) async {
    if (input.trim().isEmpty) return;
    _addUser(input);
    _ctrl.clear();

    _showTyping();
    await Future.delayed(const Duration(milliseconds: 900));
    _hideTyping();

    final lower = input.toLowerCase();

    switch (_state) {
      case _ChatState.waitingProduct:
        _handleProductRequest(lower);
        break;
      case _ChatState.waitingBudget:
        _handleBudgetResponse(lower, input);
        break;
      case _ChatState.showingProducts:
        _handleProductSelection(lower, input);
        break;
      case _ChatState.confirming:
        _handleConfirmation(lower);
        break;
      default:
        _addChris('What else can I help you find? Just tell me what you\'d like to buy!');
        setState(() => _state = _ChatState.waitingProduct);
    }
  }

  void _handleProductRequest(String lower) {
    // Detect product category
    if (lower.contains('phone') || lower.contains('iphone') || lower.contains('android') || lower.contains('mobile')) {
      _detectedCategory = 'phone';
    } else if (lower.contains('laptop') || lower.contains('macbook') || lower.contains('computer')) {
      _detectedCategory = 'laptop';
    } else if (lower.contains('headphone') || lower.contains('earphone') || lower.contains('audio')) {
      _detectedCategory = 'headphones';
    } else if (lower.contains('earb') || lower.contains('airpod') || lower.contains('earbud')) {
      _detectedCategory = 'earbuds';
    } else if (lower.contains('shoe') || lower.contains('sneaker') || lower.contains('boot')) {
      _detectedCategory = 'shoes';
    } else if (lower.contains('watch')) {
      _detectedCategory = 'watch';
    } else if (lower.contains('tablet') || lower.contains('ipad')) {
      _detectedCategory = 'tablet';
    } else if (lower.contains('speaker')) {
      _detectedCategory = 'speaker';
    } else if (lower.contains('game') || lower.contains('gaming') || lower.contains('controller')) {
      _detectedCategory = 'gaming';
    } else {
      // Try to guess from general keywords
      _detectedCategory = 'all';
    }

    _addChris('Got it! What\'s your budget? And do you have any upcoming bills I should know about? I want to make sure the timing works for you 😊');
    setState(() => _state = _ChatState.waitingBudget);
  }

  void _handleBudgetResponse(String lower, String original) {
    // Parse budget
    final budgetMatch = RegExp(r'\$?(\d+)').firstMatch(lower);
    if (budgetMatch != null) {
      _budget = double.tryParse(budgetMatch.group(1)!) ?? double.infinity;
    } else if (lower.contains('no budget') || lower.contains("don't have") || lower.contains('any')) {
      _budget = double.infinity;
    }

    // Check for bills
    _hasBills = lower.contains('bill') || lower.contains('rent') || lower.contains('payment')
        || lower.contains('due') || lower.contains('limited') || lower.contains('tight')
        || lower.contains('not much') || lower.contains('broke');

    // Filter products
    var filtered = _detectedCategory == 'all'
        ? _allProducts.toList()
        : _allProducts.where((p) => p.category == _detectedCategory).toList();

    // Apply budget (leave 30% buffer if bills mentioned)
    final effectiveBudget = _hasBills ? _budget * 0.7 : _budget;
    if (effectiveBudget < double.infinity) {
      filtered = filtered.where((p) => p.priceNum <= effectiveBudget).toList();
    }

    // Fallback to cheaper alternatives
    if (filtered.isEmpty && _budget < double.infinity) {
      filtered = _allProducts.where((p) => p.priceNum <= _budget).toList();
    }

    if (filtered.isEmpty) {
      filtered = _allProducts.take(4).toList();
    }

    final budgetStr = _budget < double.infinity ? 'under \$${_budget.toStringAsFixed(0)}' : 'any budget';

    String reply;
    if (_hasBills) {
      reply = 'Smart thinking! Since you have upcoming bills, I\'ve kept the budget a bit lighter so you stay comfortable. Here are the best options $budgetStr 👇';
    } else {
      reply = 'Perfect! Here are the best matches I found for you $budgetStr 👇';
    }

    _addChris(reply);
    setState(() {
      _msgs.add(_ChatMsg.products(filtered.take(4).toList()));
      _state = _ChatState.showingProducts;
    });
    _scrollToBottom();
  }

  void _handleProductSelection(String lower, String original) {
    if (_pendingProduct != null) {
      _handleConfirmation(lower);
    } else {
      _addChris('Tap any product above to select it, and I\'ll handle the rest for you!');
    }
  }

  void _handleConfirmation(String lower) {
    if (lower.contains('yes') || lower.contains('confirm') || lower.contains('buy')
        || lower.contains('ok') || lower.contains('sure') || lower.contains('go')) {
      _addChris('Excellent! Processing your order... 🎉');
      Future.delayed(const Duration(milliseconds: 600), () {
        setState(() {
          _msgs.add(_ChatMsg.checkout(_pendingProduct!));
          _state = _ChatState.done;
        });
        _scrollToBottom();
      });
    } else if (lower.contains('no') || lower.contains('cancel') || lower.contains('back')) {
      _addChris('No worries! Want to look at other options? Just tell me what you\'re looking for 😊');
      _pendingProduct = null;
      setState(() => _state = _ChatState.showingProducts);
    } else {
      _addChris('Just say "yes" to confirm or "no" to go back and browse more options.');
    }
  }

  void _selectProduct(_Product p) {
    setState(() => _pendingProduct = p);
    _addChris('Great choice! **${p.name}** for ${p.price}\n\nReady to checkout? Just say "yes" and I\'ll handle the rest! 🛒');
    setState(() => _state = _ChatState.confirming);
    _scrollToBottom();
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
        if (r.finalResult) {
          _speech.stop();
          setState(() => _voiceActive = false);
          _processUserInput(r.recognizedWords);
        } else {
          _ctrl.text = r.recognizedWords;
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.15))),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                      // Chris avatar
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.10)],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
                        ),
                        child: Center(
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chris', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          Text('Shopping Assistant', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0x18FFFFFF)),

                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _msgs.length + (_isTyping ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (_isTyping && i == _msgs.length) return _buildTyping();
                      return _buildMessage(_msgs[i]);
                    },
                  ),
                ),

                // Input bar
                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMsg msg) {
    if (msg.type == _MsgType.products) return _buildProductCards(msg.products!);
    if (msg.type == _MsgType.checkout) return _buildCheckoutCard(msg.selectedProduct!);

    final isUser = msg.type == _MsgType.user;
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: isUser ? 60 : 0,
        right: isUser ? 0 : 60,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser
                ? _teal.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isUser ? const Radius.circular(4) : null,
              bottomLeft: isUser ? null : const Radius.circular(4),
            ),
            border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Text(
            msg.text ?? '',
            style: TextStyle(
              color: isUser ? Colors.white : Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTyping() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 60),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(4)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => _buildDot(i)),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 400 + i * 150),
      builder: (_, v, __) => Container(
        width: 6, height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: v),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildProductCards(List<_Product> products) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          itemBuilder: (_, i) {
            final p = products[i];
            return GestureDetector(
              onTap: () => _selectProduct(p),
              child: Container(
                width: 140,
                margin: EdgeInsets.only(left: i == 0 ? 0 : 10, right: i == products.length - 1 ? 0 : 0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: p.imageUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(height: 110, color: Colors.white12),
                        errorWidget: (_, __, ___) => Container(height: 110,
                            color: Colors.white12,
                            child: const Icon(Icons.image_outlined, color: Colors.white24)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, height: 1.3)),
                          const SizedBox(height: 4),
                          Text(p.price,
                              style: const TextStyle(color: _teal, fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckoutCard(_Product p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _teal.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: p.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(height: 140, color: Colors.white12),
                errorWidget: (_, __, ___) => Container(height: 140, color: Colors.white12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(p.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                      Text(p.price,
                          style: const TextStyle(color: _teal, fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('TickPay · Buy Now Pay Later available',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: _teal,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Center(
                            child: Text('Order Confirmed ✓',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
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

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _voiceActive ? 'Listening...' : 'Tell me what you want to buy...',
                        hintStyle: TextStyle(
                            color: _voiceActive ? _teal.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.30),
                            fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      onSubmitted: _processUserInput,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleVoice,
                    child: Container(
                      margin: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _voiceActive ? _teal.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                        border: Border.all(color: _voiceActive ? _teal.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Icon(_voiceActive ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _voiceActive ? _teal : Colors.white.withValues(alpha: 0.5), size: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _processUserInput(_ctrl.text),
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
          ),
        ],
      ),
    );
  }
}
