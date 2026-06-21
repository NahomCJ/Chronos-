import 'package:flutter/material.dart';
import 'choose_experience_page.dart';

class RiskDisclosurePage extends StatefulWidget {
  const RiskDisclosurePage({super.key});

  @override
  State<RiskDisclosurePage> createState() => _RiskDisclosurePageState();
}

class _RiskDisclosurePageState extends State<RiskDisclosurePage> {
  bool _agreed = false;
  int? _expanded;

  static const _bg = Color(0xFF06060E);
  static const _card = Color(0xFF0F0F1C);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

  final _risks = [
    _Risk(Icons.show_chart_rounded, 'Market Volatility',
        'Cryptocurrency markets are highly volatile. Prices can fluctuate significantly within short periods. You may lose some or all of your investment.',
        _red),
    _Risk(Icons.cancel_outlined, 'No Guaranteed Returns',
        'Past performance is not indicative of future results. Only invest what you can afford to lose entirely.',
        Color(0xFFF59E0B)),
    _Risk(Icons.gavel_rounded, 'Regulatory Risks',
        'The regulatory environment for digital assets varies by jurisdiction and is subject to rapid change, which may affect trading availability.',
        Color(0xFF8B5CF6)),
    _Risk(Icons.shield_outlined, 'Technology Risks',
        'Blockchain networks and smart contracts may contain vulnerabilities. We implement security measures but cannot guarantee complete protection.',
        Color(0xFF3B82F6)),
    _Risk(Icons.psychology_outlined, 'AI Advisory Limitations',
        'Panther AI provides market insights for informational purposes only. Nothing herein constitutes financial, investment, or legal advice.',
        Color(0xFF14B8A6)),
    _Risk(Icons.water_drop_outlined, 'Liquidity Risks',
        'Some digital assets may have limited liquidity, making it difficult to buy or sell at desired prices or quantities.',
        Color(0xFF10B981)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
            SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 24),
                    ..._risks.asMap().entries.map(
                          (e) => _buildRiskCard(e.key, e.value),
                        ),
                    const SizedBox(height: 24),
                    _buildAgreeRow(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
          ],
        ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Risk Disclosure',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Step 1 of 3',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _red.withValues(alpha: 0.3), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: _red, size: 12),
                const SizedBox(width: 5),
                Text('Required',
                    style: TextStyle(
                        color: _red, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _amber.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _amber.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: _amber, size: 18),
              const SizedBox(width: 8),
              const Text('Before you begin',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Digital asset trading involves significant risk. Please read and understand each risk category below before proceeding.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(int index, _Risk risk) {
    final isExpanded = _expanded == index;
    return GestureDetector(
      onTap: () => setState(() => _expanded = isExpanded ? null : index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? risk.color.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.06),
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: risk.color.withValues(alpha: 0.12)),
                    child: Icon(risk.icon, color: risk.color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(risk.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 20),
                ],
              ),
            ),
            if (isExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: risk.color.withValues(alpha: 0.15),
                          width: 0.8)),
                ),
                child: Text(risk.detail,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.55)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreeRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreed = !_agreed),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _agreed
              ? const Color(0xFF22C55E).withValues(alpha: 0.08)
              : _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _agreed
                ? const Color(0xFF22C55E).withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _agreed
                    ? const Color(0xFF22C55E)
                    : Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                    color: _agreed
                        ? const Color(0xFF22C55E)
                        : Colors.white.withValues(alpha: 0.2),
                    width: 1.5),
              ),
              child: _agreed
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'I understand the risks involved in trading digital assets and have read all disclosures above.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: _agreed ? 0.85 : 0.55),
                    fontSize: 13,
                    height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: GestureDetector(
        onTap: _agreed
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChooseExperiencePage()),
                )
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _agreed ? _amber : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _agreed
                ? [
                    BoxShadow(
                        color: _amber.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Text('Continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _agreed
                      ? Colors.black
                      : Colors.white.withValues(alpha: 0.3),
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _Risk {
  final IconData icon;
  final String title;
  final String detail;
  final Color color;
  const _Risk(this.icon, this.title, this.detail, this.color);
}
