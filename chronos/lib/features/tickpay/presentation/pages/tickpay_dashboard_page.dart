import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../bloc/tickpay_account_cubit.dart';
import '../bloc/tickpay_account_state.dart';
import '../utils/tickpay_media.dart';
import 'chris_shopping_page.dart';

// ---------------------------------------------------------------------------
// Design constants
// ---------------------------------------------------------------------------
const _kBorder = Color(0x1AFFFFFF); // white 10%

const _kBrandLogos = <String, String>{
  'amazon':   'https://logo.clearbit.com/amazon.com',
  'nike':     'https://logo.clearbit.com/nike.com',
  'apple':    'https://logo.clearbit.com/apple.com',
  'ikea':     'https://logo.clearbit.com/ikea.com',
  'samsung':  'https://logo.clearbit.com/samsung.com',
  'best buy': 'https://logo.clearbit.com/bestbuy.com',
  'adidas':   'https://logo.clearbit.com/adidas.com',
};

// Always use white background so dark/coloured logos are visible
Widget _brandBadge(String brand, [Color bg = Colors.white]) {
  final key = brand.toLowerCase();
  final entry = _kBrandLogos.entries.firstWhere(
    (e) => key.contains(e.key),
    orElse: () => const MapEntry('', ''),
  );
  final url = entry.value;
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, __) => _brandFallbackIcon(key),
              errorWidget: (_, __, ___) => _brandFallbackIcon(key),
            )
          : _brandFallbackIcon(key),
    ),
  );
}

Widget _brandFallbackIcon(String key) {
  if (key.contains('amazon')) {
    return Container(color: Colors.white,
      child: const Icon(Icons.shopping_cart, color: Color(0xFFFF9900), size: 26));
  }
  if (key.contains('nike')) {
    return Container(color: Colors.white,
      child: const Icon(Icons.check_circle, color: Colors.black87, size: 26));
  }
  return const Icon(Icons.shopping_bag_outlined, color: Color(0xFF8B5CF6), size: 22);
}

class TickPayDashboardPage extends StatefulWidget {
  const TickPayDashboardPage({super.key});

  @override
  State<TickPayDashboardPage> createState() => _TickPayDashboardPageState();
}

