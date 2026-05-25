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
    _Risk(
      'Market Volatility',
      'Cryptocurrency and digital asset markets are highly volatile. Prices can fluctuate significantly within short periods, and you may lose some or all of your investment.',
    ),
    _Risk(
      'No Guaranteed Returns',
      'Past performance is not indicative of future results. There is no guarantee of profit, and you should only invest what you can afford to lose.',
    ),
    _Risk(
      'Regulatory Risks',
      'The regulatory environment for digital assets varies by jurisdiction and is subject to change. Changes in regulations may affect the value and liquidity of your assets.',
    ),
    _Risk(
      'Technology Risks',
      'Blockchain technology and smart contracts may contain vulnerabilities. While we implement security measures, we cannot guarantee complete protection against all risks.',
    ),
    _Risk(
      'AI Advisory Limitations',
      'Panther AI provides market insights and analysis for informational purposes only. AI-generated content is not financial advice and should not be the sole basis for investment decisions.',
    ),
    _Risk(
      'Liquidity Risks',
      'Some digital assets may have limited liquidity, making it difficult to buy or sell at desired prices or in desired quantities.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Risk Disclosure',
                          style: TextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Please read carefully before proceeding',
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Accordion items
                        ..._risks.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _accordionItem(e.key, e.value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Agreement checkbox
                        GestureDetector(
                          onTap: () => setState(() => _isAgreed = !_isAgreed),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color:
                                        _isAgreed
                                            ? const Color(0xFFDC8F4A)
                                            : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          _isAgreed
                                              ? const Color(0xFFDC8F4A)
                                              : Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      _isAgreed
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 13,
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'I confirm that I have read and understand the risks associated with trading crypto and digital assets, and acknowledge that any AI-generated insights are provided for informational purposes only and do not constitute financial advice.',
                                    style: TextStyles.bodySmall.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 12.5,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.close, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Exit BlockHub',
                                  style: TextStyles.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isAgreed
                                    ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const ChooseExperiencePage(),
                                      ),
                                    )
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyles.labelLarge.copyWith(
                                color:
                                    _isAgreed
                                        ? Colors.black
                                        : Colors.white.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'BlockHub',
              textAlign: TextAlign.center,
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _accordionItem(int index, _Risk risk) {
    final isOpen = _expanded.contains(index);
    return GestureDetector(
      onTap:
          () => setState(() {
            if (isOpen) {
              _expanded.remove(index);
            } else {
              _expanded.add(index);
            }
          }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  risk.title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 22,
                ),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: 10),
              Text(
                risk.description,
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
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
