import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/text_theme.dart';

class RiskAnalysisPage extends StatelessWidget {
  const RiskAnalysisPage({super.key});

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
            child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, isSmallScreen),

                  const SizedBox(height: 24),

                  // Overall Risk Profile
                  _buildOverallRiskProfile(isSmallScreen),

                  const SizedBox(height: 20),

                  // Asset Risk Breakdown
                  _buildAssetRiskBreakdown(isSmallScreen),

                  const SizedBox(height: 20),

                  // Category Exposure
                  _buildCategoryExposure(isSmallScreen),

                  const SizedBox(height: 20),

                  // Risk Recommendations
                  _buildRiskRecommendations(isSmallScreen),

                  const SizedBox(height: 20),

                  // Risk Management Tips
                  _buildRiskManagementTips(isSmallScreen),

                  const SizedBox(height: 100),
                ],
              ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Risk Analysis',
                style: TextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 18 : 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Portfolio Risk Assessment',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRiskProfile(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overall Risk Profile',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Circular Progress
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(100, 100),
                        painter: CircularProgressPainter(
                          progress: 0.52,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '52/100',
                            style: TextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Medium Risk',
                            style: TextStyles.bodySmall.copyWith(
                              color: const Color(0xFFF59E0B),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildMetricRow('Risk Score', '18.5%', isSmallScreen),
                      const SizedBox(height: 12),
                      _buildMetricRow('Volatility', '5.6/10', isSmallScreen),
                      const SizedBox(height: 12),
                      _buildMetricRow('Max Drawdown', '23.4%', isSmallScreen),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        'Risk-Adjusted Return',
                        '0.87',
                        isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: isSmallScreen ? 10 : 11,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 10 : 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetRiskBreakdown(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Asset Risk Breakdown',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAssetRiskItem(
              'Bitcoin',
              'BTC',
              'Medium',
              const Color(0xFFF59E0B),
              '35%',
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            _buildAssetRiskItem(
              'Ethereum',
              'ETH',
              'Medium-High',
              const Color(0xFF8B5CF6),
              '28%',
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            _buildAssetRiskItem(
              'Solana',
              'SOL',
              'High',
              const Color(0xFF3B82F6),
              '15%',
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            _buildAssetRiskItem(
              'USDC',
              'USDC',
              'Low',
              const Color(0xFF10B981),
              '22%',
              isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRiskItem(
    String name,
    String symbol,
    String risk,
    Color color,
    String percentage,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              symbol[0],
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                symbol,
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: isSmallScreen ? 10 : 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getRiskColor(risk).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            risk,
            style: TextStyles.bodySmall.copyWith(
              color: _getRiskColor(risk),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentage,
          style: TextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 12 : 13,
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String risk) {
    if (risk.contains('Low')) return const Color(0xFF10B981);
    if (risk.contains('High')) return Colors.red;
    return const Color(0xFFF59E0B);
  }

  Widget _buildCategoryExposure(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Category Exposure',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCategoryItem(
              'Layer 1',
              'Medium',
              60,
              const Color(0xFFF59E0B),
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            _buildCategoryItem('DeFi', 'High', 30, Colors.red, isSmallScreen),
            const SizedBox(height: 12),
            _buildCategoryItem(
              'Stablecoins',
              'Low',
              10,
              const Color(0xFF10B981),
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            _buildCategoryItem(
              'AMC Assets',
              'Medium',
              10,
              const Color(0xFFF59E0B),
              isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    String category,
    String risk,
    int percentage,
    Color color,
    bool isSmallScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    risk,
                    style: TextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 12 : 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskRecommendations(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Risk Recommendations',
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 15 : 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(
              Icons.warning_amber_rounded,
              'High Volatility Concentration',
              'Over 45% of your portfolio is in high-volatility assets. Consider rebalancing to reduce risk.',
              Colors.red,
              'High',
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              Icons.trending_up,
              'Diversification Opportunity',
              'Adding more asset classes could help reduce overall portfolio risk without sacrificing returns.',
              const Color(0xFF3B82F6),
              'Medium',
              isSmallScreen,
            ),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              Icons.check_circle_outline,
              'Great Market Beta',
              'Your portfolio has a healthy beta of 0.85, providing equity-level volatility with lower risk.',
              const Color(0xFF10B981),
              'Low',
              isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    IconData icon,
    String title,
    String description,
    Color color,
    String priority,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priority,
                        style: TextStyles.bodySmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: isSmallScreen ? 10 : 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskManagementTips(bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Management Tips',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 15 : 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              'Diversify across at least seven different assets',
              isSmallScreen,
            ),
            _buildTipItem('Rebalance your portfolio quarterly', isSmallScreen),
            _buildTipItem(
              'Set stop-loss orders to limit potential losses',
              isSmallScreen,
            ),
            _buildTipItem(
              'Keep 10-20% in stablecoins for stability',
              isSmallScreen,
            ),
            _buildTipItem(
              'Consider your time horizon and risk tolerance',
              isSmallScreen,
            ),
            _buildTipItem(
              'Use dollar-cost averaging for volatile assets',
              isSmallScreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: isSmallScreen ? 11 : 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8;

    canvas.drawCircle(center, radius - 4, bgPaint);

    // Progress arc
    final progressPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
