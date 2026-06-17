import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/widgets/fluid_glass.dart';

enum _HistoryCategory { all, transfers, exchange, crypto, nft, tickpay }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  _HistoryCategory _activeCategory = _HistoryCategory.all;

  static const _bg = Color(0xFFF5F5F5);
  static const _cardBg = Colors.white;
  static const _accent = Color(0xFF1A1A2E);

  static const _categories = [
    (_HistoryCategory.all, 'All'),
    (_HistoryCategory.transfers, 'Transfers'),
    (_HistoryCategory.exchange, 'Exchange'),
    (_HistoryCategory.crypto, 'Crypto'),
    (_HistoryCategory.nft, 'NFT'),
    (_HistoryCategory.tickpay, 'TickPay'),
  ];

  // Sample data - in production this would come from the API
  static final List<_HistoryItem> _allItems = [
    _HistoryItem(
      category: _HistoryCategory.transfers,
      icon: Icons.arrow_upward_rounded,
      iconBg: const Color(0xFF1A1A2E),
      title: 'Transfer to Marcus',
      subtitle: 'Today, 2:34 PM',
      amount: '-\$500.00',
      isPositive: false,
    ),
    _HistoryItem(
      category: _HistoryCategory.transfers,
      icon: Icons.arrow_downward_rounded,
      iconBg: const Color(0xFF10B981),
      title: 'Received from Sarah',
      subtitle: 'Today, 11:20 AM',
      amount: '+\$1,200.00',
      isPositive: true,
    ),
    _HistoryItem(
      category: _HistoryCategory.exchange,
      icon: Icons.swap_horiz_rounded,
      iconBg: const Color(0xFF3B82F6),
      title: 'USD → EUR Exchange',
      subtitle: 'Yesterday, 4:15 PM',
      amount: '-\$300.00',
      isPositive: false,
      detail: 'Rate: 1 USD = 0.92 EUR',
    ),
    _HistoryItem(
      category: _HistoryCategory.crypto,
      icon: Icons.currency_bitcoin,
      iconBg: const Color(0xFFF59E0B),
      title: 'Bought Bitcoin',
      subtitle: 'Yesterday, 10:00 AM',
      amount: '-\$200.00',
      isPositive: false,
      detail: '0.00297 BTC',
    ),
    _HistoryItem(
      category: _HistoryCategory.crypto,
      icon: Icons.currency_bitcoin,
      iconBg: const Color(0xFF10B981),
      title: 'Sold Ethereum',
      subtitle: 'Jun 15, 3:22 PM',
      amount: '+\$850.00',
      isPositive: true,
      detail: '0.224 ETH',
    ),
    _HistoryItem(
      category: _HistoryCategory.nft,
      icon: Icons.collections_rounded,
      iconBg: const Color(0xFF8B5CF6),
      title: 'NFT Purchase',
      subtitle: 'Jun 14, 1:05 PM',
      amount: '-\$420.00',
      isPositive: false,
      detail: 'CryptoArt #1042',
    ),
    _HistoryItem(
      category: _HistoryCategory.nft,
      icon: Icons.collections_rounded,
      iconBg: const Color(0xFF10B981),
      title: 'NFT Sale',
      subtitle: 'Jun 13, 9:45 AM',
      amount: '+\$680.00',
      isPositive: true,
      detail: 'PixelDude #88',
    ),
    _HistoryItem(
      category: _HistoryCategory.tickpay,
      icon: Icons.confirmation_number_rounded,
      iconBg: const Color(0xFFEC4899),
      title: 'TickPay — Apple AirPods',
      subtitle: 'Jun 12, 7:30 PM',
      amount: '-\$59.99',
      isPositive: false,
      detail: 'Installment 1 of 4',
    ),
    _HistoryItem(
      category: _HistoryCategory.transfers,
      icon: Icons.arrow_upward_rounded,
      iconBg: const Color(0xFF1A1A2E),
      title: 'Add Money via Bank',
      subtitle: 'Jun 10, 12:00 PM',
      amount: '+\$2,000.00',
      isPositive: true,
    ),
  ];

  List<_HistoryItem> get _filtered => _activeCategory == _HistoryCategory.all
      ? _allItems
      : _allItems.where((i) => i.category == _activeCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          _buildGlassHeader(context),
          _buildCategoryBar(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildGlassHeader(BuildContext context) {
    return FluidGlass.light(
      borderRadius: BorderRadius.zero,
      blur: 12,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: _accent.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _accent, size: 16),
            ),
          ),
          const Expanded(
            child: Text(
              'History',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _accent, fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: _accent.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.filter_list_rounded,
                  color: _accent, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      color: _accent,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _categories.map((c) {
                final isActive = _activeCategory == c.$1;
                return GestureDetector(
                  onTap: () => setState(() => _activeCategory = c.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c.$2,
                      style: TextStyle(
                        color: isActive ? _accent : Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildItem(items[i]),
    );
  }

  Widget _buildItem(_HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: item.iconBg, shape: BoxShape.circle),
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyles.titleSmall.copyWith(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
                const SizedBox(height: 3),
                Text(item.subtitle,
                    style: TextStyles.bodySmall.copyWith(color: const Color(0xFF888888), fontSize: 11)),
                if (item.detail != null) ...[
                  const SizedBox(height: 2),
                  Text(item.detail!,
                      style: TextStyles.bodySmall.copyWith(color: const Color(0xFF999999), fontSize: 11)),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: item.isPositive ? const Color(0xFF10B981) : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFFCCCCCC), size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryItem {
  final _HistoryCategory category;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final String? detail;

  const _HistoryItem({
    required this.category,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    this.detail,
  });
}
