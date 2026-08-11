import 'package:flutter/material.dart';
import 'choose_experience_page.dart';

class RiskDisclosurePage extends StatefulWidget {
  const RiskDisclosurePage({super.key});

  @override
  State<RiskDisclosurePage> createState() => _RiskDisclosurePageState();
}

class _RiskDisclosurePageState extends State<RiskDisclosurePage> {
  bool _agreed = false;

  static const _bg = Color(0xFFF7F8FA);
  static const _titleColor = Color(0xFF1A1A2E);
  static const _subtitleColor = Color(0xFF6B7080);
  static const _border = Color(0xFFEEEEEE);
  static const _red = Color(0xFFEF4444);
  static const _green = Color(0xFF22C55E);

  static const _risks = [
    _Risk(Icons.show_chart_rounded, 'Market Volatility',
        'Prices can swing sharply — you could lose some or all of your investment.',
        _red),
    _Risk(Icons.cancel_outlined, 'No Guaranteed Returns',
        'Past performance never guarantees future results.',
        Color(0xFFF59E0B)),
    _Risk(Icons.gavel_rounded, 'Regulatory Risks',
        'Rules vary by region and can change trading availability.',
        Color(0xFF8B5CF6)),
    _Risk(Icons.shield_outlined, 'Technology Risks',
        'Blockchain and smart contracts can carry technical vulnerabilities.',
        Color(0xFF3B82F6)),
    _Risk(Icons.psychology_outlined, 'AI Advisory Limitations',
        'Panther AI insights are informational, not financial advice.',
        Color(0xFF14B8A6)),
    _Risk(Icons.water_drop_outlined, 'Liquidity Risks',
        'Some assets may be hard to buy or sell at your desired price.',
        Color(0xFF10B981)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 16),
                    ..._risks.map(_buildRiskRow),
                    const SizedBox(height: 6),
                    _buildAgreeRow(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _border, width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _titleColor, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Risk Disclosure',
                    style: TextStyle(
                        color: _titleColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const Text('Step 1 of 3',
                    style: TextStyle(color: _subtitleColor, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _red.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: _red, size: 12),
                const SizedBox(width: 5),
                const Text('Required',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Before you\nbegin.',
            style: TextStyle(
                color: _titleColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.1)),
        const SizedBox(height: 8),
        const Text(
          'Digital asset trading involves real risk. Please review each point below.',
          style: TextStyle(color: _subtitleColor, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }

  Widget _buildRiskRow(_Risk risk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: risk.color.withValues(alpha: 0.12)),
            child: Icon(risk.icon, color: risk.color, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(risk.title,
                    style: const TextStyle(
                        color: _titleColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(risk.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _subtitleColor, fontSize: 11, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreeRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreed = !_agreed),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _agreed ? _green.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _agreed ? _green.withValues(alpha: 0.4) : _border,
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
                color: _agreed ? _green : Colors.white,
                border: Border.all(
                    color: _agreed ? _green : const Color(0xFFD5D8DE),
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
                'I understand the risks and have read all disclosures above.',
                style: TextStyle(
                    color: _agreed ? _titleColor : _subtitleColor,
                    fontSize: 12.5,
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
            color: _agreed ? _titleColor : const Color(0xFFE9EBEF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('Continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _agreed ? Colors.white : _subtitleColor,
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
