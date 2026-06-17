import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';
import 'nft_analytics_page.dart';

class NftPnlPage extends StatefulWidget {
  const NftPnlPage({super.key});

  @override
  State<NftPnlPage> createState() => _NftPnlPageState();
}

class _NftPnlPageState extends State<NftPnlPage> {
  String _filter = 'All';
  final _filters = ['All', 'Profitable', 'Loss', 'Break Even'];

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
                        _buildTotalCard(),
                        const SizedBox(height: 14),
                        _buildFilterTabs(),
                        const SizedBox(height: 14),
                        _buildNftPnlList(),
                        const SizedBox(height: 20),
                        _buildIndividualPerformance(),
                        const SizedBox(height: 16),
                        _buildSummaryStats(),
                        const SizedBox(height: 24),
                        _buildBottomButtons(context),
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
          Text(
            'Unrealized P&L',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Unrealized P&L',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '+1.20 ETH',
                style: TextStyles.titleLarge.copyWith(
                  color: const Color(0xFF22C55E),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.trending_up, color: Color(0xFF22C55E), size: 28),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$2880.00',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '2 Profitable',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '1 Loss',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            _filters.map((f) {
              final sel = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        sel
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    f,
                    style: TextStyles.bodySmall.copyWith(
                      color:
                          sel
                              ? Colors.black
                              : Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNftPnlList() {
    final items = [
      _PnlItem(
        'Chromatic #1234',
        'Chromatic Dreams',
        '2.2 ETH',
        '2.8 ETH',
        '+27.3%',
        true,
        'assets/Chromatic Dreams.png',
      ),
      _PnlItem(
        'Holographic #9012',
        'Holographic Futures',
        '2.2 ETH',
        '2.8 ETH',
        '+27.3%',
        true,
        'assets/MarketplaceHome.png',
      ),
      _PnlItem(
        'Abstract #3456',
        'Abstract Dimensions',
        '2.2 ETH',
        '2.8 ETH',
        '-8.3%',
        false,
        'assets/Abstract Dimensions.png',
      ),
    ];

    final filtered =
        _filter == 'All'
            ? items
            : _filter == 'Profitable'
            ? items.where((i) => i.isPositive).toList()
            : _filter == 'Loss'
            ? items.where((i) => !i.isPositive).toList()
            : items;

    return Column(
      children:
          filtered
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPnlCard(item),
                ),
              )
              .toList(),
    );
  }

  Widget _buildPnlCard(_PnlItem item) {
    final color =
        item.isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.imagePath,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 22,
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
                  item.name,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.collection,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _miniStat('Cost', item.cost),
                    const SizedBox(width: 16),
                    _miniStat('Current', item.current),
                    const SizedBox(width: 16),
                    _miniStat('P&L', item.pnl, color: color),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.pnl,
                  style: TextStyles.bodySmall.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                item.isPositive ? Icons.trending_up : Icons.trending_down,
                color: color,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodySmall.copyWith(
            color: color ?? Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualPerformance() {
    final items = [
      _IndivItem(
        'Chromatic #1234',
        'Chromatic Dreams',
        '+27.3%',
        '+0.60 ETH',
        true,
        'assets/Chromatic Dreams.png',
      ),
      _IndivItem(
        'Holographic #9012',
        'Holographic Futures',
        '+25.0%',
        '+0.70 ETH',
        true,
        'assets/MarketplaceHome.png',
      ),
      _IndivItem(
        'Abstract #3456',
        'Abstract Dimensions',
        '-8.3%',
        '-0.10 ETH',
        false,
        'assets/Abstract Dimensions.png',
      ),
    ];

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
            'Individual Performance',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            final c =
                e.value.isPositive
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          e.value.imagePath,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  size: 18,
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
                              e.value.name,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              e.value.collection,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.45),
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
                            e.value.pct,
                            style: TextStyles.bodySmall.copyWith(
                              color: c,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            e.value.eth,
                            style: TextStyles.bodySmall.copyWith(
                              color: c,
                              fontSize: 11,
                            ),
                          ),
                        ],
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
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final rows = [
      ('Best Performer', '+27.3%', const Color(0xFF22C55E)),
      ('Worst Performer', '-8.3%', const Color(0xFFEF4444)),
      ('Average Return', '14.6%', Colors.white),
      ('Win Rate', '67%', Colors.white),
    ];

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
            'Summary Statistics',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.value.$1,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        e.value.$2,
                        style: TextStyles.bodyMedium.copyWith(
                          color: e.value.$3,
                          fontSize: 13,
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
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NftAnalyticsPage()),
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Text(
              'View Analytics',
              style: TextStyles.labelMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            child: Text(
              'Back to Portfolio',
              style: TextStyles.labelMedium.copyWith(
                fontSize: 14,
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

class _PnlItem {
  final String name, collection, cost, current, pnl, imagePath;
  final bool isPositive;
  const _PnlItem(
    this.name,
    this.collection,
    this.cost,
    this.current,
    this.pnl,
    this.isPositive,
    this.imagePath,
  );
}

class _IndivItem {
  final String name, collection, pct, eth, imagePath;
  final bool isPositive;
  const _IndivItem(
    this.name,
    this.collection,
    this.pct,
    this.eth,
    this.isPositive,
    this.imagePath,
  );
}
