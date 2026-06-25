import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';

class PortfolioIntelligencePage extends StatefulWidget {
  const PortfolioIntelligencePage({super.key});

  @override
  State<PortfolioIntelligencePage> createState() =>
      _PortfolioIntelligencePageState();
}

class _PortfolioIntelligencePageState extends State<PortfolioIntelligencePage> {
  static const _background = Color(0xFFF5F6FA);
  static const _cardBorder = Color(0xFFE8EAF0);
  static const _primaryText = Color(0xFF1A1A2E);
  static const _secondaryText = Color(0xFF6B7080);
  static const _purple = Color(0xFF7C6EF0);
  static const _green = Color(0xFF22C55E);
  static const _amber = Color(0xFFF59E0B);
  static const _buttonPrimary = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 20),
                _buildAllocationSection(),
                const SizedBox(height: 20),
                _buildPerformanceSection(),
                const SizedBox(height: 20),
                _buildHoldingsSection(),
                const SizedBox(height: 20),
                _buildChrisInsightCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF374151),
              size: 20,
            ),
          ),
        ),
      ),
      title: Text(
        'Portfolio Intelligence',
        style: TextStyles.titleMedium.copyWith(
          color: _primaryText,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _cardBorder),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Portfolio Value',
            style: TextStyles.bodySmall.copyWith(
              color: _secondaryText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$45,890',
            style: TextStyles.titleLarge.copyWith(
              color: _primaryText,
              fontSize: 38,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward, color: _green, size: 14),
                const SizedBox(width: 4),
                Text(
                  '+12.4% (+\$5,072)',
                  style: TextStyles.bodySmall.copyWith(
                    color: _green,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: _cardBorder, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat('AI Status', 'Stable'),
              _buildHeroStat('Risk Level', 'Low'),
              _buildHeroStat('Health Score', '78/100'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: _secondaryText,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyles.bodyMedium.copyWith(
            color: _primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Allocation',
          style: TextStyles.titleMedium.copyWith(
            color: _primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAllocationRow('Stocks', 45, const Color(0xFF3B82F6)),
              const SizedBox(height: 14),
              _buildAllocationRow('Bonds', 20, _amber),
              const SizedBox(height: 14),
              _buildAllocationRow('Crypto', 25, _purple),
              const SizedBox(height: 14),
              _buildAllocationRow('Cash', 10, _green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationRow(String label, int percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: _secondaryText,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 36,
          child: Text(
            '$percent%',
            textAlign: TextAlign.right,
            style: TextStyles.bodySmall.copyWith(
              color: _primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '6-Month Performance',
          style: TextStyles.titleMedium.copyWith(
            color: _primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const _PerformanceChart(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPerfStat('Jan', '+3.2%', _green),
                  _buildPerfStat('Feb', '+1.8%', _green),
                  _buildPerfStat('Mar', '-0.9%', const Color(0xFFEF4444)),
                  _buildPerfStat('Apr', '+5.1%', _green),
                  _buildPerfStat('May', '+2.4%', _green),
                  _buildPerfStat('Jun', '+0.8%', _green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerfStat(String month, String change, Color color) {
    return Column(
      children: [
        Text(
          change,
          style: TextStyles.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          month,
          style: TextStyles.bodySmall.copyWith(
            color: _secondaryText,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Holdings',
          style: TextStyles.titleMedium.copyWith(
            color: _primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHoldingRow(
                symbol: 'BTC',
                name: 'Bitcoin',
                price: '\$67,400',
                change: '+8.2%',
                value: '\$16,850',
                isPositive: true,
                iconBg: const Color(0xFFFFF3E0),
                iconColor: _amber,
                iconLabel: '₿',
              ),
              Divider(color: _cardBorder, height: 1, indent: 16),
              _buildHoldingRow(
                symbol: 'ETH',
                name: 'Ethereum',
                price: '\$3,890',
                change: '+5.7%',
                value: '\$9,725',
                isPositive: true,
                iconBg: const Color(0xFFEDE7F6),
                iconColor: _purple,
                iconLabel: 'Ξ',
              ),
              Divider(color: _cardBorder, height: 1, indent: 16),
              _buildHoldingRow(
                symbol: 'AAPL',
                name: 'Apple Inc.',
                price: '\$192.40',
                change: '+1.3%',
                value: '\$9,620',
                isPositive: true,
                iconBg: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF3B82F6),
                iconLabel: 'A',
              ),
              Divider(color: _cardBorder, height: 1, indent: 16),
              _buildHoldingRow(
                symbol: 'MSFT',
                name: 'Microsoft',
                price: '\$415.20',
                change: '-0.4%',
                value: '\$8,304',
                isPositive: false,
                iconBg: const Color(0xFFE8F5E9),
                iconColor: _green,
                iconLabel: 'M',
              ),
              Divider(color: _cardBorder, height: 1, indent: 16),
              _buildHoldingRow(
                symbol: 'BOND',
                name: 'US Treasury Bonds',
                price: '\$98.50',
                change: '+0.2%',
                value: '\$1,391',
                isPositive: true,
                iconBg: const Color(0xFFFFF8E1),
                iconColor: _amber,
                iconLabel: '\$',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingRow({
    required String symbol,
    required String name,
    required String price,
    required String change,
    required String value,
    required bool isPositive,
    required Color iconBg,
    required Color iconColor,
    required String iconLabel,
  }) {
    final changeColor = isPositive ? _green : const Color(0xFFEF4444);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                iconLabel,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: TextStyles.fontFamily,
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
                  symbol,
                  style: TextStyles.bodyMedium.copyWith(
                    color: _primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyles.bodySmall.copyWith(
                    color: _secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyles.bodyMedium.copyWith(
                  color: _primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    price,
                    style: TextStyles.bodySmall.copyWith(
                      color: _secondaryText,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    change,
                    style: TextStyles.bodySmall.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChrisInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _purple.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: _purple,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Chris's Take",
                style: TextStyles.labelLarge.copyWith(
                  color: _purple,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'AI Insight',
                  style: TextStyles.labelSmall.copyWith(
                    color: _purple,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your portfolio is performing well with a 12.4% gain this period. However, your crypto allocation (25%) is slightly above the recommended range for your risk profile. Consider rebalancing BTC and ETH holdings if the market continues trending upward.',
            style: TextStyles.bodySmall.copyWith(
              color: _primaryText,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _purple,
                    side: BorderSide(color: _purple.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Simulate Rebalance',
                    style: TextStyles.labelMedium.copyWith(
                      color: _purple,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Ask Chris',
                    style: TextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Simple bar chart for 6-month performance
class _PerformanceChart extends StatelessWidget {
  const _PerformanceChart();

  @override
  Widget build(BuildContext context) {
    final data = [3.2, 1.8, -0.9, 5.1, 2.4, 0.8];
    const green = Color(0xFF22C55E);
    const red = Color(0xFFEF4444);
    const maxVal = 6.0;

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data.map((val) {
          final fraction = val.abs() / maxVal;
          final barHeight = (fraction * 64).clamp(4.0, 64.0);
          final color = val >= 0 ? green : red;
          return Container(
            width: 28,
            height: barHeight,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
