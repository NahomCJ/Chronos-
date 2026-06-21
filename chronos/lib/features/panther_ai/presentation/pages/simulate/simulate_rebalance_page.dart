import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/router/route_constants.dart';

class SimulateRebalancePage extends StatefulWidget {
  const SimulateRebalancePage({super.key});

  @override
  State<SimulateRebalancePage> createState() => _SimulateRebalancePageState();
}

class _SimulateRebalancePageState extends State<SimulateRebalancePage> {
  String selectedStrategy = 'moderate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A))),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 7),
                        _buildPortfolioComparison(),
                        const SizedBox(height: 24),
                        _buildStrategySelection(),
                        const SizedBox(height: 24),
                        _buildRequiredTrades(),
                        const SizedBox(height: 24),
                        _buildEstimatedImpact(),
                        const SizedBox(height: 24),
                        _buildTaxConsiderations(),
                        const SizedBox(height: 24),
                        _buildActionButtons(context),
                        const SizedBox(height: 100),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rebalance Simulation',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              Text(
                'AI-powered optimization',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFFA1A1A1),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioComparison() {
    return Row(
      children: [
        Expanded(child: _buildPortfolioCard('Current', 62, Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildPortfolioCard('Target', 45, Colors.green)),
      ],
    );
  }

  Widget _buildPortfolioCard(String label, int riskScore, Color riskColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          // Pie chart placeholder
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  const Color(0xFFF0B100),
                  const Color(0xFF00D4FF),
                  const Color(0xFF05DF72),
                  const Color(0xFFF0B100),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Risk Score: $riskScore',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: riskColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Strategy',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 11),
        _buildStrategyOption(
          'conservative',
          'Conservative',
          'Low Risk',
          'Lower risk, higher stability',
          '8-12%',
          'Low',
          const Color(0x3300C950),
          const Color(0xFF05DF72),
        ),
        const SizedBox(height: 7),
        _buildStrategyOption(
          'moderate',
          'Moderate',
          'Medium Risk',
          'Balanced risk and growth',
          '12-18%',
          'Medium',
          const Color(0x33F0B100),
          const Color(0xFFFDC700),
        ),
        const SizedBox(height: 7),
        _buildStrategyOption(
          'aggressive',
          'Aggressive',
          'High Risk',
          'Higher risk, maximum growth',
          '18-25%',
          'High',
          const Color(0x33FB2C36),
          const Color(0xFFFF6467),
        ),
      ],
    );
  }

  Widget _buildStrategyOption(
    String value,
    String title,
    String riskLabel,
    String description,
    String expectedReturn,
    String volatility,
    Color badgeColor,
    Color badgeTextColor,
  ) {
    final isSelected = selectedStrategy == value;
    return GestureDetector(
      onTap: () => setState(() => selectedStrategy = value),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFDC8F4A) : Colors.transparent,
            width: isSelected ? 1 : 0.61,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? badgeColor
                        : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.auto_awesome,
                color:
                    isSelected
                        ? badgeTextColor
                        : Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          riskLabel,
                          style: TextStyles.bodySmall.copyWith(
                            color: badgeTextColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFFA1A1A1),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expected Return',
                              style: TextStyles.bodySmall.copyWith(
                                color: const Color(0xFFA1A1A1),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              expectedReturn,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volatility',
                              style: TextStyles.bodySmall.copyWith(
                                color: const Color(0xFFA1A1A1),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              volatility,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
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

  Widget _buildRequiredTrades() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Trades',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 11),
        _buildTradeItem(
          Icons.arrow_downward,
          'Sell BTC',
          '0.08 BTC',
          '\$3,406',
          const Color(0x33FB2C36),
          const Color(0xFFFF6467),
        ),
        const SizedBox(height: 8),
        _buildTradeItem(
          Icons.arrow_upward,
          'Buy ETH',
          '0.45 ETH',
          '\$1,105',
          const Color(0x3300C950),
          const Color(0xFF05DF72),
        ),
        const SizedBox(height: 8),
        _buildTradeItem(
          Icons.arrow_upward,
          'Buy USDC',
          '6,000 USDC',
          '\$6,000',
          const Color(0x3300C950),
          const Color(0xFF05DF72),
        ),
      ],
    );
  }

  Widget _buildTradeItem(
    IconData icon,
    String title,
    String amount,
    String value,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFFA1A1A1),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedImpact() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Impact',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 11),
          _buildImpactRow(
            'Risk Reduction',
            '62 → 45 (-27%)',
            const Color(0xFF05DF72),
          ),
          const SizedBox(height: 11),
          _buildImpactRow('Trading Fees', '~\$18.50', Colors.white),
          const SizedBox(height: 11),
          _buildImpactRow('Execution Time', '~3 minutes', Colors.white),
          const SizedBox(height: 11),
          _buildImpactRow('AI Confidence', '89%', const Color(0xFF00D4FF)),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodyMedium.copyWith(
            color: const Color(0xFFA1A1A1),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTaxConsiderations() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x7FF0B100), width: 4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF0B100),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tax Considerations',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selling assets may trigger capital gains taxes. Consult with a tax advisor before proceeding.',
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFFA1A1A1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.push(RouteConstants.rebalanceConfirmation.toPath);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB0B0B0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0x7F05DF72), width: 0.74),
              ),
              elevation: 0,
            ),
            child: Text(
              'Execute Rebalance',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // TODO: View full analysis
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
                width: 0.74,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'View Full Analysis',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
                width: 0.74,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
