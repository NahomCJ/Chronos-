import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_fab.dart';
import '../bloc/tickpay_account_cubit.dart';
import '../bloc/tickpay_account_state.dart';
import '../utils/tickpay_media.dart';

class TickPayDashboardPage extends StatelessWidget {
  const TickPayDashboardPage({super.key});

  static const _kDark = Color(0xFF1A0A2E);
  static const _kLight = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TickpayAccountCubit, TickpayAccountState>(
      builder: (context, state) {
        final loaded = state is TickpayAccountLoaded ? state : null;
        return Scaffold(
          backgroundColor: _kLight,
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 80),
            child: const ChrisFab(),
          ),
          body: Column(
            children: [
              // ── Dark hero header ──────────────────────────────────────────────
              Container(
                color: _kDark,
                child: SafeArea(
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
              ),
              // ── White content body ────────────────────────────────────────────
              Expanded(
                child: state is TickpayAccountLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state is TickpayAccountError
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.credit_card_off,
                                      size: 48, color: Color(0xFF7C3AED)),
                                  const SizedBox(height: 12),
                                  Text(state.message,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Color(0xFF555555))),
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
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
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

  Widget _buildCreditCard(BuildContext context, TickpayAccountLoaded? account) {
    final fmt = NumberFormat('#,##0.00');
    final available = account?.available ?? 0.0;
    final creditUsed = account?.creditUsed ?? 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                context.push(RouteConstants.tickpayCreditOverview.toPath),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Credit Overview',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D1B4E), Color(0xFF3D2B5E)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Credit',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      account == null ? 'Loading...' : 'TickPay Card',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  account == null ? '---' : '\$${fmt.format(available)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Text(
                    account == null
                        ? 'Credit Used  ---'
                        : 'Credit Used  \$${fmt.format(creditUsed)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
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
                        color: Colors.white.withValues(alpha: 0.2), width: 0.8),
                  ),
                  child: Icon(actions[i].$1, color: Colors.white, size: 22),
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

  Widget _buildActivePlans(BuildContext context, TickpayAccountLoaded? account) {
    final fmt = NumberFormat('#,##0.00');
    final purchases = account?.purchases ?? [];
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
                  color: Color(0xFF1A1A1A),
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
                    color: Color(0xFF7C3AED),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (purchases.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No active plans yet. Start shopping!',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13),
              ),
            )
          else
            ...purchases.take(2).map((tx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildPlanItem(
                  logo: Icons.shopping_bag_outlined,
                  brand: tx.merchant ?? 'Purchase',
                  orderRef: '#${tx.id.substring(tx.id.length > 6 ? tx.id.length - 6 : 0)}',
                  info: tx.status,
                  amount: '\$${fmt.format(tx.amount)}',
                  color: const Color(0xFF7C3AED),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(logo, color: color, size: 20),
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
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      orderRef,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  info,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiPicks(BuildContext context) {
    final picks = [
      ('Samsung Galaxy Buds', '\$149', TickPayMedia.wirelessEarbuds),
      ('Adidas Ultraboost', '\$180', TickPayMedia.adidasShoes),
      ('Sony WH-1000XM4', '\$350', TickPayMedia.headphonesBlack),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Picks for You',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    context.push(RouteConstants.tickpayAiPicks.toPath),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: picks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TickPayImage(
                          picks[i].$3,
                          height: 110,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                picks[i].$1,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                picks[i].$2,
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border,
                            color: Color(0xFF444444), size: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
