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
        MaterialPageRoute(builder: (context) => const SetupWalletPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    // Responsive sizing
    final horizontalPadding =
        isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final headerFontSize =
        isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);
    final titleFontSize = isSmallScreen ? 22.0 : (isMediumScreen ? 24.0 : 28.0);
    final bodyFontSize = isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final cardTitleFontSize =
        isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 22.0);
    final buttonHeight = isSmallScreen ? 50.0 : (isMediumScreen ? 54.0 : 56.0);
    final verticalSpacing =
        isSmallScreen ? 16.0 : (isMediumScreen ? 18.0 : 20.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const RiskDisclosurePage(),
                              ),
                            ),
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'BlockHub',
                        style: TextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: headerFontSize,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: isSmallScreen ? 30 : 36),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: verticalSpacing),

                        Text(
                          'Choose Your Experience',
                          style: TextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 6 : 8),

                        Text(
                          'We\'ll tailor the platform to match your trading style',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: bodyFontSize,
                          ),
                        ),

                        SizedBox(height: verticalSpacing * 1.5),

                        // Beginner Option
                        _buildExperienceCard(
                          icon: Icons.auto_awesome_outlined,
                          title: 'Beginner',
                          subtitle: 'Perfect for those new to crypto trading',
                          features: [
                            'Simplified user interface',
                            'Guided trading flows',
                            'Essential market data only',
                            'Educational tooltip',
                            'Pre-set order types',
                          ],
                          isSelected: _selectedExperience == 'beginner',
                          onTap:
                              () => setState(
                                () => _selectedExperience = 'beginner',
                              ),
                          cardTitleFontSize: cardTitleFontSize,
                          bodyFontSize: bodyFontSize,
                          isSmallScreen: isSmallScreen,
                        ),

                        SizedBox(height: verticalSpacing),

                        // Advanced Option
                        _buildExperienceCard(
                          icon: Icons.bar_chart,
                          title: 'Advanced',
                          subtitle:
                              'Full trading toolkit for experienced traders',
                          features: [
                            'Advanced charting tools',
                            'Order book & depth charts',
                            'Multiple order types',
                            'Technical indicators',
                            'API access available',
                          ],
                          isSelected: _selectedExperience == 'advanced',
                          onTap:
                              () => setState(
                                () => _selectedExperience = 'advanced',
                              ),
                          cardTitleFontSize: cardTitleFontSize,
                          bodyFontSize: bodyFontSize,
                          isSmallScreen: isSmallScreen,
                        ),

                        SizedBox(height: verticalSpacing * 1.5),
                      ],
                    ),
                  ),
                ),

                // Bottom Buttons
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    children: [
                      // Exit Button
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: isSmallScreen ? 18 : 20),
                              SizedBox(width: isSmallScreen ? 6 : 8),
                              Text(
                                'Exit BlockHub',
                                style: TextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 10 : 12),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed:
                              _selectedExperience != null
                                  ? () => _continueToWalletSetup(
                                    _selectedExperience!,
                                  )
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedExperience != null
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyles.titleMedium.copyWith(
                              color:
                                  _selectedExperience != null
                                      ? Colors.black
                                      : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                    ],
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
    required double cardTitleFontSize,
    required double bodyFontSize,
    required bool isSmallScreen,
  }) {
    final cardPadding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 22.0 : 24.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFFF59E0B)
                    : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFF59E0B),
                    size: iconSize,
                  ),
                ),
                const Spacer(),
                Container(
                  width: isSmallScreen ? 20 : 24,
                  height: isSmallScreen ? 20 : 24,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFFF59E0B)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFFF59E0B)
                              : Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: isSmallScreen ? 12 : 14,
                          )
                          : null,
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              title,
              style: TextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: cardTitleFontSize,
              ),
            ),
            SizedBox(height: isSmallScreen ? 3 : 4),
            Text(
              subtitle,
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: bodyFontSize,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            ...features.map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: isSmallScreen ? 5 : 6),
                      width: isSmallScreen ? 5 : 6,
                      height: isSmallScreen ? 5 : 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: bodyFontSize,
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
