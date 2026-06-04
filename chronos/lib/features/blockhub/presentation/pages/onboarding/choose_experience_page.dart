import 'package:chronos_bank/features/blockhub/presentation/pages/onboarding/risk_disclosure_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/theme/text_theme.dart';
import 'setup_wallet_page.dart';

class ChooseExperiencePage extends StatefulWidget {
  const ChooseExperiencePage({super.key});

  @override
  State<ChooseExperiencePage> createState() => _ChooseExperiencePageState();
}

class _ChooseExperiencePageState extends State<ChooseExperiencePage> {
  String? _selectedExperience;

  Future<void> _continueToWalletSetup(String experience) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('blockhub_onboarding_completed', true);
    await prefs.setString('blockhub_experience_level', experience);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetupWalletPage()),
      );
    }
  }

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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RiskDisclosurePage()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'BlockHub',
                        textAlign: TextAlign.center,
                        style: TextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 34),
                  ],
                ),
              ),
            ),
          ),

          // ── White body ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Choose Your Experience',
                    style: TextStyles.headlineMedium.copyWith(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We\'ll tailor the platform to match your trading style',
                    style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF888888),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Beginner card
                  _buildExperienceCard(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Beginner',
                    subtitle: 'Perfect for those new to crypto trading',
                    features: [
                      'Simplified user interface',
                      'Guided trading flows',
                      'Essential market data only',
                      'Educational tooltips',
                      'Pre-set order types',
                    ],
                    isSelected: _selectedExperience == 'beginner',
                    onTap: () =>
                        setState(() => _selectedExperience = 'beginner'),
                  ),

                  const SizedBox(height: 12),

                  // Advanced card
                  _buildExperienceCard(
                    icon: Icons.bar_chart,
                    title: 'Advanced',
                    subtitle: 'Full trading toolkit for experienced traders',
                    features: [
                      'Advanced charting tools',
                      'Order book & depth charts',
                      'Multiple order types',
                      'Technical indicators',
                      'API access available',
                    ],
                    isSelected: _selectedExperience == 'advanced',
                    onTap: () =>
                        setState(() => _selectedExperience = 'advanced'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom buttons ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Exit BlockHub',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedExperience != null
                        ? () => _continueToWalletSetup(_selectedExperience!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0A1E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFDDDDDD),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: _selectedExperience != null
                            ? Colors.white
                            : const Color(0xFF999999),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
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

  Widget _buildExperienceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> features,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEEEEEE),
            width: isSelected ? 2 : 1,
          ),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon,
                      color: const Color(0xFFF59E0B), size: 20),
                ),
                const Spacer(),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF59E0B)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFCCCCCC),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 13)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyles.titleLarge.copyWith(
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyles.bodyMedium.copyWith(
                color: const Color(0xFF888888),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF555555),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
