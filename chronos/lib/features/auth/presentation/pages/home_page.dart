import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../features/home/domain/entities/home_summary.dart';
import '../../../../features/home/presentation/bloc/home_bloc.dart';
import '../../../../features/home/presentation/bloc/home_event.dart';
import '../../../../features/home/presentation/bloc/home_state.dart';
import '../../../../core/widgets/chris_home_fab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<HomeBloc>()..add(const HomeSummaryRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  bool _isBalanceVisible = true;
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 360;
    final double scale = size.width / 390;
    final double textScale = math.min(scale, 1.1);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final summary = state is HomeLoaded ? state.summary : null;
        final balance = summary?.accountBalance ?? 8342.30;
        final transactions = summary?.recentTransactions ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(
                  context, scale, textScale, isSmallScreen,
                  balance: balance,
                  isLoading: state is HomeLoading,
                ),
                const SizedBox(height: 12),
                Container(
                  color: const Color(0xFFF5F5F5),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildTransactionsSection(
                          scale, textScale, transactions),
                      const SizedBox(height: 24),
                      _buildOffersSection(scale, textScale),
                      const SizedBox(height: 24),
                      _buildSpendingAnalysisSection(scale, textScale, summary),
                      const SizedBox(height: 24),
                      _buildNetWorthSection(scale, textScale, balance),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 90),
            child: const ChrisHomeFab(),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    double scale,
    double textScale,
    bool isSmallScreen, {
    required double balance,
    required bool isLoading,
  }) {
    final double heroHeight = (isSmallScreen ? 380 : 440) * scale;

    return Stack(
      children: [
        Container(
          height: heroHeight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        Container(
          height: heroHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.35),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        SizedBox(
          height: heroHeight,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push(RouteConstants.profile.toPath),
                        child: CircleAvatar(
                          radius: 18 * scale,
                          backgroundColor: const Color(0xFFCD853F),
                          child: Icon(Icons.person, color: Colors.white,
                              size: 20 * scale),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/search'),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                height: 40 * scale,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Icon(Icons.search, color: Colors.white,
                                        size: 18 * scale),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Search services, transactions...',
                                        style: TextStyles.bodySmall.copyWith(
                                          color: Colors.white.withValues(
                                              alpha: 0.85),
                                          fontSize: 12 * textScale,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(8 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(Icons.notifications_none,
                                color: Colors.white, size: 22 * scale),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 45 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 14 * textScale,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(
                                () => _isBalanceVisible = !_isBalanceVisible),
                            child: Icon(
                              _isBalanceVisible
                                  ? Icons.remove_red_eye_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white70,
                              size: 20 * scale,
                            ),
                          ),
                        ],
                      ),
                      _buildCurrencyPicker(scale, textScale),
                    ],
                  ),
                  const SizedBox(height: 4),
                  isLoading
                      ? SizedBox(
                          height: (isSmallScreen ? 44 : 58) * textScale,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                        )
                      : Text(
                          _isBalanceVisible
                              ? '\$${balance.toStringAsFixed(2)}'
                              : '••••••••',
                          style: TextStyles.displaySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: (isSmallScreen ? 36 : 48) * textScale,
                          ),
                        ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(Icons.arrow_upward, 'Transfer',
                          scale, textScale,
                          () => context.go(RouteConstants.transfer.toPath)),
                      _buildQuickAction(Icons.add, 'Add Money', scale,
                          textScale,
                          () => context.push(RouteConstants.addMoney.toPath)),
                      _buildQuickAction(Icons.swap_horiz, 'Exchange',
                          scale, textScale,
                          () => context.go(RouteConstants.exchange.toPath)),
                      _buildQuickAction(Icons.wallet, 'Wallet', scale,
                          textScale,
                          () => context.go(RouteConstants.wallet.toPath)),
                      _buildQuickAction(Icons.confirmation_number, 'TickPay',
                          scale, textScale,
                          () => context.push(RouteConstants.tickpayWelcome.toPath),
                          iconOverride: const Text(
                            'T',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyPicker(double scale, double textScale) {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _selectedCurrency = value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'USD', child: Text('USD')),
        const PopupMenuItem(value: 'EUR', child: Text('EUR')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15), width: 0.7),
        ),
        child: Row(
          children: [
            Text(_selectedCurrency,
                style: TextStyles.labelSmall.copyWith(
                    color: Colors.white, fontSize: 11 * textScale)),
            Icon(Icons.keyboard_arrow_down, color: Colors.white,
                size: 14 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, double scale,
      double textScale, VoidCallback onTap, {Widget? iconOverride}) {
    final double circleSize = 54 * scale;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.30), width: 1.0),
            ),
            child: Center(
              child: iconOverride ?? Icon(icon, color: Colors.white, size: 24 * scale),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 10 * textScale)),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(double scale, double textScale,
      List<RecentTransaction> transactions) {
    return Column(
      children: [
        SectionHeader(
          title: 'Transactions',
          actionText: 'View All',
          onActionPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: transactions.isEmpty
                ? _buildFallbackTransactions(scale, textScale)
                : Column(
                    children: transactions
                        .take(5)
                        .map((tx) => _buildTransactionItem(
                              icon: _iconForType(tx.type),
                              title: tx.description ?? tx.type,
                              subtitle: _formatDate(tx.createdAt),
                              amount:
                                  '${tx.isCredit ? '+' : '-'}\$${tx.amount.abs().toStringAsFixed(2)}',
                              isNegative: !tx.isCredit,
                              iconBg: tx.isCredit
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF7C3AED),
                              scale: scale,
                              textScale: textScale,
                            ))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackTransactions(double scale, double textScale) {
    final items = [
      ('Apple Store', 'Today, 2:34 PM', '-\$299.00', true,
          Icons.apple, const Color(0xFF7C3AED)),
      ('Salary Deposit', 'Today, 9:00 AM', '+\$5,200.00', false,
          Icons.south_west, const Color(0xFF2E7D32)),
      ('Uber Eats', 'Yesterday, 8:12 PM', '-\$32.50', true,
          Icons.restaurant, const Color(0xFFDC8F4A)),
    ];
    return Column(
      children: items
          .map((i) => _buildTransactionItem(
                icon: i.$5,
                title: i.$1,
                subtitle: i.$2,
                amount: i.$3,
                isNegative: i.$4,
                iconBg: i.$6,
                scale: scale,
                textScale: textScale,
              ))
          .toList(),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
        return Icons.south_west;
      case 'TRANSFER':
        return Icons.swap_horiz;
      case 'PURCHASE':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final time = '$hour:$minute $period';
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today, $time';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == yesterday.year && dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return 'Yesterday, $time';
      }
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isNegative,
    required Color iconBg,
    required double scale,
    required double textScale,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12 * scale),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24 * scale),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyles.titleSmall.copyWith(
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14 * textScale)),
                Text(subtitle,
                    style: TextStyles.bodySmall.copyWith(
                        color: const Color(0xFF888888), fontSize: 11 * textScale)),
              ],
            ),
          ),
          Text(amount,
              style: TextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * textScale,
                  color: isNegative
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFCD853F))),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: const Color(0xFFCCCCCC), size: 20 * scale),
        ],
      ),
    );
  }

  Widget _buildOffersSection(double scale, double textScale) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.card_giftcard, color: const Color(0xFFB8860B),
                  size: 20 * scale),
              const SizedBox(width: 8),
              Text('Offers For You',
                  style: TextStyles.titleMedium.copyWith(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * textScale)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text('View All',
                    style: TextStyles.labelLarge.copyWith(
                        color: const Color(0xFFB8860B),
                        fontSize: 12 * textScale)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
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
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCD853F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.percent, color: Colors.white,
                      size: 24 * scale),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cashback Boost',
                          style: TextStyles.titleSmall.copyWith(
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.bold,
                              fontSize: 14 * textScale)),
                      Text('Get 5% cashback on dining',
                          style: TextStyles.bodySmall.copyWith(
                              color: const Color(0xFF888888),
                              fontSize: 11 * textScale)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18 * scale,
                    color: const Color(0xFFCCCCCC)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingAnalysisSection(double scale, double textScale,
      HomeSummary? summary) {
    final List<double> values;
    final List<Color> colors = [
      const Color(0xFFB8860B),
      const Color(0xFFD4A373),
      const Color(0xFFF4A460),
      const Color(0xFFDEB887),
      const Color(0xFFCD853F),
    ];
    final List<String> labels;

    if (summary != null && summary.spendingByCategory.isNotEmpty) {
      values = summary.spendingByCategory.map((c) => c.amount).toList();
      labels = summary.spendingByCategory.map((c) => c.category).toList();
    } else {
      values = [420, 285, 180, 340, 540];
      labels = ['Food', 'Transport', 'Shopping', 'Bills', 'Other'];
    }

    final total = values.fold(0.0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Spending Analysis',
              style: TextStyles.titleMedium.copyWith(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * textScale)),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
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
                SizedBox(
                  width: 100 * scale,
                  height: 100 * scale,
                  child: CustomPaint(
                    painter:
                        DonutChartPainter(values: values, colors: colors),
                    child: Center(
                      child: Text(
                        'Total\n\$${total.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: TextStyles.labelSmall.copyWith(
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.bold,
                            fontSize: 10 * textScale),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(
                      math.min(values.length, 3),
                      (i) => _buildSpendingLegend(
                          labels[i],
                          '\$${values[i].toStringAsFixed(0)}',
                          colors[i % colors.length],
                          textScale),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingLegend(String label, String value, Color color,
      double textScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  width: 8, height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF555555), fontSize: 11 * textScale)),
            ],
          ),
          Text(value,
              style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 11 * textScale)),
        ],
      ),
    );
  }

  Widget _buildNetWorthSection(double scale, double textScale, double balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Net Worth Summary',
              style: TextStyles.titleMedium.copyWith(
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * textScale)),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCD853F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 20 * scale),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Net Worth',
                            style: TextStyles.labelSmall.copyWith(
                                color: const Color(0xFF888888),
                                fontSize: 11 * textScale)),
                        Text('\$${balance.toStringAsFixed(0)}',
                            style: TextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                                fontSize: 16 * textScale)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                SizedBox(
                  height: 120 * scale,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar('Cash', 0.85, const Color(0xFFCD853F), scale),
                      _buildBar('AI Portfolio', 0.45,
                          const Color(0xFF8B4513), scale),
                      _buildBar('Investments', 0.18,
                          const Color(0xFFB8860B), scale),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String label, double heightFactor, Color color,
      double scale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32 * scale,
          height: 80 * scale * heightFactor,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 9 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF555555))),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double total = values.fold(0, (sum, item) => sum + item);
    double startAngle = -math.pi / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
