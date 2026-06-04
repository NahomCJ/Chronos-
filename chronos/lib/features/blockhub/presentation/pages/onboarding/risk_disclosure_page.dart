import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'choose_experience_page.dart';

class RiskDisclosurePage extends StatefulWidget {
  const RiskDisclosurePage({super.key});

  @override
  State<RiskDisclosurePage> createState() => _RiskDisclosurePageState();
}

class _RiskDisclosurePageState extends State<RiskDisclosurePage> {
  bool _isAgreed = false;
  final Set<int> _expanded = {};

  final _risks = [
    _Risk('Market Volatility',
        'Cryptocurrency markets are highly volatile. Prices can fluctuate significantly and you may lose some or all of your investment.'),
    _Risk('No Guaranteed Returns',
        'Past performance is not indicative of future results. Only invest what you can afford to lose.'),
    _Risk('Regulatory Risks',
        'The regulatory environment for digital assets varies by jurisdiction and is subject to change.'),
    _Risk('Technology Risks',
        'Blockchain and smart contracts may contain vulnerabilities. We implement security measures but cannot guarantee complete protection.'),
    _Risk('AI Advisory Limitations',
        'Panther AI provides market insights for informational purposes only. Not financial advice.'),
    _Risk('Liquidity Risks',
        'Some digital assets may have limited liquidity, making it difficult to buy or sell at desired prices.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ── Dark header ────────────────────────────────────────────────
          Container(
            color: const Color(0xFF0D0A1E),
            child: SafeArea(
              bottom: false,
              child: _buildHeader(context),
            ),
          ),
          // ── White scrollable body ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Disclosure',
                    style: TextStyles.titleLarge.copyWith(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please read carefully before proceeding',
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF888888),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Accordion items
                  ..._risks.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _accordionItem(e.key, e.value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Agreement checkbox
                  GestureDetector(
                    onTap: () => setState(() => _isAgreed = !_isAgreed),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isAgreed
                            ? const Color(0xFFFFF8ED)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isAgreed
                              ? const Color(0xFFDC8F4A)
                              : const Color(0xFFEEEEEE),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _isAgreed
                                  ? const Color(0xFFDC8F4A)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isAgreed
                                    ? const Color(0xFFDC8F4A)
                                    : const Color(0xFFCCCCCC),
                                width: 2,
                              ),
                            ),
                            child: _isAgreed
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 12)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'I confirm I have read and understand the risks. AI-generated insights are informational only and do not constitute financial advice.',
                              style: TextStyles.bodySmall.copyWith(
                                color: const Color(0xFF555555),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A1A1A),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text('Exit BlockHub',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAgreed
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChooseExperiencePage(),
                                ),
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D0A1E),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFDDDDDD),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: _isAgreed
                              ? Colors.white
                              : const Color(0xFF999999),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 17),
            ),
          ),
          Expanded(
            child: Text(
              'BlockHub',
              textAlign: TextAlign.center,
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _accordionItem(int index, _Risk risk) {
    final isOpen = _expanded.contains(index);
    return GestureDetector(
      onTap: () => setState(() {
        if (isOpen) {
          _expanded.remove(index);
        } else {
          _expanded.add(index);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isOpen
                ? const Color(0xFFDC8F4A).withValues(alpha: 0.4)
                : const Color(0xFFEEEEEE),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    risk.title,
                    style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF999999),
                  size: 20,
                ),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: 8),
              Text(
                risk.description,
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF666666),
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Risk {
  final String title, description;
  const _Risk(this.title, this.description);
}
