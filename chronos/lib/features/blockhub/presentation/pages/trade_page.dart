import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';
import 'trending_assets_page.dart';
import 'top_gainers_page.dart';
import 'top_losers_page.dart';

class TradePage extends StatelessWidget {
  const TradePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, isSmallScreen),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // Trade Options
                        _buildTradeOption(
                          context,
                          icon: Icons.trending_up,
                          title: 'Trending Assets',
                          subtitle: 'Most searched today',
                          iconColor: Colors.white,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const TrendingAssetsPage(),
                                ),
                              ),
                          isSmallScreen: isSmallScreen,
                        ),

                        const SizedBox(height: 16),

                        _buildTradeOption(
                          context,
                          icon: Icons.trending_up,
                          title: 'Top Gainers',
                          subtitle: '24h performance leaders',
                          iconColor: Colors.white,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TopGainersPage(),
                                ),
                              ),
                          isSmallScreen: isSmallScreen,
                        ),

                        const SizedBox(height: 16),

                        _buildTradeOption(
                          context,
                          icon: Icons.trending_down,
                          title: 'Top Losers',
                          subtitle: '24h performance decliners',
                          iconColor: Colors.white,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TopLosersPage(),
                                ),
                              ),
                          isSmallScreen: isSmallScreen,
                        ),
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

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Trade',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 15 : 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
