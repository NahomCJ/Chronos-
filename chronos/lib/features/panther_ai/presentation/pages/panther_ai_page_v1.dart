import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/theme/panther_colors.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/alerts_bloc.dart';
import '../bloc/alerts_event.dart';
import '../bloc/alerts_state.dart';
import '../widgets/your_insights_modal.dart';

// ignore_for_file: unused_element
class PantherAiPageV1 extends StatefulWidget {
  const PantherAiPageV1({super.key});

  @override
  State<PantherAiPageV1> createState() => _PantherAiPageV1State();
}

class _PantherAiPageV1State extends State<PantherAiPageV1> {
  final bool _isFirstTime = false;
  late final AlertsBloc _alertsBloc;

  @override
  void initState() {
    super.initState();
    _alertsBloc = GetIt.I<AlertsBloc>();
    _alertsBloc.add(const AlertsLoadRequested());
  }

  @override
  void dispose() {
    _alertsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = size.width / 390;
    final double textScale = math.min(scale, 1.1);

    return BlocProvider.value(
      value: _alertsBloc,
      child: Scaffold(
      backgroundColor: PantherColors.bg,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // Hero section with panther image
                _buildHeroSection(context, scale, textScale),
                // Black background section that continues from hero
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.only(),
                  child: const SizedBox(),
                ),
                // Background image for remaining content
                Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/background.png'),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.20),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildPriorityActionsSection(scale, textScale),
                        const SizedBox(height: 24),
                        _buildIntelligenceHubSection(scale, textScale),
                        const SizedBox(height: 24),
                        _buildUpcomingEventsSection(scale, textScale),
                        const SizedBox(height: 24),
                        _isFirstTime
                            ? _buildQuickAccessSection(scale, textScale)
                            : _buildPantherTabBar(scale, textScale),
                        const SizedBox(height: 140),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Top Insights section overlaying the hero
            Positioned(
              top: 180 * scale,
              left: 0,
              right: 0,
              child: _buildTopInsightsSection(scale, textScale),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildHeroSection(
    BuildContext context,
    double scale,
    double textScale,
  ) {
    return Stack(
      children: [
        // Background image with panther
        Container(
          height: 450 * scale,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/panther.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient overlay - darker at bottom to blend with black section
        Container(
          height: 450 * scale,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
                Colors.black,
              ],
              stops: const [0.0, 0.3, 0.8, 1.0],
            ),
          ),
        ),
        // Content
        SizedBox(
          height: 450 * scale,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15 * scale,
                            backgroundColor: PantherColors.brand,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 18 * scale,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good evening, Antonio',
                                style: TextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18 * textScale,
                                ),
                              ),
                              Text(
                                'Tuesday, February 3',
                                style: TextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14 * textScale,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20 * scale,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.all(6 * scale),
                            decoration: BoxDecoration(
                              color: PantherColors.brand,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20 * scale,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // AI Status section at the top
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 0.74,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: PantherColors.brand,
                          size: 20 * scale,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Status',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 14 * textScale,
                                ),
                              ),
                              Text(
                                'Observing your portfolio',
                                style: TextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12 * textScale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: PantherColors.positive.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: PantherColors.positive,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyles.bodySmall.copyWith(
                              color: PantherColors.positive,
                              fontSize: 12 * textScale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopInsightsSection(double scale, double textScale) {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        final alerts = state is AlertsLoaded ? state.alerts : [];
        final isLoading = state is AlertsLoading;

        // Use first real alert if available, otherwise fall back to placeholder
        final title = alerts.isNotEmpty
            ? alerts.first.title
            : 'Portfolio rebalance recommended';
        final message = alerts.isNotEmpty
            ? alerts.first.message
            : 'Your BTC exposure is 22% above optimal allocation';
        final alertType = alerts.isNotEmpty ? alerts.first.type : 'INFO';
        final typeColor = alertType == 'FRAUD'
            ? PantherColors.negative
            : alertType == 'BNPL_RISK'
                ? PantherColors.warning
                : PantherColors.warning;
        final typeLabel = alertType == 'FRAUD'
            ? 'High Risk'
            : alertType == 'BNPL_RISK'
                ? 'BNPL Risk'
                : 'Medium Risk';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Insights',
                    style: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 18 * textScale,
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white54),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PantherColors.border,
                    width: 0.74,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: 12 * textScale,
                            ),
                          ),
                        ),
                        if (alerts.isNotEmpty)
                          GestureDetector(
                            onTap: () => _alertsBloc
                                .add(AlertDismissRequested(alerts.first.id)),
                            child: Icon(
                              Icons.close,
                              color: PantherColors.textSubtle,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyles.titleMedium.copyWith(
                        color: PantherColors.textPrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: 16 * textScale,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyles.bodySmall.copyWith(
                        color: PantherColors.textSecondary,
                        fontSize: 14 * textScale,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _alertsBloc
                                .add(const AlertsGenerateRequested()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PantherColors.cardAlt,
                              foregroundColor: PantherColors.textPrimary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'Refresh',
                              style: TextStyles.labelMedium.copyWith(
                                fontSize: 13.44 * textScale,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context
                                  .push(RouteConstants.insightDetails.toPath);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PantherColors.brand,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'View all',
                              style: TextStyles.labelMedium.copyWith(
                                fontSize: 13.44 * textScale,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  alerts.length.clamp(1, 3),
                  (i) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: i == 0 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? PantherColors.brand
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriorityActionsSection(double scale, double textScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority Actions',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 18 * textScale,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            icon: Icons.sync,
            iconColor: PantherColors.info.withValues(alpha: 0.15),
            iconForeground: PantherColors.info,
            title: 'Simulate Rebalance',
            subtitle: 'Optimize portfolio allocation',
            scale: scale,
            textScale: textScale,
            onTap: () {
              context.push(RouteConstants.simulateRebalance.toPath);
            },
          ),
          const SizedBox(height: 18),
          _buildActionCard(
            icon: Icons.warning_amber_rounded,
            iconColor: PantherColors.warning.withValues(alpha: 0.15),
            iconForeground: PantherColors.warning,
            title: 'Review BNPL payment',
            subtitle: 'Due in 3 days',
            scale: scale,
            textScale: textScale,
            onTap: () {
              context.push(RouteConstants.paymentPlan.toPath);
            },
          ),
          const SizedBox(height: 18),
          _buildActionCard(
            icon: Icons.shield_outlined,
            iconColor: PantherColors.brand.withValues(alpha: 0.15),
            iconForeground: PantherColors.brand,
            title: 'View Full Analysis',
            subtitle: 'Complete portfolio insights',
            scale: scale,
            textScale: textScale,
            onTap: () {
              context.push(RouteConstants.fullPortfolioAnalysis.toPath);
            },
          ),
          const SizedBox(height: 18),
          _buildActionCard(
            icon: Icons.trending_up,
            iconColor: PantherColors.info.withValues(alpha: 0.15),
            iconForeground: PantherColors.info,
            title: 'ETH entry signal detected',
            subtitle: 'High confidence',
            scale: scale,
            textScale: textScale,
            // highlighted: true,
            onTap: () {
              context.push(RouteConstants.ethFlowDetail.toPath);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconForeground,
    required String title,
    required String subtitle,
    required double scale,
    required double textScale,
    bool highlighted = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                highlighted
                    ? PantherColors.brand
                    : PantherColors.border,
            width: highlighted ? 1 : 0.74,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(icon, color: iconForeground, size: 20 * scale),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyMedium.copyWith(
                      color: PantherColors.textPrimary,
                      fontSize: 14 * textScale,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyles.bodySmall.copyWith(
                      color: PantherColors.textSecondary,
                      fontSize: 12 * textScale,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: PantherColors.textSubtle,
              size: 20 * scale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntelligenceHubSection(double scale, double textScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Intelligence Hub',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 18 * textScale,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // First row - 3 small cards (horizontally scrollable)
        SizedBox(
          height: 95 * scale,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              SizedBox(
                width: 140,
                child: _buildSmallHubCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Portfolio',
                  value: '\$45,890',
                  change: '+12.4%',
                  changeColor: PantherColors.positive,
                  scale: scale,
                  textScale: textScale,
                  onTap: () {
                    context.push(RouteConstants.portfolioIntelligence.toPath);
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: _buildSmallHubCard(
                  icon: Icons.show_chart,
                  title: 'Trading',
                  value: '4 signals',
                  change: '87% confidence',
                  changeColor: PantherColors.brand,
                  scale: scale,
                  textScale: textScale,
                  onTap: () {
                    context.push(RouteConstants.tradingAssistant.toPath);
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: _buildSmallHubCard(
                  icon: Icons.payment,
                  title: 'TickPay',
                  value: '\$420 safe',
                  change: 'This month',
                  changeColor: PantherColors.positive,
                  scale: scale,
                  textScale: textScale,
                  // highlighted: true,
                  onTap: () {
                    context.push(RouteConstants.tickPayAi.toPath);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Second row - 3 larger cards (horizontally scrollable)
        // SizedBox(
        //   height: 140,
        //   child: ListView(
        //     scrollDirection: Axis.horizontal,
        //     padding: const EdgeInsets.symmetric(horizontal: 20),
        //     children: [
        //       SizedBox(
        //         width: 200,
        //         child: _buildCryptoCard(
        //           name: 'Ethereum',
        //           symbol: 'ETH',
        //           price: '\$2,456',
        //           change: '+3.2%',
        //           changeColor: const Color(0xFF05DF72),
        //           scale: scale,
        //           textScale: textScale,
        //           onTap: () {
        //             context.push(RouteConstants.ethFlowDetail.toPath);
        //           },
        //         ),
        //       ),
        //       const SizedBox(width: 12),
        //       SizedBox(
        //         width: 200,
        //         child: _buildCryptoCard(
        //           name: 'Bitcoin',
        //           symbol: 'BTC',
        //           price: '\$42,890',
        //           change: '+5.1%',
        //           changeColor: const Color(0xFF05DF72),
        //           scale: scale,
        //           textScale: textScale,
        //         ),
        //       ),
        //       const SizedBox(width: 12),
        //       SizedBox(
        //         width: 200,
        //         child: _buildCryptoCard(
        //           name: 'Solana',
        //           symbol: 'SOL',
        //           price: '\$98.45',
        //           change: '-2.3%',
        //           changeColor: const Color(0xFFFF6467),
        //           scale: scale,
        //           textScale: textScale,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildSmallHubCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required Color changeColor,
    required double scale,
    required double textScale,
    bool highlighted = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color:
                highlighted
                    ? PantherColors.brand
                    : PantherColors.border,
            width: highlighted ? 1 : 0.65,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: PantherColors.brand, size: 18 * scale),
            SizedBox(height: 3 * scale),
            Text(
              title,
              style: TextStyles.bodySmall.copyWith(
                color: PantherColors.textSecondary,
                fontSize: 9.5 * textScale,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1 * scale),
            Text(
              value,
              style: TextStyles.titleSmall.copyWith(
                color: PantherColors.textPrimary,
                fontSize: 12.5 * textScale,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1 * scale),
            Text(
              change,
              style: TextStyles.bodySmall.copyWith(
                color: changeColor,
                fontSize: 9.5 * textScale,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildUpcomingEventsSection(double scale, double textScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Events',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 18 * textScale,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PantherColors.border,
                width: 0.74,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildEventItem(
                  title: 'Netflix payment',
                  subtitle: 'Tomorrow, \$15.99',
                  color: PantherColors.brand,
                  scale: scale,
                  textScale: textScale,
                ),
                const SizedBox(height: 12),
                _buildEventItem(
                  title: 'BTC earnings report',
                  subtitle: 'Feb 5, High impact',
                  color: PantherColors.brand,
                  scale: scale,
                  textScale: textScale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem({
    required String title,
    required String subtitle,
    required Color color,
    required double scale,
    required double textScale,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyles.bodyMedium.copyWith(
                  color: PantherColors.textPrimary,
                  fontSize: 14 * textScale,
                ),
              ),
              Text(
                subtitle,
                style: TextStyles.bodySmall.copyWith(
                  color: PantherColors.textSecondary,
                  fontSize: 12 * textScale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(double scale, double textScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'Panther is learning from your actions',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12 * textScale,
            ),
          ),
          Text(
            'Trust score: 94%',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.warning,
              fontSize: 12 * textScale,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessButton(
                  icon: Icons.home,
                  label: 'Panther Home',
                  subtitle: 'Simple AI Landing',
                  scale: scale,
                  textScale: textScale,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessButton(
                  icon: Icons.article,
                  label: 'Daily AI Brief',
                  subtitle: '30 sec read',
                  scale: scale,
                  textScale: textScale,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessButton(
                  icon: Icons.psychology,
                  label: 'AI Confidence',
                  subtitle: 'Risk summary',
                  scale: scale,
                  textScale: textScale,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessButton(
                  icon: Icons.help_outline,
                  label: 'How It Works',
                  subtitle: 'AI explained',
                  scale: scale,
                  textScale: textScale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required double scale,
    required double textScale,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: PantherColors.border,
          width: 0.67,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: PantherColors.brand, size: 20 * scale),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textPrimary,
                    fontSize: 14 * textScale,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyles.bodySmall.copyWith(
                color: PantherColors.textSecondary,
                fontSize: 12 * textScale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPantherTabBar(double scale, double textScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panther is learning from your actions',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12 * textScale,
            ),
          ),
          Text(
            'Trust score: 94%',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.warning,
              fontSize: 12 * textScale,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  icon: Icons.lightbulb_outline,
                  label: 'Insights',
                  scale: scale,
                  textScale: textScale,
                  onTap: () => YourInsightsModal.show(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTabButton(
                  icon: Icons.trending_up,
                  label: 'Markets',
                  scale: scale,
                  textScale: textScale,
                  onTap:
                      () => context.push(
                        RouteConstants.marketIntelligence.toPath,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTabButton(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  scale: scale,
                  textScale: textScale,
                  onTap:
                      () =>
                          context.push(RouteConstants.pantherAiSettings.toPath),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required double scale,
    required double textScale,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PantherColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: PantherColors.brand, size: 18 * scale),
            SizedBox(height: 4 * scale),
            Text(
              label,
              style: TextStyles.bodySmall.copyWith(
                color: PantherColors.textPrimary,
                fontSize: 11 * textScale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
