import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_constants.dart';

class _SearchItem {
  final String title;
  final String category;
  final IconData icon;
  final RouteConstants route;
  const _SearchItem(this.title, this.category, this.icon, this.route);
}

const _allItems = [
  // Finance
  _SearchItem('Transfer Money', 'Finance', Icons.arrow_upward, RouteConstants.transfer),
  _SearchItem('Add Money', 'Finance', Icons.add, RouteConstants.addMoney),
  _SearchItem('Exchange', 'Finance', Icons.swap_horiz, RouteConstants.exchange),
  _SearchItem('Wallet', 'Finance', Icons.wallet, RouteConstants.wallet),
  // TickPay
  _SearchItem('TickPay Dashboard', 'TickPay', Icons.dashboard, RouteConstants.tickpayDashboard),
  _SearchItem('TickPay Shop', 'TickPay', Icons.shopping_bag, RouteConstants.tickpayDiscover),
  _SearchItem('TickPay Orders', 'TickPay', Icons.receipt_long, RouteConstants.tickpayOrderHistory),
  _SearchItem('TickPay Payments', 'TickPay', Icons.payments, RouteConstants.tickpayUpcomingPayments),
  _SearchItem('TickPay Rewards', 'TickPay', Icons.card_giftcard, RouteConstants.tickpayRewards),
  _SearchItem('TickPay Credit', 'TickPay', Icons.credit_score, RouteConstants.tickpayCreditOverview),
  // Crypto / BlockHub
  _SearchItem('BlockHub', 'Crypto', Icons.hub, RouteConstants.blockHub),
  // AI
  _SearchItem('Panther AI', 'AI', Icons.psychology, RouteConstants.pantherAi),
  _SearchItem('Chris AI Chat', 'AI', Icons.chat_bubble, RouteConstants.pantherAiChat),
  // Profile
  _SearchItem('Profile & Settings', 'Account', Icons.person, RouteConstants.profile),
];

// Routes that use push (overlay)  everything else uses go (tab swap)
const _pushRoutes = {
  RouteConstants.addMoney,
  RouteConstants.profile,
  RouteConstants.pantherAiChat,
  RouteConstants.tickpayDashboard,
  RouteConstants.tickpayDiscover,
  RouteConstants.tickpayOrderHistory,
  RouteConstants.tickpayUpcomingPayments,
  RouteConstants.tickpayRewards,
  RouteConstants.tickpayCreditOverview,
};

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<_SearchItem> _filtered = List.of(_allItems);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    final q = _controller.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(_allItems);
      } else {
        _filtered = _allItems
            .where((item) =>
                item.title.toLowerCase().contains(q) ||
                item.category.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  void _navigate(_SearchItem item) {
    if (_pushRoutes.contains(item.route)) {
      context.push(item.route.toPath);
    } else {
      context.go(item.route.toPath);
    }
  }

  // Group items by category preserving insertion order
  Map<String, List<_SearchItem>> get _grouped {
    final map = <String, List<_SearchItem>>{};
    for (final item in _filtered) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final categories = grouped.keys.toList();

    // Build a flat list of category headers + items for the ListView
    final List<Object> rows = [];
    for (final cat in categories) {
      rows.add(cat); // header
      rows.addAll(grouped[cat]!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                  ),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search services, features...',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 15),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF6C5CE7), size: 20),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.white.withValues(alpha: 0.5),
                                      size: 18),
                                  onPressed: () => _controller.clear(),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Results ──────────────────────────────────────────────
            Expanded(
              child: rows.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        if (row is String) {
                          return _buildCategoryHeader(row);
                        }
                        return _buildItemTile(row as _SearchItem);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF6C5CE7).withValues(alpha: 0.9),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildItemTile(_SearchItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigate(item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF13132A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon,
                    color: const Color(0xFF6C5CE7), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.25), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              color: Colors.white.withValues(alpha: 0.2), size: 56),
          const SizedBox(height: 16),
          Text(
            'No results for "${_controller.text}"',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 15),
          ),
        ],
      ),
    );
  }
}
