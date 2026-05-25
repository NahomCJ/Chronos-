import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/router/route_constants.dart';

class EthFlowSimulateRebalancePage extends StatefulWidget {
  const EthFlowSimulateRebalancePage({super.key});

  @override
  State<EthFlowSimulateRebalancePage> createState() =>
      _EthFlowSimulateRebalancePageState();
}

class _EthFlowSimulateRebalancePageState
    extends State<EthFlowSimulateRebalancePage> {
  String selectedStrategy = 'moderate';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildPortfolioComparison(),
                        const SizedBox(height: 22),
                        _buildStrategySelection(),
                        const SizedBox(height: 22),
                        _buildRequiredTrades(),
                        const SizedBox(height: 22),
                        _buildEstimatedImpact(),
                        const SizedBox(height: 16),
                        _buildTaxConsiderations(),
                        const SizedBox(height: 28),
                        _buildActionButtons(context),
                        const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Column(
            children: [
              Text(
                'Rebalance Simulation',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                'AI-powered optimization',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
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
        Expanded(
          child: _buildRiskCard(
            'Current',
            'Risk Score: 82',
            const Color(0xFFFF6467),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRiskCard(
            'Target',
            'Risk Score: 45',
            const Color(0xFF05DF72),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCard(String label, String riskText, Color riskColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            riskText,
            style: TextStyles.bodyMedium.copyWith(
              color: riskColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        _buildStrategyCard(
          'conservative',
          'Conservative',
          'Low Risk',
          'Lower risk, higher stability',
          '8-12%',
          'Low',
          const Color(0xFF05DF72),
          const Color(0xFF05DF72).withValues(alpha: 0.15),
        ),
        const SizedBox(height: 8),
        _buildStrategyCard(
          'moderate',
          'Moderate',
          'Medium Risk',
          'Balanced risk and growth',
          '12-18%',
          'Medium',
          const Color(0xFFF0B100),
          const Color(0xFFF0B100).withValues(alpha: 0.15),
        ),
        const SizedBox(height: 8),
        _buildStrategyCard(
          'aggressive',
          'Aggressive',
          'High Risk',
          'Higher risk, maximum growth',
          '18-25%',
          'High',
          const Color(0xFFFF6467),
          const Color(0xFFFF6467).withValues(alpha: 0.15),
        ),
      ],
    );
  }

  Widget _buildStrategyCard(
    String value,
    String title,
    String riskLabel,
    String description,
    String expectedReturn,
    String volatility,
    Color accentColor,
    Color iconBg,
  ) {
    final isSelected = selectedStrategy == value;
    return GestureDetector(
      onTap: () => setState(() => selectedStrategy = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFFDC8F4A)
                    : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.2 : 0.6,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isSelected ? iconBg : Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                color:
                    isSelected
                        ? accentColor
                        : Colors.white.withValues(alpha: 0.4),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          riskLabel,
                          style: TextStyles.bodySmall.copyWith(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expected Return',
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              expectedReturn,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              volatility,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              _buildTradeRow(
                Icons.south_west,
                'Sell BTC',
                '0.08 BTC',
                '\$3,406',
                const Color(0xFFFF6467),
                const Color(0xFFFF6467).withValues(alpha: 0.15),
                false,
              ),
              _buildTradeRow(
                Icons.north_east,
                'Buy ETH',
                '0.45 ETH',
                '\$1,105',
                const Color(0xFF05DF72),
                const Color(0xFF05DF72).withValues(alpha: 0.15),
                false,
              ),
              _buildTradeRow(
                Icons.north_east,
                'Buy USDC',
                '6,000 USDC',
                '\$6,000',
                const Color(0xFF05DF72),
                const Color(0xFF05DF72).withValues(alpha: 0.15),
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTradeRow(
    IconData icon,
    String title,
    String amount,
    String value,
    Color iconColor,
    Color iconBg,
    bool isLast,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      amount,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.06),
            height: 1,
            thickness: 0.5,
            indent: 14,
            endIndent: 14,
          ),
      ],
    );
  }

  Widget _buildEstimatedImpact() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Impact',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          _buildImpactRow(
            'Risk Reduction',
            '62 → 45 (-27%)',
            const Color(0xFF05DF72),
            false,
          ),
          _buildImpactRow('Trading Fees', '~\$18.50', Colors.white, false),
          _buildImpactRow('Execution Time', '~3 minutes', Colors.white, false),
          _buildImpactRow(
            'AI Confidence',
            '89%',
            const Color(0xFF00D4FF),
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow(
    String label,
    String value,
    Color valueColor,
    bool isLast,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13.5,
                ),
              ),
              Text(
                value,
                style: TextStyles.bodyMedium.copyWith(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.06),
            height: 1,
            thickness: 0.5,
          ),
      ],
    );
  }

  Widget _buildTaxConsiderations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0B100).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF0B100).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFF0B100).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF0B100).withValues(alpha: 0.5),
              ),
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                  color: Color(0xFFF0B100),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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
                  'Tax Considerations',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selling assets may trigger capital gains taxes. Consult with a tax advisor before proceeding.',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12.5,
                    height: 1.45,
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
            onPressed:
                () =>
                    context.push(RouteConstants.ethFlowRebalanceSuccess.toPath),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Text(
              'Execute Rebalance',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                () => context.push(RouteConstants.fullPortfolioAnalysis.toPath),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            child: Text(
              'View Full Analysis',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