class _TickPayDashboardPageState extends State<TickPayDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TickpayAccountCubit, TickpayAccountState>(
      builder: (context, state) {
        final loaded = state is TickpayAccountLoaded ? state : null;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 90),
            child: ChrisHomeFab(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChrisShoppingPage()),
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: 0,
            onItemSelected: (i) {
              switch (i) {
                case 0: context.go(RouteConstants.home.toPath); break;
                case 1: context.go(RouteConstants.pantherAi.toPath); break;
                case 2: context.go(RouteConstants.blockHub.toPath); break;
              }
            },
          ),
          body: Stack(
            children: [
              Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
              // ── Content (fully scrollable) ────────────────────────────
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      _buildCreditCard(context, loaded),
                      const SizedBox(height: 20),
                      _buildQuickActions(context),
                      const SizedBox(height: 16),
                      // White section, rounds top, then extends to end
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        padding: const EdgeInsets.only(bottom: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductsSection(context),
                            const SizedBox(height: 20),
                            _buildActivePlans(context, loaded),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    final products = [
      ('Nike Air Max', '\$299', TickPayMedia.nikeShoes, '4 payments of \$74'),
      ('Wireless Headphones', '\$189', TickPayMedia.headphonesBlack, '3 payments of \$63'),
      ('Smart Watch', '\$349', TickPayMedia.appleWatch, '4 payments of \$87'),
      ('Fashion Dress', '\$129', TickPayMedia.fashionDress, '2 payments of \$64'),
      ('Coffee Maker', '\$219', TickPayMedia.coffeeMaker, '3 payments of \$73'),
      ('Gaming Controller', '\$79', TickPayMedia.gameController, '2 payments of \$39'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shop Now, Pay Later',
                  style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => context.push(RouteConstants.tickpayDiscover.toPath),
                child: const Text('Browse All',
                    style: TextStyle(color: Color(0xFFFF2D87), fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = products[i];
              return GestureDetector(
                onTap: () => context.push(RouteConstants.tickpayDiscover.toPath),
                child: Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: p.$3,
                          height: 100, width: double.infinity, fit: BoxFit.cover,
                          placeholder: (_, __) => Container(height: 100, color: Colors.grey.shade100),
                          errorWidget: (_, __, ___) => Container(height: 100, color: Colors.grey.shade100,
                              child: const Icon(Icons.image_outlined, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.$1, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text(p.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black)),
                            const SizedBox(height: 2),
                            Text(p.$4, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 9, color: Color(0xFFFF2D87), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good evening, Antonio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Tuesday, February 3',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(RouteConstants.tickpayAlerts.toPath),
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_none,
                      color: Colors.white, size: 20),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF2D87),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFDC8F4A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(
      BuildContext context, TickpayAccountLoaded? account) {
    final fmt = NumberFormat('#,##0.00');
    final available = account?.available ?? 0.0;
    final creditUsed = account?.creditUsed ?? 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push(RouteConstants.tickpayCreditOverview.toPath),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.22), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.40),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative glass circles
              Positioned(
                top: -35,
                right: -25,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -15,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC8F4A), Color(0xFFE8B06A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                height: 1,
                                color: Colors.black.withValues(alpha: 0.2)),
                            Container(
                                height: 1,
                                color: Colors.black.withValues(alpha: 0.2)),
                            Container(
                                height: 1,
                                color: Colors.black.withValues(alpha: 0.2)),
                          ],
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF2D87), Color(0xFFFF6EB4)],
                        ).createShader(bounds),
                        child: const Text(
                          'TickPay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Available Credit',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account == null ? '-' : '\$${fmt.format(available)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '•••• •••• •••• 4892',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          account == null
                              ? 'Used  -'
                              : 'Used  \$${fmt.format(creditUsed)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Valid until',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '05/34',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.shopping_bag_outlined, 'Shop', RouteConstants.tickpayDiscover.toPath, false),
      (Icons.payment_outlined, 'Pay', RouteConstants.tickpayRepayNow.toPath, false),
      (Icons.receipt_long_outlined, 'Purchases', RouteConstants.tickpayOrderHistory.toPath, false),
      (Icons.replay_outlined, 'Repayments', RouteConstants.tickpayUpcomingPayments.toPath, false),
      (Icons.savings_outlined, 'Rewards', RouteConstants.tickpayRewards.toPath, false),
    ];
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, i) {
          final isAi = actions[i].$4;
          return GestureDetector(
            onTap: () => context.push(actions[i].$3),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isAi
                        ? const Color(0xFF14B8A6).withValues(alpha: 0.30)
                        : Colors.black.withValues(alpha: 0.30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAi
                          ? const Color(0xFF14B8A6).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.30),
                      width: isAi ? 1.2 : 0.8,
                    ),
                  ),
                  child: Icon(actions[i].$1,
                      color: isAi ? const Color(0xFF14B8A6) : Colors.white,
                      size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  actions[i].$2,
                  style: TextStyle(
                    color: isAi
                        ? const Color(0xFF14B8A6)
                        : Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: isAi ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static (IconData, Color) _brandInfo(String merchant) {
    final m = merchant.toLowerCase();
    if (m.contains('amazon')) {
      return (Icons.shopping_cart, const Color(0xFFFF9900));
    }
    if (m.contains('nike')) {
      return (Icons.check_circle_outline, const Color(0xFFE53935));
    }
    if (m.contains('apple')) {
      return (Icons.apple, const Color(0xFF888888));
    }
    if (m.contains('ikea')) {
      return (Icons.home_outlined, const Color(0xFF0058A3));
    }
    if (m.contains('samsung')) {
      return (Icons.devices_outlined, const Color(0xFF1428A0));
    }
    if (m.contains('best buy')) {
      return (Icons.stars_outlined, const Color(0xFF0046BE));
    }
    if (m.contains('adidas')) {
      return (Icons.directions_run, const Color(0xFFAAAAAA));
    }
    return (Icons.shopping_bag_outlined, const Color(0xFF8B5CF6));
  }

  static String _installmentInfo(double amount, String id) {
    final total = amount > 800 ? 4 : amount > 350 ? 3 : 2;
    final hash = id.codeUnits.fold(0, (a, b) => a + b) % total;
    final remaining = total - hash;
    return '$remaining of $total payments left';
  }

  Widget _buildActivePlans(
      BuildContext context, TickpayAccountLoaded? account) {
    final fmt = NumberFormat('#,##0.00');
    final purchases = account?.purchases ?? [];

    final mockPlans = [
      (
        _brandBadge('amazon'),
        'Amazon', '#9012', '3 of 4 payments left', '\$599',
      ),
      (
        _brandBadge('nike'),
        'Nike', '#8234', '2 of 3 payments left', '\$450',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Plans',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    context.push(RouteConstants.tickpayActivePlans.toPath),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (purchases.isEmpty)
            ...mockPlans.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPlanItem(
                    logoWidget: p.$1,
                    brand: p.$2,
                    orderRef: p.$3,
                    info: p.$4,
                    amount: p.$5,
                  ),
                ))
          else
            ...purchases.take(2).map((tx) {
              final merchant = tx.merchant ?? '';
              final (_, color) = _brandInfo(merchant);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildPlanItem(
                  logoWidget: _brandBadge(merchant),
                  brand: tx.merchant ?? 'Purchase',
                  orderRef:
                      '#${tx.id.substring(tx.id.length > 6 ? tx.id.length - 6 : 0)}',
                  info: _installmentInfo(tx.amount, tx.id),
                  amount: '\$${fmt.format(tx.amount)}',
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPlanItem({
    required Widget logoWidget,
    required String brand,
    required String orderRef,
    required String info,
    required String amount,
  }) {
    double progress = 0.5;
    final match = RegExp(r'(\d+) of (\d+)').firstMatch(info);
    if (match != null) {
      final remaining = int.tryParse(match.group(1) ?? '1') ?? 1;
      final total = int.tryParse(match.group(2) ?? '4') ?? 4;
      progress = (total - remaining) / total;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2240), Color(0xFF0D0D1A)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              logoWidget,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          brand,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          orderRef,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFF14B8A6),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

}
