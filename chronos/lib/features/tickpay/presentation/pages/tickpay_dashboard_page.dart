import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_fab.dart';
import '../bloc/tickpay_account_cubit.dart';
import '../bloc/tickpay_account_state.dart';
import '../utils/tickpay_media.dart';

// ---------------------------------------------------------------------------
// Design constants
// ---------------------------------------------------------------------------
const _kCard = Color(0xFF1A1A2E);
const _kBorder = Color(0x1AFFFFFF); // white 10%

class TickPayDashboardPage extends StatelessWidget {
  const TickPayDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TickpayAccountCubit, TickpayAccountState>(
      builder: (context, state) {
        final loaded = state is TickpayAccountLoaded ? state : null;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 80),
            child: const ChrisFab(),
          ),
          body: Stack(
            children: [
              // ── Full-screen background ────────────────────────────────────
              Positioned.fill(
                child: Image.asset(
                  'assets/tickpay/background.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
              // ── Content ───────────────────────────────────────────────────
              Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _buildTopBar(context),
                        _buildCreditCard(context, loaded),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state is TickpayAccountLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.white54))
                        : state is TickpayAccountError
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.credit_card_off,
                                          size: 48,
                                          color: Colors.white.withValues(alpha: 0.4)),
                                      const SizedBox(height: 12),
                                      Text(state.message,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.55))),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 28, bottom: 100),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildActivePlans(context, loaded),
                                    const SizedBox(height: 28),
                                    _buildAiPicks(context),
                                  ],
                                ),
                              ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
            color: Colors.white.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.25), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
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
                    account == null ? '—' : '\$${fmt.format(available)}',
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
                              ? 'Used  —'
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
      (Icons.shopping_bag_outlined, 'Shop',
          RouteConstants.tickpayDiscover.toPath),
      (Icons.payment_outlined, 'Pay', RouteConstants.tickpayRepayNow.toPath),
      (Icons.receipt_long_outlined, 'Purchases',
          RouteConstants.tickpayOrderHistory.toPath),
      (Icons.replay_outlined, 'Repayments',
          RouteConstants.tickpayUpcomingPayments.toPath),
      (Icons.savings_outlined, 'Rewards',
          RouteConstants.tickpayRewards.toPath),
    ];
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => context.push(actions[i].$3),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.8),
                  ),
                  child:
                      Icon(actions[i].$1, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  actions[i].$2,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
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
      (Icons.shopping_cart, const Color(0xFFFF9900), 'Amazon', '#9012',
          '3 of 4 payments left', '\$599'),
      (Icons.check_circle_outline, const Color(0xFFE53935), 'Nike', '#8234',
          '2 of 3 payments left', '\$450'),
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
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    context.push(RouteConstants.tickpayActivePlans.toPath),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
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
                    logo: p.$1,
                    brand: p.$3,
                    orderRef: p.$4,
                    info: p.$5,
                    amount: p.$6,
                    color: p.$2,
                  ),
                ))
          else
            ...purchases.take(2).map((tx) {
              final (icon, color) = _brandInfo(tx.merchant ?? '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildPlanItem(
                  logo: icon,
                  brand: tx.merchant ?? 'Purchase',
                  orderRef:
                      '#${tx.id.substring(tx.id.length > 6 ? tx.id.length - 6 : 0)}',
                  info: _installmentInfo(tx.amount, tx.id),
                  amount: '\$${fmt.format(tx.amount)}',
                  color: color,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPlanItem({
    required IconData logo,
    required String brand,
    required String orderRef,
    required String info,
    required String amount,
    required Color color,
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
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(logo, color: color, size: 22),
              ),
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
                  color: Color(0xFFFF9900),
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
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiPicks(BuildContext context) {
    final picks = [
      ('Samsung Galaxy Buds', '\$149', TickPayMedia.wirelessEarbuds, 88),
      ('Adidas Ultraboost', '\$180', TickPayMedia.adidasShoes, 84),
      ('Sony WH-1000XM4', '\$350', TickPayMedia.headphonesBlack, 82),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Color(0xFF8B5CF6), size: 13),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Picks for You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () =>
                    context.push(RouteConstants.tickpayAiPicks.toPath),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: picks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final pick = picks[i];
              return GestureDetector(
                onTap: () => context.push(
                  RouteConstants.tickpayProductDetail.toPath,
                  extra: {
                    'name': pick.$1,
                    'price': pick.$2,
                    'asset': pick.$3
                  },
                ),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kBorder, width: 1),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: TickPayImage(
                              pick.$3,
                              height: 115,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pick.$1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pick.$2,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6)
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        '${pick.$4}%',
                                        style: const TextStyle(
                                          color: Color(0xFF60A5FA),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // AI badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('AI',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      // Heart button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.favorite_border,
                              color: Colors.white70, size: 14),
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
}
