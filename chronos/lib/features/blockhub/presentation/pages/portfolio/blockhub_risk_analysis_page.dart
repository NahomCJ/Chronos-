import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

class BlockHubRiskAnalysisPage extends StatelessWidget {
  const BlockHubRiskAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          Positioned.fill(
            child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
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
                        _buildOverallRisk(),
                        const SizedBox(height: 16),
                        _buildAssetRiskBreakdown(),
                        const SizedBox(height: 16),
                        _buildCategoryExposure(),
                        const SizedBox(height: 16),
                        _buildRiskRecommendations(),
                        const SizedBox(height: 16),
                        _buildRiskManagementTips(),
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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Column(
            children: [
              Text(
                'Risk Analysis',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                'Portfolio Risk Assessment',
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

  Widget _buildOverallRisk() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
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
                color: Color(0xFFDC8F4A),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Overall Risk Profile',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '52/100',
                    style: TextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC8F4A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Medium Risk',
                      style: TextStyles.bodySmall.copyWith(
                        color: const Color(0xFFDC8F4A),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDC8F4A), width: 3),
                ),
                child: const Center(
                  child: Icon(
                    Icons.show_chart,
                    color: Color(0xFFDC8F4A),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _statBox('Volatility', '18.5%')),
              const SizedBox(width: 10),
              Expanded(child: _statBox('Sharpe Ratio', '1.42')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statBox('Max Drawdown', '-23.4%')),
              const SizedBox(width: 10),
              Expanded(child: _statBox('Beta vs Market', '0.87')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRiskBreakdown() {
    final assets = [
      _RiskAsset(
        'Bitcoin',
        '45% allocation',
        'Medium',
        const Color(0xFFDC8F4A),
        const Color(0xFFF7931A),
        0.45,
        '22% vol',
      ),
      _RiskAsset(
        'Ethereum',
        '30% allocation',
        'Medium-High',
        const Color(0xFFDC8F4A),
        const Color(0xFF627EEA),
        0.30,
        '28% vol',
      ),
      _RiskAsset(
        'Solana',
        '15% allocation',
        'High',
        const Color(0xFFEF4444),
        const Color(0xFF9945FF),
        0.15,
        '42% vol',
      ),
      _RiskAsset(
        'USDC',
        '10% allocation',
        'Low',
        const Color(0xFF22C55E),
        const Color(0xFF22C55E),
        0.10,
        '0.1% vol',
      ),
    ];

    return _card(
      'Asset Risk Breakdown',
      Column(
        children:
            assets
                .map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: a.iconColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  a.name[0],
                                  style: TextStyle(
                                    color: a.iconColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.name,
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    a.allocation,
                                    style: TextStyles.bodySmall.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.45,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: a.riskColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                a.risk,
                                style: TextStyles.bodySmall.copyWith(
                                  color: a.riskColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              a.vol,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: a.value,
                            minHeight: 5,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              a.iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCategoryExposure() {
    final cats = [
      _CatExposure('Layer 1', 'Medium', const Color(0xFFDC8F4A), 0.6, '60%'),
      _CatExposure('DeFi', 'High', const Color(0xFFEF4444), 0.2, '20%'),
      _CatExposure('Stablecoins', 'Low', const Color(0xFF22C55E), 0.1, '10%'),
      _CatExposure('AMC Assets', 'Medium', const Color(0xFFDC8F4A), 0.1, '10%'),
    ];

    return _card(
      'Category Exposure',
      Column(
        children:
            cats
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.name,
                              style: TextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: c.riskColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    c.risk,
                                    style: TextStyles.bodySmall.copyWith(
                                      color: c.riskColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  c.pct,
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: c.value,
                            minHeight: 5,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              c.riskColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildRiskRecommendations() {
    final recs = [
      _Rec(
        'High Volatility Concentration',
        'High',
        const Color(0xFFEF4444),
        '35% of your portfolio is in high-volatility assets. Consider rebalancing to reduce risk.',
      ),
      _Rec(
        'Diversification Opportunity',
        'Medium',
        const Color(0xFFDC8F4A),
        'Adding more stablecoin exposure could help reduce overall portfolio volatility.',
      ),
      _Rec(
        'Good Market Beta',
        'Low',
        const Color(0xFF22C55E),
        'Your portfolio has a beta of 0.87, providing slightly lower volatility than the market.',
      ),
    ];

    return _card(
      'Risk Recommendations',
      Column(
        children:
            recs
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: r.color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: r.color.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.title,
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: r.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  r.level,
                                  style: TextStyles.bodySmall.copyWith(
                                    color: r.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            r.desc,
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildRiskManagementTips() {
    final tips = [
      'Diversify across multiple asset classes to reduce concentration risk',
      'Set stop-loss orders to limit potential losses',
      'Regularly rebalance your portfolio to maintain target allocations',
      'Consider your time horizon and risk tolerance when making decisions',
      'Keep a portion of your portfolio in stable, low-volatility assets',
    ];

    return _card(
      'Risk Management Tips',
      Column(
        children:
            tips
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC8F4A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t,
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RiskAsset {
  final String name, allocation, risk, vol;
  final Color riskColor, iconColor;
  final double value;
  const _RiskAsset(
    this.name,
    this.allocation,
    this.risk,
    this.riskColor,
    this.iconColor,
    this.value,
    this.vol,
  );
}

class _CatExposure {
  final String name, risk, pct;
  final Color riskColor;
  final double value;
  const _CatExposure(
    this.name,
    this.risk,
    this.riskColor,
    this.value,
    this.pct,
  );
}

class _Rec {
  final String title, level, desc;
  final Color color;
  const _Rec(this.title, this.level, this.color, this.desc);
}
