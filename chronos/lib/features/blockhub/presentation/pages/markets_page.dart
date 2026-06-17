import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';
import 'crypto_markets_page.dart';
import 'top_gainers_page.dart';
import 'top_losers_page.dart';
import 'trending_assets_page.dart';

class MarketsPage extends StatelessWidget {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                        _buildStatCards(),
                        const SizedBox(height: 16),
                        _buildNavCard(
                          context,
                          icon: Icons.currency_bitcoin,
                          iconBg: const Color(0xFFF59E0B),
                          title: 'Crypto Markets',
                          subtitle: 'BTC, ETH, SOL & more',
                          badge: '6 gainers',
                          badgeColor: const Color(0xFF10B981),
                          badge2: '2 losers',
                          badge2Color: const Color(0xFFEF4444),
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CryptoMarketsPage(),
                                ),
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildNavCard(
                          context,
                          icon: Icons.receipt_long,
                          iconBg: const Color(0xFF3B82F6),
                          title: 'AMC / Tokenized Assets',
                          subtitle: 'Stocks, ETFs & Commodities',
                          badge: 'Tokenized · Backed 1:1',
                          badgeColor: const Color(0xFF3B82F6),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const _AmcPage()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNavCard(
                          context,
                          icon: Icons.local_fire_department_outlined,
                          iconBg: const Color(0xFFEC4899),
                          title: 'Trending Assets',
                          subtitle: 'Most searched today',
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TrendingAssetsPage(),
                                ),
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildGainersLosers(context),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          Text(
            'Markets',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(child: _statCard('Market Cap', '\$2.45T', '+3.2%', true)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('24h Volume', '\$89.5B', '-1.8%', false)),
      ],
    );
  }

  Widget _statCard(String label, String value, String change, bool isPositive) {
    final color =
        isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyles.bodySmall.copyWith(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    String? badge2,
    Color? badge2Color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _pill(badge, badgeColor!),
                        if (badge2 != null) ...[
                          const SizedBox(width: 8),
                          _pill(badge2, badge2Color!),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.4),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyles.bodySmall.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGainersLosers(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TopGainersPage()),
                ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Top Gainers',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '24h performance',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TopLosersPage()),
                ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                    ),
                    child: const Icon(
                      Icons.trending_down,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Top Losers',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '24h performance',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}

// ── AMC / Tokenized Assets page ───────────────────────────────────────────────
class _AmcPage extends StatelessWidget {
  const _AmcPage();

  static const _assets = [
    ('AAPL', 'Apple Inc.', '\$189.42', '+1.24%', true, Color(0xFF3B82F6)),
    ('TSLA', 'Tesla', '\$248.87', '+3.56%', true, Color(0xFF8B5CF6)),
    ('GOLD', 'Gold', '\$2,341.10', '+0.38%', true, Color(0xFFF59E0B)),
    ('SPY', 'S&P 500 ETF', '\$521.73', '+0.89%', true, Color(0xFF10B981)),
    ('AMZN', 'Amazon', '\$184.12', '-0.71%', false, Color(0xFFEC4899)),
    ('NVDA', 'NVIDIA', '\$875.40', '+5.12%', true, Color(0xFF06B6D4)),
    ('OIL', 'Crude Oil', '\$82.34', '-1.20%', false, Color(0xFFEF4444)),
    ('BRK', 'Berkshire', '\$398.50', '+0.45%', true, Color(0xFF6366F1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))])),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      Text('Tokenized Assets', style: TextStyles.titleLarge.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,
                      )),
                    ],
                  ),
                ),
                // Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.verified_outlined, color: Color(0xFF3B82F6), size: 16),
                      const SizedBox(width: 8),
                      Text('All assets are tokenized and backed 1:1',
                          style: TextStyles.bodySmall.copyWith(color: const Color(0xFF93C5FD), fontSize: 12)),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: _assets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final a = _assets[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: a.$6.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: a.$6.withValues(alpha: 0.35)),
                              ),
                              child: Center(
                                child: Text(a.$1.substring(0, a.$1.length > 3 ? 3 : a.$1.length),
                                    style: TextStyle(color: a.$6, fontWeight: FontWeight.w800, fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                  Text(a.$2, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(a.$3, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (a.$5 ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(a.$4, style: TextStyle(
                                    color: a.$5 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                  )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
