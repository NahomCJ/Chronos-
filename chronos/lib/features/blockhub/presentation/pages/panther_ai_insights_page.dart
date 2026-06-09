import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';

class PantherAiInsightsPage extends StatefulWidget {
  const PantherAiInsightsPage({super.key});

  @override
  State<PantherAiInsightsPage> createState() => _PantherAiInsightsPageState();
}

class _PantherAiInsightsPageState extends State<PantherAiInsightsPage> {
  final Map<int, bool> _automationToggles = {0: true, 1: false, 2: true, 3: false};

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isSmall),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Signal cards row
                        Row(
                          children: [
                            Expanded(child: _signalCard('📈', 'Bullish', 'Market cap +3.2% today', const Color(0xFF10B981))),
                            const SizedBox(width: 12),
                            Expanded(child: _signalCard('⚡', 'Volatile', 'VIX up 18% this week', const Color(0xFFF59E0B))),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Market vibe
                        _sectionLabel('Market Vibe'),
                        const SizedBox(height: 10),
                        _vibeCard(isSmall),

                        const SizedBox(height: 20),

                        // AI Picks
                        _sectionLabel('AI Picks rn 🔥'),
                        const SizedBox(height: 10),
                        _aiPicksCard(isSmall),

                        const SizedBox(height: 20),

                        // Automation
                        _sectionLabel('Automations'),
                        const SizedBox(height: 10),
                        _automationCard(isSmall),

                        const SizedBox(height: 20),

                        // Sector heat
                        _sectionLabel('Sector Heat'),
                        const SizedBox(height: 10),
                        _heatmapCard(isSmall),

                        const SizedBox(height: 20),

                        // Risk check
                        _sectionLabel('Risk Check ⚠️'),
                        const SizedBox(height: 10),
                        _riskCard(isSmall),

                        const SizedBox(height: 16),
                        _disclaimer(isSmall),
                        const SizedBox(height: 100),
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

  Widget _buildHeader(BuildContext context, bool isSmall) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Panther AI', style: TextStyles.titleLarge.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 18 : 20,
                )),
                Text('Your market bestie 🐆', style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: isSmall ? 11 : 12,
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('Live', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(
    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
  ));

  Widget _signalCard(String emoji, String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _vibeCard(bool isSmall) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _vibeRow('Trend', 'Bullish 🐂', const Color(0xFF10B981)),
          const Divider(color: Colors.white12, height: 20),
          _vibeRow('Volatility', 'High ⚡', const Color(0xFFF59E0B)),
          const Divider(color: Colors.white12, height: 20),
          _vibeRow('Liquidity', 'All good 💧', const Color(0xFF10B981)),
          const Divider(color: Colors.white12, height: 20),
          _vibeRow('Fear & Greed', '62 Greedy 😏', const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _vibeRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _aiPicksCard(bool isSmall) {
    final picks = [
      ('BTC', 'Strong breakout above \$64k support. Volume lit 🔥', const Color(0xFFF7931A), '+2.3%'),
      ('SOL', 'NFT activity spiking. Ecosystem heat is real', const Color(0xFF9945FF), '+4.1%'),
      ('MATIC', 'L2 season incoming. Scaling narrative back', const Color(0xFF8247E5), '+3.8%'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: picks.asMap().entries.map((e) {
          final p = e.value;
          return Column(
            children: [
              if (e.key > 0) const Divider(color: Colors.white12, height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: p.$3.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: p.$3.withValues(alpha: 0.4)),
                    ),
                    child: Center(child: Text(p.$1.substring(0, 2), style: TextStyle(color: p.$3, fontSize: 10, fontWeight: FontWeight.w800))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(p.$2, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, height: 1.4)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(p.$4, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _automationCard(bool isSmall) {
    final automations = [
      (0, '🔄', 'Auto DCA', 'Buy \$50 of BTC every Monday'),
      (1, '🚨', 'Price Alert', 'Ping me when BTC hits \$70k'),
      (2, '📉', 'Stop Loss', 'Sell if portfolio drops 10%'),
      (3, '🌙', 'Moon Bag', 'Hold 5% never auto-sell'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: automations.asMap().entries.map((entry) {
          final a = entry.value;
          final isLast = entry.key == automations.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Text(a.$2, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.$3, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(a.$4, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _automationToggles[a.$1] ?? false,
                      onChanged: (v) => setState(() => _automationToggles[a.$1] = v),
                      activeColor: const Color(0xFF8B5CF6),
                      activeTrackColor: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(color: Colors.white12, height: 0),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _heatmapCard(bool isSmall) {
    final sectors = [
      ('Large Caps', '+5.2%', true),
      ('DeFi', '+3.8%', true),
      ('Layer 2', '-1.2%', false),
      ('Tokenized', '+1.1%', true),
    ];
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: sectors.map((s) {
        final color = s.$3 ? const Color(0xFF10B981) : const Color(0xFFEF4444);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.$1, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
              Text(s.$2, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _riskCard(bool isSmall) {
    return Column(
      children: [
        _riskAlert('Crazy volatility rn', 'Use limit orders so you don\'t get rekt on slippage 😬'),
        const SizedBox(height: 10),
        _riskAlert('Weekend liquidity dip', 'Markets thin on weekends, prices move wild. Stay sharp 👀'),
      ],
    );
  }

  Widget _riskAlert(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF92400E).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer(bool isSmall) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        'Not financial advice. Do your own research. Panther AI is for info only, don\'t bet what you can\'t lose.',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, height: 1.4),
      ),
    );
  }
}
