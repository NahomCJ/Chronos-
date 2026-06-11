import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/alerts_bloc.dart';
import '../bloc/alerts_event.dart';
import '../bloc/alerts_state.dart';
import '../widgets/chris_voice_orb.dart';
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

  static const _awareness = [
    'Tracking 4 spending patterns',
    'Markets stable · No action needed',
    '2 things noticed this week',
    'LifeX sync complete',
  ];

  @override
  void initState() {
    super.initState();
    _alertsBloc = GetIt.I<AlertsBloc>();
    _alertsBloc.add(const AlertsLoadRequested());

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
        backgroundColor: const Color(0xFF06060E),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildOrbHero()),
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

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PANTHER',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.32),
              fontSize: 11,
              fontWeight: FontWeight.w600,
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
                    color: const Color(0xFF22C55E),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(
                          alpha: 0.25 + _glowCtrl.value * 0.45,
                        ),
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
                  color: const Color(0xFF22C55E),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () =>
                    context.push(RouteConstants.pantherAiSettings.toPath),
                child: Icon(
                  Icons.tune_rounded,
                  color: Colors.white.withValues(alpha: 0.32),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Orb Hero ────────────────────────────────────────────────────────────────

  Widget _buildOrbHero() {
    return GestureDetector(
      onTap: () => context.push(RouteConstants.pantherAiChat.toPath),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 275,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient glow
            AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFDC8F4A).withValues(
                        alpha: 0.07 + _glowCtrl.value * 0.05,
                      ),
                      const Color(0xFFDC8F4A).withValues(alpha: 0.02),
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
                const ChrisVoiceOrb(state: OrbState.idle, size: 130),
                const SizedBox(height: 22),
                Text(
                  'Tap to talk with Chris',
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: anim,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _awareness[_awarenessIndex],
                    key: ValueKey(_awarenessIndex),
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFFDC8F4A).withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Stories Section ─────────────────────────────────────────────────────────

  Widget _buildStoriesSection() {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        final alerts = state is AlertsLoaded ? state.alerts : <AiAlert>[];
        final isLoading = state is AlertsLoading;
        final stories = _makeStories(alerts);
        final screenWidth = MediaQuery.sizeOf(context).width;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Text(
                    'What Chris sees',
                    style: TextStyles.titleMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
                          Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 205,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollUpdateNotification) {
                    final cardWidth = screenWidth * 0.80 + 12;
                    final page = (n.metrics.pixels / cardWidth).round();
                    if (page != _currentStory) {
                      setState(() => _currentStory = page.clamp(0, stories.length - 1));
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
                    child: _StoryCard(
                      story: stories[i],
                      width: screenWidth * 0.80,
                    ),
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
                        ? const Color(0xFFDC8F4A)
                        : Colors.white.withValues(alpha: 0.18),
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
        tagColor: isRisk ? const Color(0xFFE07040) : const Color(0xFFF0B100),
        headline: a.title,
        detail: a.message,
        action: 'Review',
        onTap: () => context.push(RouteConstants.insightDetails.toPath),
      ));
    }

    stories.addAll([
      _Story(
        tag: 'SPENDING',
        tagColor: const Color(0xFFDC8F4A),
        headline: 'Food delivery up 40% this week',
        detail: '\$128 vs your \$90 average. 4 days left in the month.',
        action: 'See breakdown',
        onTap: () => context.push(RouteConstants.fullPortfolioAnalysis.toPath),
      ),
      _Story(
        tag: 'OPPORTUNITY',
        tagColor: const Color(0xFF6A8EDC),
        headline: '\$340 sitting idle in checking',
        detail: "No bills for 12 days. Your money isn't working.",
        action: 'Move to savings',
        onTap: () {},
      ),
      _Story(
        tag: 'MARKET',
        tagColor: const Color(0xFF22C55E),
        headline: 'ETH entry signal — 87% confidence',
        detail: 'Pattern matches your risk profile. Window is open.',
        action: 'View signal',
        onTap: () => context.push(RouteConstants.ethFlowDetail.toPath),
      ),
    ]);

    return stories;
  }

  // ── LifeX Card ──────────────────────────────────────────────────────────────

  Widget _buildLifeXCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1C1B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.22),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF14B8A6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    'LIFEX × MONEY',
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF14B8A6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.hub_outlined,
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.45),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Life × Money Intelligence',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chris cross-references your LifeX data with financial patterns to surface decisions that benefit from more context.',
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.38),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            _signalRow(
              'ACTIVITY',
              'High-load period detected',
              const Color(0xFFF0B100),
            ),
            const SizedBox(height: 10),
            _signalRow(
              'FINANCE SIGNAL',
              '2 decisions flagged for review',
              const Color(0xFFE07040),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => context.push(RouteConstants.lifex.toPath),
              child: Row(
                children: [
                  Text(
                    'Open LifeX',
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF14B8A6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF14B8A6),
                    size: 14,
                  ),
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
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Quick Actions ───────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Row(
        children: [
          Expanded(
            child: _QuickTile(
              icon: Icons.mic_none_rounded,
              label: 'Talk\nto Chris',
              accent: const Color(0xFFDC8F4A),
              onTap: () => context.push(RouteConstants.pantherAiChat.toPath),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Weekly\nRoast',
              accent: const Color(0xFFE07040),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickTile(
              icon: Icons.tune_rounded,
              label: 'Set a\nRule',
              accent: const Color(0xFF6A8EDC),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ── Intelligence Tiles ──────────────────────────────────────────────────────

  Widget _buildIntelligence() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(
            'Intelligence',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _IntelTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Portfolio',
                value: '\$45,890',
                change: '+12.4%',
                changeColor: const Color(0xFF22C55E),
                onTap: () => context
                    .push(RouteConstants.portfolioIntelligence.toPath),
              ),
              const SizedBox(width: 12),
              _IntelTile(
                icon: Icons.show_chart_rounded,
                title: 'Trading',
                value: '4 signals',
                change: '87% conf.',
                changeColor: const Color(0xFFDC8F4A),
                onTap: () =>
                    context.push(RouteConstants.tradingAssistant.toPath),
              ),
              const SizedBox(width: 12),
              _IntelTile(
                icon: Icons.payment_rounded,
                title: 'TickPay',
                value: '\$420 safe',
                change: 'This month',
                changeColor: const Color(0xFF22C55E),
                onTap: () => context.push(RouteConstants.tickPayAi.toPath),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Story Data ────────────────────────────────────────────────────────────────

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

// ── Story Card ────────────────────────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  final _Story story;
  final double width;

  const _StoryCard({required this.story, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: story.tagColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: story.tagColor.withValues(alpha: 0.28),
                width: 0.7,
              ),
            ),
            child: Text(
              story.tag,
              style: TextStyle(
                color: story.tagColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            story.headline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              story.detail,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.42),
                fontSize: 13,
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                story.action,
                style: TextStyle(
                  color: story.tagColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                color: story.tagColor,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Tile ────────────────────────────────────────────────────────────────

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
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accent.withValues(alpha: 0.18),
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Intel Tile ────────────────────────────────────────────────────────────────

class _IntelTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String change;
  final Color changeColor;
  final VoidCallback onTap;

  const _IntelTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.change,
    required this.changeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            width: 0.7,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFDC8F4A), size: 18),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              change,
              style: TextStyle(color: changeColor, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
