import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';

class MarketIntelligencePage extends StatelessWidget {
  const MarketIntelligencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.15))),
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
                        _buildMarketMoodCard(),
                        const SizedBox(height: 22),
                        _buildAffectsPortfolio(),
                        const SizedBox(height: 22),
                        _buildTopMovers(),
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
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF374151), size: 20),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Market Intelligence',
                style: TextStyles.titleMedium.copyWith(
                  color: const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                'Real-time AI analysis',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF6B7080),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketMoodCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market Mood',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF6B7080),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bullish',
                style: TextStyles.titleMedium.copyWith(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Volatility',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF6B7080),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Medium-High',
                style: TextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF22C55E), Color(0xFFA3E635)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'AI Confidence',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF6B7080),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '87%',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF22C55E),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAffectsPortfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Affects Your Portfolio',
          style: TextStyles.titleMedium.copyWith(
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          Icons.error_outline,
          const Color(0xFFEF4444),
          'BTC volatility rising',
          'Affects 34% of your portfolio value',
          '-2.4% (24h) • High impact',
          const Color(0xFFEF4444),
        ),
        const SizedBox(height: 10),
        _buildAlertCard(
          Icons.trending_up,
          const Color(0xFF22C55E),
          'ETH momentum building',
          'Strong buying pressure detected',
          '+5.8% (24h) • 89% confidence',
          const Color(0xFF22C55E),
        ),
        const SizedBox(height: 10),
        _buildAlertCard(
          Icons.warning_amber_rounded,
          const Color(0xFFF59E0B),
          'AMC earnings tomorrow',
          'Token may react to earnings report',
          'Watch closely • Feb 4, 9:00 AM',
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    String impact,
    Color impactColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF1A1A2E),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyles.bodySmall.copyWith(
                        color: const Color(0xFF6B7080),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      impact,
                      style: TextStyles.bodySmall.copyWith(
                        color: impactColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: const Color(0xFF374151),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    'View asset',
                    style: TextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8EAF0)),
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  color: Color(0xFF6B7080),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopMovers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Movers',
          style: TextStyles.titleMedium.copyWith(
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EAF0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMoverRow(
                'BTC',
                'Bitcoin',
                '\$42,890',
                '-2.4%',
                const Color(0xFF0EA5E9),
                const Color(0xFFEF4444),
                false,
              ),
              _buildMoverRow(
                'ETH',
                'Ethereum',
                '\$2,340',
                '+5.8%',
                const Color(0xFF0EA5E9),
                const Color(0xFF22C55E),
                false,
              ),
              _buildMoverRow(
                'SOL',
                'Solana',
                '\$98.50',
                '+12.3%',
                const Color(0xFF0EA5E9),
                const Color(0xFF22C55E),
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoverRow(
    String symbol,
    String name,
    String price,
    String change,
    Color iconBg,
    Color changeColor,
    bool isLast,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    symbol,
                    style: const TextStyle(
                      color: Colors.white,
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
                      name,
                      style: TextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF1A1A2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      price,
                      style: TextStyles.bodySmall.copyWith(
                        color: const Color(0xFF6B7080),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    change.startsWith('-')
                        ? Icons.trending_down
                        : Icons.trending_up,
                    color: changeColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    change,
                    style: TextStyles.bodyMedium.copyWith(
                      color: changeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            color: Color(0xFFE8EAF0),
            height: 1,
            thickness: 0.5,
            indent: 14,
            endIndent: 14,
          ),
      ],
    );
  }
}
