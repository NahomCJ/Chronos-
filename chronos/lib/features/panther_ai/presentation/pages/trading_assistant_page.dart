import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';

class TradingAssistantPage extends StatefulWidget {
  const TradingAssistantPage({super.key});

  @override
  State<TradingAssistantPage> createState() => _TradingAssistantPageState();
}

class _TradingAssistantPageState extends State<TradingAssistantPage> {
  static const _background = Color(0xFFF5F6FA);
  static const _cardBorder = Color(0xFFE8EAF0);
  static const _primaryText = Color(0xFF1A1A2E);
  static const _secondaryText = Color(0xFF6B7080);
  static const _purple = Color(0xFF7C6EF0);
  static const _green = Color(0xFF22C55E);
  static const _amber = Color(0xFFF59E0B);
  static const _blue = Color(0xFF3B82F6);
  static const _red = Color(0xFFEF4444);
  static const _buttonPrimary = Color(0xFF1F2937);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarketOverviewStrip(),
                const SizedBox(height: 20),
                _buildActiveSignalsSection(),
                const SizedBox(height: 20),
                _buildMarketConditionsSection(),
                const SizedBox(height: 20),
                _buildChrisRecommendationCard(),
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
        'Trading Assistant',
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

  Widget _buildMarketOverviewStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Overview',
          style: TextStyles.titleMedium.copyWith(
            color: _primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMarketCard(
                symbol: 'BTC',
                price: '\$67,400',
                change: '+2.1%',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMarketCard(
                symbol: 'ETH',
                price: '\$3,890',
                change: '+1.8%',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMarketCard(
                symbol: 'SPX',
                price: '5,280',
                change: '-0.3%',
                isPositive: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketCard({
    required String symbol,
    required String price,
    required String change,
    required bool isPositive,
  }) {
    final changeColor = isPositive ? _green : _red;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            symbol,
            style: TextStyles.labelMedium.copyWith(
              color: _secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyles.bodyMedium.copyWith(
              color: _primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeColor,
                size: 10,
              ),
              const SizedBox(width: 2),
              Text(
                change,
                style: TextStyles.labelSmall.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSignalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Signals',
          style: TextStyles.titleMedium.copyWith(
            color: _primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _buildSignalCard(
          name: 'ETH Long Entry',
          type: 'Long',
          confidence: 87,
          accentColor: _green,
          badgeLabel: 'Strong',
        ),
        const SizedBox(height: 10),
        _buildSignalCard(
          name: 'BTC Accumulation',
          type: 'Long',
          confidence: 74,
          accentColor: _green,
          badgeLabel: 'Moderate',
        ),
        const SizedBox(height: 10),
        _buildSignalCard(
          name: 'AAPL Put',
          type: 'Option',
          confidence: 65,
          accentColor: _amber,
          badgeLabel: 'Cautious',
        ),
        const SizedBox(height: 10),
        _buildSignalCard(
          name: 'SPX Hedge',
          type: 'Short',
          confidence: 71,
          accentColor: _blue,
          badgeLabel: 'Hedge',
        ),
      ],
    );
  }

  Widget _buildSignalCard({
    required String name,
    required String type,
    required int confidence,
    required Color accentColor,
    required String badgeLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Colored left border accent
          Container(
            width: 4,
            height: 88,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyles.bodyMedium.copyWith(
                          color: _primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyles.labelSmall.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              type,
                              style: TextStyles.labelSmall.copyWith(
                                color: _secondaryText,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: confidence / 100,
                            backgroundColor: const Color(0xFFF3F4F6),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(accentColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$confidence% confidence',
                        style: TextStyles.labelSmall.copyWith(
                          color: _secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'View signal →',
                        style: TextStyles.labelSmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
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

  Widget _buildMarketConditionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Conditions',
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
              _buildConditionRow(
                label: 'Trend',
                value: 'Bullish',
                valueColor: _green,
                icon: Icons.trending_up,
                iconColor: _green,
              ),
              Divider(color: _cardBorder, height: 20),
              _buildConditionRow(
                label: 'Volatility',
                value: 'Low',
                valueColor: _blue,
                icon: Icons.waves,
                iconColor: _blue,
              ),
              Divider(color: _cardBorder, height: 20),
              _buildConditionRow(
                label: 'Volume',
                value: 'Above Avg',
                valueColor: _purple,
                icon: Icons.bar_chart,
                iconColor: _purple,
              ),
              Divider(color: _cardBorder, height: 20),
              _buildConditionRow(
                label: 'Sentiment',
                value: 'Neutral',
                valueColor: _amber,
                icon: Icons.sentiment_neutral,
                iconColor: _amber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionRow({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: _secondaryText,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: valueColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            value,
            style: TextStyles.labelSmall.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChrisRecommendationCard() {
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
                "Chris's Recommendation",
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
                  'AI Signal',
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
            'Current market conditions favor a cautious approach. The bullish trend is intact, but low volatility suggests a potential breakout is coming. I recommend scaling into ETH long positions at current levels, while keeping 15-20% in cash as a hedge. Avoid overleveraging ahead of macro data this week.',
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
                    'Full Analysis',
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
