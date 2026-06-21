import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';

class WalletOnboardingPage extends StatefulWidget {
  const WalletOnboardingPage({super.key});

  @override
  State<WalletOnboardingPage> createState() => _WalletOnboardingPageState();
}

class _WalletOnboardingPageState extends State<WalletOnboardingPage>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late Animation<double> _floatAnim;
  late Animation<double> _shimmerAnim;

  static const _pages = [
    _OnboardingSlide(
      tag: 'WALLET',
      title: 'Take Control\nof Your Money',
      subtitle:
          'Track spending, plan smarter, and stay one step ahead — every day.',
      accentColor: Color(0xFF6C5CE7),
    ),
    _OnboardingSlide(
      tag: 'YOUR CARDS',
      title: 'All Your Cards,\nOne Wallet',
      subtitle:
          'Add debit and credit cards. Tap to lift a card, swipe to flip between them.',
      accentColor: Color(0xFF4FC3C3),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _getStarted();
    }
  }

  void _getStarted() {
    context.go(RouteConstants.wallet.toPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.15))),
          // Background radial glow
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, _) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.1 + _floatAnim.value * 0.5,
                left: MediaQuery.of(context).size.width * 0.2,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _pages[_currentPage].accentColor.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, i) {
              return _buildSlide(context, i);
            },
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(BuildContext context, int index) {
    final slide = _pages[index];
    return Column(
      children: [
        // Card illustration area
        Expanded(
          flex: 6,
          child: _buildCardIllustration(index),
        ),

        // Text content
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: slide.accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: slide.accentColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    slide.tag,
                    style: TextStyles.labelSmall.copyWith(
                      color: slide.accentColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  slide.title,
                  style: TextStyles.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    fontSize: 32,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  slide.subtitle,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildCardIllustration(int index) {
    if (index == 0) {
      return _buildPage1Illustration();
    }
    return _buildPage2Illustration();
  }

  Widget _buildPage1Illustration() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardW = screenWidth * 0.72;
    final cardH = cardW / 1.586;

    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Back card (teal) — slightly offset and rotated
            Transform.translate(
              offset: Offset(-20, _floatAnim.value * 0.6 + 30),
              child: Transform.rotate(
                angle: -0.12,
                child: _buildIllustrationCard(
                  width: cardW,
                  height: cardH,
                  gradientColors: const [Color(0xFF2EC4B6), Color(0xFF0A7E74)],
                  cardType: 'Debit Card',
                  cardNumber: '**** 0958',
                  expiry: 'EXP: 02/28',
                ),
              ),
            ),
            // Front card (blue/purple) — slightly elevated
            Transform.translate(
              offset: Offset(10, _floatAnim.value * -0.6 - 10),
              child: Transform.rotate(
                angle: 0.06,
                child: _buildIllustrationCard(
                  width: cardW,
                  height: cardH,
                  gradientColors: const [Color(0xFF6C5CE7), Color(0xFF2D2944)],
                  cardType: 'Debit Card',
                  cardNumber: '**** 4568',
                  expiry: 'EXP: 05/27',
                  showVisa: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPage2Illustration() {
    final screenWidth = MediaQuery.of(context).size.width;
    final walletW = screenWidth * 0.78;
    final cardW = walletW * 0.86;
    final cardH = cardW / 1.586;

    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnim, _shimmerAnim]),
      builder: (context, _) {
        return Center(
          child: SizedBox(
            width: walletW,
            height: cardH * 1.5,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Wallet body
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: cardH * 0.7,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1F1840), Color(0xFF3D2F7E)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D2F7E).withValues(alpha: 0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // Back card peeking
                Positioned(
                  top: cardH * 0.14,
                  left: walletW * 0.07,
                  right: walletW * 0.07,
                  height: cardH,
                  child: _buildIllustrationCard(
                    width: cardW,
                    height: cardH,
                    gradientColors: const [Color(0xFF2EC4B6), Color(0xFF0A7E74)],
                    cardType: 'Debit Card',
                    cardNumber: '**** 0958',
                    expiry: 'EXP: 02/28',
                    opacity: 0.7,
                  ),
                ),

                // Front card lifted
                Positioned(
                  top: _floatAnim.value * 0.5,
                  left: walletW * 0.07,
                  right: walletW * 0.07,
                  height: cardH,
                  child: _buildIllustrationCard(
                    width: cardW,
                    height: cardH,
                    gradientColors: const [Color(0xFF6C5CE7), Color(0xFF2D2944)],
                    cardType: 'Debit Card',
                    cardNumber: '**** 4568',
                    expiry: 'EXP: 05/27',
                    showVisa: true,
                  ),
                ),

                // Shimmer overlay on front card
                Positioned(
                  top: _floatAnim.value * 0.5,
                  left: walletW * 0.07,
                  right: walletW * 0.07,
                  height: cardH,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Transform.translate(
                      offset: Offset(_shimmerAnim.value * cardW, 0),
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIllustrationCard({
    required double width,
    required double height,
    required List<Color> gradientColors,
    required String cardType,
    required String cardNumber,
    required String expiry,
    bool showVisa = false,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cardType,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                Icon(
                  Icons.contactless_outlined,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 34,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.credit_card, color: Colors.white, size: 14),
            ),
            const SizedBox(height: 8),
            Text(
              cardNumber,
              style: TextStyles.titleSmall.copyWith(
                color: Colors.white,
                letterSpacing: 2,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expiry,
                  style: TextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
                if (showVisa)
                  Text(
                    'VISA',
                    style: TextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final bool isLast = _currentPage == _pages.length - 1;
    final accentColor = _pages[_currentPage].accentColor;

    return Container(
      padding: EdgeInsets.fromLTRB(
        32,
        20,
        32,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: GestureDetector(
              onTap: _nextPage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Get Started' : 'Next',
                      style: TextStyles.titleMedium.copyWith(
                        color: const Color(0xFF0D0B1E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF0D0B1E),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Skip button (only on first page)
          if (!isLast)
            TextButton(
              onPressed: _getStarted,
              child: Text(
                'Skip',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String tag;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _OnboardingSlide({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}
