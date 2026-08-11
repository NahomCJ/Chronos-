import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/theme/panther_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/alerts_bloc.dart';
import '../bloc/alerts_event.dart';
import '../bloc/alerts_state.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../auth/data/services/token_storage_service.dart';
import '../../domain/entities/ai_alert.dart';

class PantherAiPage extends StatefulWidget {
  const PantherAiPage({super.key});

  @override
  State<PantherAiPage> createState() => _PantherAiPageState();
}

class _PantherAiPageState extends State<PantherAiPage>
    with SingleTickerProviderStateMixin {
  late final AlertsBloc _alertsBloc;
  late final AnimationController _glowCtrl;
  late final Timer _awarenessTimer;
  int _awarenessIndex = 0;
  int _currentStory = 0;

  static const _bg = PantherColors.bg;
  static const _textPrimary = PantherColors.textPrimary;
  static const _textSecondary = PantherColors.textSecondary;
  static const _purple = PantherColors.brand;
  static const _green = PantherColors.positive;
  static const _teal = Color(0xFF14B8A6);

  static const _awareness = [
    'Tracking 4 spending patterns',
    'Markets stable · No action needed',
    '2 things noticed this week',
    'LifeX sync complete',
  ];

  String get _greetingName {
    try {
      final name = GetIt.I<TokenStorageService>().firstName;
      return (name != null && name.isNotEmpty) ? name : 'there';
    } catch (_) {
      return 'there';
    }
  }

  @override
  void initState() {
    super.initState();
    _alertsBloc = GetIt.I<AlertsBloc>();
    _alertsBloc.add(const AlertsGenerateRequested());

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _awarenessTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _awarenessIndex = (_awarenessIndex + 1) % _awareness.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _alertsBloc.close();
    _glowCtrl.dispose();
    _awarenessTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _alertsBloc,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildOrbHero()),
              SliverToBoxAdapter(child: _buildRightNowBand()),
              SliverToBoxAdapter(child: _buildAutoInvestCard()),
              SliverToBoxAdapter(child: _buildStoriesSection()),
              SliverToBoxAdapter(child: _buildLifeXCard()),
              SliverToBoxAdapter(child: _buildQuickActions()),
              SliverToBoxAdapter(child: _buildIntelligence()),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PANTHER',
                style: TextStyles.bodySmall.copyWith(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                ),
              ),
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (_, __) => Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _green,
                        boxShadow: [
                          BoxShadow(
                            color: _green.withValues(
                                alpha: 0.25 + _glowCtrl.value * 0.45),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Aware',
                    style: TextStyles.bodySmall.copyWith(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () =>
                        context.push(RouteConstants.pantherAiSettings.toPath),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PantherColors.cardAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF374151),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Hey $_greetingName',
            style: TextStyles.headlineSmall.copyWith(
              color: _textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbHero() {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _purple.withValues(alpha: 0.12 + _glowCtrl.value * 0.06),
                    _purple.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChrisHomeFab(
                size: 124,
                onTap: () => context.push(RouteConstants.pantherAiChat.toPath),
              ),
              const SizedBox(height: 18),
              Text(
                'Tap to talk with Chris',
                style: TextStyles.bodySmall.copyWith(
                  color: _textSecondary,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                    child: child,
                  ),
                ),
                child: Text(
                  _awareness[_awarenessIndex],
                  key: ValueKey(_awarenessIndex),
                  style: TextStyles.bodySmall.copyWith(
                    color: _purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The "can I actually afford this?" band — the three numbers a user
  /// checks right before a purchase or lending-to-a-friend decision:
  /// what's safe to spend today, what's due next, and the debt load
  /// sitting behind both. Surfaced above the fold instead of buried in
  /// the Intelligence grid, per the goal of keeping users oriented on
  /// their schedule before they commit to something.
  Widget _buildRightNowBand() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
      child: Row(
        children: [
          Expanded(
            child: _RightNowChip(
              label: 'Safe to spend',
              value: '\$420',
              accent: _green,
              icon: Icons.wallet_rounded,
              onTap: () => context.push(RouteConstants.budgetIntelligence.toPath),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _RightNowChip(
              label: 'Next bill · 4 days',
              value: '\$89',
              accent: const Color(0xFFF59E0B),
              icon: Icons.event_rounded,
              onTap: () => context.push(RouteConstants.billsManagement.toPath),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _RightNowChip(
              label: 'Total debt',
              value: '\$318.8k',
              accent: const Color(0xFFEF4444),
              icon: Icons.credit_card_off_rounded,
              onTap: () =>
                  context.push(RouteConstants.liabilitiesIntelligence.toPath),
            ),
          ),
        ],
      ),
    );
  }

  /// Entry point for "Auto-Invest with Chris". Always routes to the intro
  /// page — that page itself checks for an existing plan on load and
  /// redirects straight to the dashboard state so a returning user never
  /// sees the pitch twice.
  Widget _buildAutoInvestCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: GestureDetector(
        onTap: () => context.push(RouteConstants.autoInvestIntro.toPath),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_purple, _purple.withValues(alpha: 0.75)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Invest with Chris',
                      style: TextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Diversify automatically across crypto, stocks & ETFs.',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoriesSection() {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        final alerts = state is AlertsLoaded ? state.alerts : <AiAlert>[];
        final isLoading = state is AlertsLoading;
        final stories = _makeStories(alerts);
        final screenWidth = MediaQuery.sizeOf(context).width;
        final cardWidth = screenWidth * 0.74;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Row(
                children: [
                  Text(
                    'What Chris sees',
                    style: TextStyles.titleMedium.copyWith(
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isLoading)
                    SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Text(
                'Decisions worth a second look this week',
                style: TextStyles.bodySmall.copyWith(
                  color: _textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            SizedBox(
              height: 176,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollUpdateNotification) {
                    final step = cardWidth + 12;
                    final page = (n.metrics.pixels / step).round();
                    if (page != _currentStory) {
                      setState(
                          () => _currentStory = page.clamp(0, stories.length - 1));
                    }
                  }
                  return false;
                },
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: stories.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: stories[i].onTap,
                    child: _StoryCard(story: stories[i], width: cardWidth),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(stories.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 6),
                  width: i == _currentStory ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _currentStory
                        ? _purple
                        : _textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }

  List<_Story> _makeStories(List<AiAlert> alerts) {
    final stories = <_Story>[];

    if (alerts.isNotEmpty) {
      final a = alerts.first;
      final isRisk = a.type == 'FRAUD' || a.type == 'BNPL_RISK';
      stories.add(_Story(
        tag: isRisk ? 'HEADS UP' : 'INSIGHT',
        tagColor: isRisk ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
        headline: a.title,
        detail: a.message,
        action: 'Review',
        onTap: () => context.push(RouteConstants.insightDetails.toPath),
      ));
    }

    stories.addAll([
      _Story(
        tag: 'SPENDING',
        tagColor: _purple,
        headline: 'Food delivery up 40% this week',
        detail: '\$128 vs your \$90 average. 4 days left in the month.',
        action: 'See breakdown',
        onTap: () => context.push(RouteConstants.fullPortfolioAnalysis.toPath),
      ),
      _Story(
        tag: 'OPPORTUNITY',
        tagColor: const Color(0xFF3B82F6),
        headline: '\$340 sitting idle in checking',
        detail: "No bills for 12 days. Your money isn't working.",
        action: 'Move to savings',
        onTap: () {},
      ),
      _Story(
        tag: 'MARKET',
        tagColor: _green,
        headline: 'ETH entry signal — 87% confidence',
        detail: 'Pattern matches your risk profile. Window is open.',
        action: 'View signal',
        onTap: () => context.push(RouteConstants.ethFlowDetail.toPath),
      ),
    ]);

    return stories;
  }

  Widget _buildLifeXCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _teal.withValues(alpha: 0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: _teal.withValues(alpha: 0.06),
              blurRadius: 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: _teal.withValues(alpha: 0.3), width: 0.7),
                  ),
                  child: Text(
                    'LIFEX × MONEY',
                    style: TextStyles.bodySmall.copyWith(
                      color: _teal,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.hub_outlined, color: _teal.withValues(alpha: 0.5), size: 14),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Life × Money Intelligence',
              style: TextStyles.titleMedium.copyWith(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Chris cross-references your LifeX data with financial patterns to surface decisions that benefit from more context.',
              style: TextStyles.bodySmall.copyWith(
                color: _textSecondary,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            _signalRow('ACTIVITY', 'High-load period detected', const Color(0xFFF59E0B)),
            const SizedBox(height: 8),
            _signalRow('FINANCE SIGNAL', '2 decisions flagged for review', const Color(0xFFEF4444)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => context.push(RouteConstants.lifex.toPath),
              child: Row(
                children: [
                  Text(
                    'Open LifeX',
                    style: TextStyles.bodySmall.copyWith(
                      color: _teal,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward_rounded, color: _teal, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signalRow(String label, String value, Color accent) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 38,
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyles.bodySmall.copyWith(
                color: _textSecondary,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyles.bodySmall.copyWith(
                color: _textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Row(
        children: [
          Expanded(
            child: _QuickTile(
              icon: Icons.mic_none_rounded,
              label: 'Talk\nto Chris',
              accent: _purple,
              onTap: () => context.push(RouteConstants.pantherAiChat.toPath),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Weekly\nRoast',
              accent: const Color(0xFFEF4444),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickTile(
              icon: Icons.tune_rounded,
              label: 'Set a\nRule',
              accent: const Color(0xFF3B82F6),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsBanner() {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        if (state is! AlertsLoaded || state.alerts.isEmpty) {
          return const SizedBox.shrink();
        }
        final alert = state.alerts.first;
        final color = switch (alert.type) {
          'FRAUD' => const Color(0xFFEF4444),
          'BNPL_RISK' => const Color(0xFFF59E0B),
          _ => const Color(0xFF3B82F6),
        };
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notifications_active_rounded, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.title,
                          style: TextStyle(
                              color: color, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(alert.message,
                          style: TextStyles.bodySmall.copyWith(
                              color: _textSecondary, fontSize: 12, height: 1.4)),
                      if (state.alerts.length > 1) ...[
                        const SizedBox(height: 6),
                        Text('+${state.alerts.length - 1} more heads-up from Chris',
                            style: TextStyle(
                                color: color.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _alertsBloc.add(AlertDismissRequested(alert.id)),
                  child: Icon(Icons.close_rounded, color: color.withValues(alpha: 0.6), size: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntelligence() {
    final attention = [
      _IntelData(
        icon: Icons.receipt_rounded,
        title: 'Bills',
        value: '5 upcoming',
        change: '\$840/mo',
        changeColor: const Color(0xFF3B82F6),
        onTap: () => context.push(RouteConstants.billsManagement.toPath),
      ),
      _IntelData(
        icon: Icons.credit_card_off_rounded,
        title: 'Debts',
        value: '\$318.8k',
        change: '-\$8.4k paid',
        changeColor: _green,
        onTap: () => context.push(RouteConstants.liabilitiesIntelligence.toPath),
      ),
    ];

    final moneyHealth = [
      _IntelData(
        icon: Icons.bar_chart_rounded,
        title: 'Budget',
        value: '67% used',
        change: '\$1,240 left',
        changeColor: _green,
        onTap: () => context.push(RouteConstants.budgetIntelligence.toPath),
      ),
      _IntelData(
        icon: Icons.trending_up_rounded,
        title: 'Net Worth',
        value: '\$47.2k',
        change: '+8.2% YTD',
        changeColor: _green,
        onTap: () => context.push(RouteConstants.netWorthIntelligence.toPath),
      ),
      _IntelData(
        icon: Icons.receipt_long_rounded,
        title: 'Taxes',
        value: '\$4,200',
        change: 'Apr 15 due',
        changeColor: const Color(0xFFF59E0B),
        onTap: () => context.push(RouteConstants.taxIntelligence.toPath),
      ),
    ];

    final grow = [
      _IntelData(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Portfolio',
        value: '\$45,890',
        change: '+12.4%',
        changeColor: _green,
        onTap: () => context.push(RouteConstants.portfolioIntelligence.toPath),
      ),
      _IntelData(
        icon: Icons.show_chart_rounded,
        title: 'Trading',
        value: '4 signals',
        change: '87% conf.',
        changeColor: _purple,
        onTap: () => context.push(RouteConstants.tradingAssistant.toPath),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(
            'Your Money',
            style: TextStyles.titleMedium.copyWith(
              color: _textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _buildAlertsBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            'On your schedule',
            style: TextStyles.bodySmall.copyWith(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: attention
                .map((d) => Expanded(child: _AttentionTile(data: d)))
                .expand((w) => [w, const SizedBox(width: 12)])
                .toList()
              ..removeLast(),
          ),
        ),
        const SizedBox(height: 20),
        _buildIntelSection('Money Health', moneyHealth),
        const SizedBox(height: 20),
        _buildIntelSection('Grow', grow),
      ],
    );
  }

  Widget _buildIntelSection(String title, List<_IntelData> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            title,
            style: TextStyles.bodySmall.copyWith(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemCount: tiles.length,
            itemBuilder: (_, i) => _IntelTile(data: tiles[i]),
          ),
        ),
      ],
    );
  }
}

class _RightNowChip extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const _RightNowChip({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PantherColors.border, width: 1),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 16),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: PantherColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: PantherColors.textSecondary,
                fontSize: 10.5,
                height: 1.25,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttentionTile extends StatelessWidget {
  final _IntelData data;
  const _AttentionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PantherColors.border, width: 1),
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
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: data.changeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: PantherColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.value,
                    style: const TextStyle(
                      color: PantherColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    data.change,
                    style: TextStyle(
                        color: data.changeColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFD1D5DB), size: 16),
          ],
        ),
      ),
    );
  }
}

class _Story {
  final String tag;
  final Color tagColor;
  final String headline;
  final String detail;
  final String action;
  final VoidCallback? onTap;

  const _Story({
    required this.tag,
    required this.tagColor,
    required this.headline,
    required this.detail,
    required this.action,
    this.onTap,
  });
}

class _StoryCard extends StatelessWidget {
  final _Story story;
  final double width;
  const _StoryCard({required this.story, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PantherColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: story.tagColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              story.tag,
              style: TextStyle(
                color: story.tagColor,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            story.headline,
            style: const TextStyle(
              color: PantherColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              story.detail,
              style: const TextStyle(
                color: PantherColors.textSecondary,
                fontSize: 11.5,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Text(
                story.action,
                style: TextStyle(
                  color: story.tagColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, color: story.tagColor, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PantherColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 10.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntelData {
  final IconData icon;
  final String title;
  final String value;
  final String change;
  final Color changeColor;
  final VoidCallback onTap;

  const _IntelData({
    required this.icon,
    required this.title,
    required this.value,
    required this.change,
    required this.changeColor,
    required this.onTap,
  });
}

class _IntelTile extends StatelessWidget {
  final _IntelData data;
  const _IntelTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: PantherColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: PantherColors.cardAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: const Color(0xFF374151), size: 14),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 14),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.title,
              style: const TextStyle(
                color: PantherColors.textSecondary,
                fontSize: 10,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.value,
              style: const TextStyle(
                color: PantherColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.change,
              style: TextStyle(color: data.changeColor, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
