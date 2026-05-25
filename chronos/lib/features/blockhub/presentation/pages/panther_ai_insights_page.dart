import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';

class PantherAiInsightsPage extends StatelessWidget {
  const PantherAiInsightsPage({super.key});

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

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // Market Overview Section
                        _buildSection(
                          'Market Overview',
                          Column(
                            children: [
                              _buildBullishMomentumCard(isSmallScreen),
                              const SizedBox(height: 12),
                              _buildElevatedVolatilityCard(isSmallScreen),
                            ],
                          ),
                          isSmallScreen,
                        ),

                        const SizedBox(height: 28),

                        // Current Market Conditions
                        _buildSection(
                          'Current Market Conditions',
                          _buildMarketConditionsTable(isSmallScreen),
                          isSmallScreen,
                        ),

                        const SizedBox(height: 28),

                        // About Section
                        _buildSection(
                          'About',
                          _buildAboutCard(isSmallScreen),
                          isSmallScreen,
                        ),

                        const SizedBox(height: 28),

                        // Sector Heatmap
                        _buildSection(
                          'Sector Heatmap',
                          _buildSectorHeatmap(isSmallScreen),
                          isSmallScreen,
                        ),

                        const SizedBox(height: 28),

                        // Risk Alerts
                        _buildSection(
                          'Risk Alerts',
                          _buildRiskAlertsContent(isSmallScreen),
                          isSmallScreen,
                        ),

                        const SizedBox(height: 20),

                        // Disclaimer
                        _buildDisclaimer(isSmallScreen),

                        const SizedBox(height: 100),

                        // Disclaimer
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panther AI Insights',
                  style: TextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Market Intelligence & Analysis',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title, isSmallScreen),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isSmallScreen) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 15 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBullishMomentumCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bullish Momentum',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Market cap increased 3.2% in 24h. Large-cap assets showing strong support levels.',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedVolatilityCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elevated Volatility',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Volatility index increased 18% from weekly average. Consider smaller position sizes for new entries.',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketConditionsTable(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),

      child: Column(
        children: [
          _buildConditionRow('Trend', 'Bullish', Colors.green, isSmallScreen),
          const SizedBox(height: 10),
          _buildConditionRow('Volatility', 'High', Colors.red, isSmallScreen),
          const SizedBox(height: 10),
          _buildConditionRow(
            'Liquidity Health',
            'Good',
            Colors.green,
            isSmallScreen,
          ),
          const SizedBox(height: 10),
          _buildConditionRow(
            'Fear & Greed Index',
            '62 (Greed)',
            const Color(0xFFF59E0B),
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionRow(
    String label,
    String value,
    Color valueColor,
    bool isSmallScreen,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: isSmallScreen ? 12 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 12 : 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard(bool isSmallScreen) {
    return Container(
      child: Text(
        'The first decentralized cryptocurrency, created by Satoshi Nakamoto.',
        style: TextStyles.bodyMedium.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.5,
          fontSize: isSmallScreen ? 12 : 13,
        ),
      ),
    );
  }

  Widget _buildSectorHeatmap(bool isSmallScreen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildHeatmapTile(
                'Large Caps',
                '+5.2%',
                true,
                isSmallScreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHeatmapTile('DeFi', '+3.8%', true, isSmallScreen),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHeatmapTile(
                'Layer 2',
                '-1.2%',
                false,
                isSmallScreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHeatmapTile(
                'AMC Assets',
                '+1.1%',
                true,
                isSmallScreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeatmapTile(
    String label,
    String percentage,
    bool isPositive,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color:
            isPositive
                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                : const Color(0xFFEF4444).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isPositive
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isSmallScreen ? 11 : 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percentage,
            style: TextStyles.titleMedium.copyWith(
              color: isPositive ? const Color(0xFF10B981) : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAlertsContent(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRiskAlertCard(
          'High Volatility Period',
          'Consider limit orders instead of market orders to avoid slippage.',
          isSmallScreen,
        ),
        const SizedBox(height: 12),
        _buildRiskAlertCard(
          'Weekend Trading',
          'Liquidity typically decreases on weekends, which can increase price volatility.',
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildRiskAlertsSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFF59E0B),
              size: isSmallScreen ? 16 : 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Risk Alerts',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 15 : 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRiskAlertCard(
          'High Volatility Period',
          'Consider limit orders instead of market orders to avoid slippage.',
          isSmallScreen,
        ),
        const SizedBox(height: 12),
        _buildRiskAlertCard(
          'Weekend Trading',
          'Liquidity typically decreases on weekends, which can increase price volatility.',
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildRiskAlertCard(
    String title,
    String description,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF92400E).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
              fontSize: isSmallScreen ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disclaimer:',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 10 : 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI insights are for informational purposes only and should not be considered financial advice. Always conduct your own research and consider your risk tolerance before making investment decisions.',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.4,
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
