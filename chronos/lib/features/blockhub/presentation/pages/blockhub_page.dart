import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/text_theme.dart';
import 'buy/buy_btc_page.dart';
import 'bitcoin_detail_page.dart';
import 'panther_ai_insights_page.dart';
import '../widgets/more_options_modal.dart';
import 'onboarding/blockhub_welcome_page.dart';
import 'onboarding/setup_wallet_page.dart';

class BlockHubPage extends StatefulWidget {
  const BlockHubPage({super.key});

  @override
  State<BlockHubPage> createState() => _BlockHubPageState();
}

class _BlockHubPageState extends State<BlockHubPage> {
  bool _isLoading = true;
  bool _hasCheckedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Only check onboarding status once when the page first loads
    if (_hasCheckedOnboarding) {
      setState(() => _isLoading = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('blockhub_onboarding_completed') ?? false;
    final hasCompletedWalletSetup =
        prefs.getBool('blockhub_wallet_setup_completed') ?? false;

    _hasCheckedOnboarding = true;

    if (!hasCompletedOnboarding && mounted) {
      // Navigate to onboarding using root navigator (hides bottom nav)
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => const BlockHubWelcomePage()),
      );
      // After returning, just show the page (don't check again)
      setState(() => _isLoading = false);
    } else if (!hasCompletedWalletSetup && mounted) {
      // Navigate to wallet setup using root navigator (hides bottom nav)
      await Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (context) => const SetupWalletPage()));
      // After returning, just show the page (don't check again)
      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoading = false);
    }
  }

  final List<CryptoAsset> _watchlist = [
    CryptoAsset(
      name: 'Bitcoin',
      symbol: 'BTC',
      price: 67.43,
      change: 2.34,
      isPositive: true,
    ),
    CryptoAsset(
      name: 'Ethereum',
      symbol: 'ETH',
      price: 67.43,
      change: 2.34,
      isPositive: true,
    ),
    CryptoAsset(
      name: 'Solana',
      symbol: 'SOL',
      price: 67.43,
      change: 2.34,
      isPositive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          // Background Image (only visible in dark sections)
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          // White overlay for top section (covers status bar + header + portfolio)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).padding.top,
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // White background container for all content including header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        // Header (now with white background)
                        Padding(
                          padding: EdgeInsets.all(horizontalPadding),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu,
                                color: Colors.grey[700],
                                size: 24,
                              ),
                              const Spacer(),
                              Text(
                                'BlockHub',
                                style: TextStyles.titleLarge.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 20 : 24,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 10 : 16),

                        // Portfolio Card
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          padding: EdgeInsets.only(
                            top: isSmallScreen ? 20 : 24,
                            left: isSmallScreen ? 20 : 24,
                            right: isSmallScreen ? 20 : 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Total Portfolio Value',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.visibility_outlined,
                                    color: Colors.grey[700],
                                    size: 26,
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              Column(
                                children: [
                                  Text(
                                    '\$24,521.83',
                                    style: TextStyles.headlineLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 28 : 32,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 6 : 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallScreen ? 6 : 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '24H Change: +\$2,521.83 (+11.6%)',
                                      style: TextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF10B981),
                                        fontWeight: FontWeight.w600,
                                        fontSize: isSmallScreen ? 10 : 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 16 : 20),

                              // Portfolio Chart
                              Image.asset(
                                'assets/Frame blochub.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 24),

                        // Action Buttons
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildActionButton(
                                Icons.add,
                                'Buy',
                                isSmallScreen,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BuyBtcPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildActionButton(
                                Icons.trending_down,
                                'Sell',
                                isSmallScreen,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const BitcoinDetailPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildActionButton(
                                Icons.swap_horiz,
                                'Swap',
                                isSmallScreen,
                              ),
                              _buildActionButton(
                                Icons.send,
                                'Send',
                                isSmallScreen,
                              ),
                              _buildActionButton(
                                Icons.more_horiz,
                                'More',
                                isSmallScreen,
                                onTap: () {
                                  MoreOptionsModal.show(context);
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 28 : 32),
                      ],
                    ),
                  ),

                  // Top Movers Section - Full Width Dark Container
                  Container(
                    width: double.infinity, // edge-to-edge
                    margin: EdgeInsets.zero, // No margin for full width
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Movers',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),

                        // Crypto Icons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCryptoIconDark(
                              'assets/ethereum.png',
                              false,
                              isSmallScreen,
                            ),
                            _buildCryptoIconDark(
                              'assets/btc.png',
                              true,
                              isSmallScreen,
                            ),
                            _buildCryptoIconDark(
                              'assets/solana.png',
                              false,
                              isSmallScreen,
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 12 : 16),

                        // Bitcoin Price (highlighted)
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'BTC',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),

                              Text(
                                'Bitcoin',
                                style: TextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 6 : 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$28,291',
                                    style: TextStyles.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 20 : 24,
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? 6 : 8),
                                  Text(
                                    '-0.25%',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 13 : 14,
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

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Watchlist Section (keeping dark theme)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      // Darker background to match image
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Watchlist',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),

                        ..._watchlist.map(
                          (asset) => _buildWatchlistItem(asset, isSmallScreen),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Panther AI Insights
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Color(0xFF7C3AED).withValues(alpha: 0.5),
                      // gradient: const LinearGradient(
                      //   colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      // ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Text(
                              'Panther AI Insights',
                              style: TextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 12),
                        Text(
                          'BTC volatility increased by 8% today. Consider smaller position sizes and dollar-cost averaging for entry.',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const PantherAiInsightsPage(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'View AI Insights',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    bool isSmallScreen, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 44 : 48,
            height: isSmallScreen ? 44 : 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Icon(
              icon,
              color: Colors.grey[700],
              size: isSmallScreen ? 18 : 20,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.grey[600],
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoIcon(
    String assetPath,
    bool isHighlighted,
    bool isSmallScreen,
  ) {
    return Container(
      width: isSmallScreen ? 56 : 60,
      height: isSmallScreen ? 56 : 60,
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isHighlighted
                ? Colors.orange.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
        border: Border.all(
          color:
              isHighlighted
                  ? Colors.orange
                  : Colors.grey.withValues(alpha: 0.3),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Image.asset(
        assetPath,
        width: isSmallScreen ? 36 : 40,
        height: isSmallScreen ? 36 : 40,
      ),
    );
  }

  Widget _buildCryptoIconDark(
    String assetPath,
    bool isHighlighted,
    bool isSmallScreen,
  ) {
    // Make highlighted (BTC) icon larger
    final containerSize =
        isHighlighted
            ? (isSmallScreen ? 100.0 : 100.0)
            : (isSmallScreen ? 56.0 : 60.0);
    final imageSize =
        isHighlighted
            ? (isSmallScreen ? 100.0 : 100.0)
            : (isSmallScreen ? 36.0 : 40.0);
    final padding =
        isHighlighted
            ? (isSmallScreen ? 5.0 : 7.0)
            : (isSmallScreen ? 5.0 : 7.0);

    return Container(
      width: containerSize,
      height: containerSize,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: isHighlighted ? 3 : 1,
        ),

        // Add shadow for highlighted icon
      ),
      child: Image.asset(assetPath, width: imageSize, height: imageSize),
    );
  }

  Widget _buildWatchlistItem(CryptoAsset asset, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Crypto Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Icon(
              _getCryptoIcon(asset.symbol),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Name and Symbol
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  asset.symbol,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Price and Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${asset.price.toStringAsFixed(2)}k',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${asset.isPositive ? '+' : ''}${asset.change.toStringAsFixed(2)}%',
                style: TextStyles.bodySmall.copyWith(
                  color:
                      asset.isPositive ? const Color(0xFF10B981) : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCryptoColor(String symbol) {
    switch (symbol) {
      case 'BTC':
        return Colors.orange;
      case 'ETH':
        return Colors.blue;
      case 'SOL':
        return const Color(0xFF9945FF);
      default:
        return Colors.white;
    }
  }

  IconData _getCryptoIcon(String symbol) {
    switch (symbol) {
      case 'BTC':
        return Icons.currency_bitcoin;
      case 'ETH':
        return Icons.diamond;
      case 'SOL':
        return Icons.wb_sunny;
      default:
        return Icons.currency_bitcoin;
    }
  }
}

class CryptoAsset {
  final String name;
  final String symbol;
  final double price;
  final double change;
  final bool isPositive;

  CryptoAsset({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.isPositive,
  });
}

class PortfolioChartPainter extends CustomPainter {
  final bool isSmallScreen;

  PortfolioChartPainter({required this.isSmallScreen});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - (isSmallScreen ? 8 : 10);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSmallScreen ? 6 : 8;

    // Draw colored segments to match the image exactly
    // Yellow-green segment (largest - top right)
    paint.color = const Color(0xFFBEF264); // Light green-yellow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.2,
      2.0,
      false,
      paint,
    );

    // Orange segment (medium - right)
    paint.color = const Color(0xFFF59E0B); // Bright orange
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.8,
      1.5,
      false,
      paint,
    );

    // Purple segment (smallest - bottom)
    paint.color = const Color(0xFF8B5CF6); // Purple
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.3,
      1.0,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniChartPainter extends CustomPainter {
  final bool isPositive;

  MiniChartPainter({required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isPositive ? const Color(0xFF10B981) : Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();

    // Simple zigzag pattern
    if (isPositive) {
      path.moveTo(0, size.height);
      path.lineTo(size.width * 0.3, size.height * 0.7);
      path.lineTo(size.width * 0.6, size.height * 0.4);
      path.lineTo(size.width, size.height * 0.1);
    } else {
      path.moveTo(0, size.height * 0.3);
      path.lineTo(size.width * 0.3, size.height * 0.5);
      path.lineTo(size.width * 0.6, size.height * 0.8);
      path.lineTo(size.width, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
