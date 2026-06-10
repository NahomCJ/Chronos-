import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';

class CardData {
  final String cardType;
  final String cardNumber;
  final String expiryDate;
  final String balance;
  final String backgroundImage;
  final List<Color> gradientColors;

  const CardData({
    required this.cardType,
    required this.cardNumber,
    required this.expiryDate,
    required this.balance,
    required this.backgroundImage,
    required this.gradientColors,
  });
}

class InteractiveWalletCarousel extends StatefulWidget {
  final List<CardData>? cards;

  const InteractiveWalletCarousel({super.key, this.cards});

  @override
  State<InteractiveWalletCarousel> createState() =>
      _InteractiveWalletCarouselState();
}

class _InteractiveWalletCarouselState extends State<InteractiveWalletCarousel>
    with TickerProviderStateMixin {
  late AnimationController _liftController;
  late AnimationController _flipController;
  late Animation<double> _liftAnim;
  late Animation<double> _flipAnim;

  bool _isLifted = false;
  int _activeIndex = 0;
  bool _flipInProgress = false;

  static final List<CardData> _defaultCards = [
    const CardData(
      cardType: 'Virtual Card',
      cardNumber: '**** 7777',
      expiryDate: 'EXP: 04/26',
      balance: '\$1,250.50',
      backgroundImage: 'assets/image2.png',
      gradientColors: [Color(0xFF4FC3C3), Color(0xFF1A7A7A)],
    ),
    const CardData(
      cardType: 'Debit Card',
      cardNumber: '**** 8888',
      expiryDate: 'EXP: 08/27',
      balance: '\$3,450.25',
      backgroundImage: 'assets/image1.jpg',
      gradientColors: [Color(0xFF6B9FE4), Color(0xFF1A4A9E)],
    ),
  ];

  List<CardData> get _cards => widget.cards ?? _defaultCards;

  @override
  void initState() {
    super.initState();

    _liftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _liftAnim = CurvedAnimation(
      parent: _liftController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _liftController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _toggleLift() {
    if (_isLifted) {
      _liftController.reverse();
    } else {
      _liftController.forward();
    }
    setState(() => _isLifted = !_isLifted);
  }

  Future<void> _flipToNext() async {
    if (_flipInProgress || _cards.length <= 1) return;
    setState(() => _flipInProgress = true);

    await _flipController.forward(from: 0);
    setState(() {
      _activeIndex = (_activeIndex + 1) % _cards.length;
    });
    await _flipController.reverse();

    setState(() => _flipInProgress = false);

    // Auto-close lift after navigating
    if (_isLifted) {
      _liftController.reverse();
      setState(() => _isLifted = false);
    }
  }

  Future<void> _flipToPrev() async {
    if (_flipInProgress || _cards.length <= 1) return;
    setState(() => _flipInProgress = true);

    await _flipController.forward(from: 0);
    setState(() {
      _activeIndex = (_activeIndex - 1 + _cards.length) % _cards.length;
    });
    await _flipController.reverse();

    setState(() => _flipInProgress = false);

    if (_isLifted) {
      _liftController.reverse();
      setState(() => _isLifted = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32.0;
    final cardHeight = cardWidth / 1.586;
    final extraHeight = (_cards.length - 1) * 22.0;
    // Wallet body below cards
    const walletBottomHeight = 72.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _cards.length > 1 ? _toggleLift : null,
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -300) {
            _flipToNext();
          } else if ((details.primaryVelocity ?? 0) > 300) {
            _flipToPrev();
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_liftAnim, _flipAnim]),
          builder: (context, _) {
            return _buildWalletContainer(
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              extraHeight: extraHeight,
              walletBottomHeight: walletBottomHeight,
            );
          },
        ),
      ),
    );
  }

  Widget _buildWalletContainer({
    required double cardWidth,
    required double cardHeight,
    required double extraHeight,
    required double walletBottomHeight,
  }) {
    final totalHeight = cardHeight + extraHeight + walletBottomHeight;

    return SizedBox(
      width: cardWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Wallet case background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: cardHeight * 0.55 + extraHeight + walletBottomHeight,
            child: _buildWalletBody(cardWidth),
          ),

          // Cards in the wallet
          ..._buildCardStack(
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            extraHeight: extraHeight,
          ),

          // Bottom wallet controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: walletBottomHeight,
            child: _buildWalletControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBody(double cardWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F1840),
            Color(0xFF3D2F7E),
            Color(0xFF2A2060),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F1840).withValues(alpha: 0.55),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Inner wallet pocket shadow (depth effect)
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Subtle stitching border effect
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCardStack({
    required double cardWidth,
    required double cardHeight,
    required double extraHeight,
  }) {
    final int count = _cards.length;
    final List<Widget> stack = [];

    // Render from back to front using visual slots relative to active index.
    // slot 0 = active (front), slot count-1 = furthest behind.
    for (int slot = count - 1; slot >= 0; slot--) {
      final int cardIndex = (_activeIndex + slot) % count;
      final bool isActiveSlot = slot == 0;

      // Active card: sits at the top position (top=0).
      // Back cards: peek at increasing downward offsets.
      final double peekOffset = extraHeight - ((count - 1 - slot) * 22.0);
      double cardTopOffset;
      if (isActiveSlot && _isLifted) {
        cardTopOffset = -(_liftAnim.value * cardHeight * 0.38);
      } else {
        cardTopOffset = peekOffset;
      }

      // Flip angle applies only to the active slot during a swipe.
      final double flipAngle =
          (isActiveSlot && _flipInProgress) ? _flipAnim.value * math.pi : 0.0;

      stack.add(
        Positioned(
          top: cardTopOffset,
          left: 0,
          right: 0,
          height: cardHeight,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(flipAngle),
            child: flipAngle > math.pi / 2
                ? _buildCardFaceBack(cardWidth, cardHeight)
                : _buildCard(
                    card: _cards[cardIndex],
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    isActive: isActiveSlot,
                    slot: slot,
                  ),
          ),
        ),
      );
    }

    return stack;
  }

  Widget _buildCard({
    required CardData card,
    required double cardWidth,
    required double cardHeight,
    required bool isActive,
    required int slot,
  }) {
    final opacity = isActive ? 1.0 : math.max(0.5, 1.0 - slot * 0.2);
    final scale = isActive ? 1.0 : math.max(0.9, 1.0 - slot * 0.025);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isActive ? 0.3 : 0.15),
                blurRadius: isActive ? 16 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    card.backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: card.gradientColors,
                        ),
                      ),
                    ),
                  ),
                ),
                // Dark overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                // Card content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.cardType,
                                style: TextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                          // NFC icon
                          Icon(
                            Icons.contactless_outlined,
                            color: Colors.white.withValues(alpha: 0.75),
                            size: 22,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Chip icon
                      Container(
                        width: 38,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        card.cardNumber,
                        style: TextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            card.expiryDate,
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            card.balance,
                            style: TextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _buildCardFaceBack(double cardWidth, double cardHeight) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D2944), Color(0xFF5B4E9E)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Card indicator dots
          Row(
            children: List.generate(_cards.length, (i) {
              final bool isActive = i == _activeIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          // Hint text
          if (_cards.length > 1)
            Text(
              _isLifted ? 'Swipe to switch' : 'Tap to lift',
              style: TextStyles.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
