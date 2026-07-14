import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/theme/panther_colors.dart';

class PantherAiSettingsPage extends StatefulWidget {
  const PantherAiSettingsPage({super.key});

  @override
  State<PantherAiSettingsPage> createState() => _PantherAiSettingsPageState();
}

class _PantherAiSettingsPageState extends State<PantherAiSettingsPage> {
  double _riskTolerance = 0.5;
  double _automationLevel = 0.8;
  String _selectedPersonality = 'friendly';
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantherColors.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A))),
          ),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
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
                        _buildAIPreferences(),
                        const SizedBox(height: 22),
                        _buildNotifications(),
                        const SizedBox(height: 22),
                        _buildSecurityPrivacy(),
                        const SizedBox(height: 22),
                        _buildAccount(),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Column(
            children: [
              Text(
                'Settings',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                'Personalize Panther AI',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyles.titleMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _buildAIPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('AI Preferences'),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PantherColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSliderRow('Risk Tolerance', _riskTolerance, _riskLabel(), (
                v,
              ) {
                setState(() => _riskTolerance = v);
              }),
              Divider(
                color: PantherColors.border,
                height: 20,
                thickness: 0.5,
              ),
              _buildSliderRow(
                'Automation Level',
                _automationLevel,
                'Full auto',
                (v) {
                  setState(() => _automationLevel = v);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'AI Personality',
                style: TextStyles.bodySmall.copyWith(
                  color: PantherColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              _buildPersonalityOption(
                'friendly',
                'Friendly',
                'Warm and encouraging',
              ),
              const SizedBox(height: 8),
              _buildPersonalityOption(
                'professional',
                'Professional',
                'Direct and formal',
              ),
              const SizedBox(height: 8),
              _buildPersonalityOption(
                'coaching',
                'Coaching',
                'Educational and supportive',
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  String _riskLabel() {
    if (_riskTolerance < 0.33) return 'Conservative';
    if (_riskTolerance < 0.66) return 'Moderate';
    return 'Aggressive';
  }

  Widget _buildSliderRow(
    String label,
    double value,
    String valueLabel,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyles.bodyMedium.copyWith(
                color: PantherColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valueLabel,
              style: TextStyles.bodySmall.copyWith(
                color: PantherColors.brand,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: PantherColors.brand,
            inactiveTrackColor: PantherColors.border,
            thumbColor: PantherColors.brand,
            overlayColor: PantherColors.brand.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildPersonalityOption(String value, String title, String subtitle) {
    final isSelected = _selectedPersonality == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPersonality = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? PantherColors.brand.withValues(alpha: 0.08) : PantherColors.cardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? PantherColors.brand.withValues(alpha: 0.6)
                    : PantherColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.bodyMedium.copyWith(
                color: PantherColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyles.bodySmall.copyWith(
                color: PantherColors.textSubtle,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Notifications'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PantherColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PantherColors.cardAlt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: PantherColors.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Push Notifications',
                      style: TextStyles.bodyMedium.copyWith(
                        color: PantherColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Get AI insights in real-time',
                      style: TextStyles.bodySmall.copyWith(
                        color: PantherColors.textSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
                activeColor: Colors.white,
                activeTrackColor: PantherColors.positive,
                inactiveTrackColor: PantherColors.border,
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityPrivacy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Security & Privacy'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PantherColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              _buildNavRow(
                Icons.lock_outline,
                'Security Settings',
                'Biometric & PIN',
                false,
              ),
              _buildNavRow(
                Icons.storage_outlined,
                'Data Permissions',
                'Manage what AI can access',
                false,
              ),
              _buildNavRow(
                Icons.shield_outlined,
                'Privacy Policy',
                'How we protect your data',
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavRow(
    IconData icon,
    String title,
    String subtitle,
    bool isLast,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PantherColors.cardAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: PantherColors.textSecondary,
                  size: 18,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyles.bodySmall.copyWith(
                        color: PantherColors.textSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: PantherColors.textSubtle,
                size: 20,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: PantherColors.border,
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PantherColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: PantherColors.brand.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: PantherColors.brand,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyles.bodyMedium.copyWith(
                              color: PantherColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Abraham',
                            style: TextStyles.bodySmall.copyWith(
                              color: PantherColors.textSubtle,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: PantherColors.textSubtle,
                      size: 20,
                    ),
                  ],
                ),
              ),
              Divider(
                color: PantherColors.border,
                height: 1,
                thickness: 0.5,
                indent: 16,
                endIndent: 16,
              ),
              _buildTrustScoreCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: PantherColors.brand, size: 28),
          const SizedBox(height: 8),
          Text(
            'AI Trust Score',
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '94%',
            style: TextStyles.titleLarge.copyWith(
              color: PantherColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Excellent relationship',
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
