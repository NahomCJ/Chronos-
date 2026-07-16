import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/theme/panther_colors.dart';

class YourInsightsModal extends StatelessWidget {
  const YourInsightsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => const YourInsightsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = size.width / 390;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: PantherColors.bg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * scale),
          topRight: Radius.circular(20 * scale),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: 16 * scale,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8 * scale),
                    decoration: const BoxDecoration(
                      color: PantherColors.cardAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: PantherColors.textPrimary,
                      size: 20 * scale,
                    ),
                  ),
                ),
                Text(
                  'Your Insights',
                  style: TextStyles.titleMedium.copyWith(
                    color: PantherColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18 * scale,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8 * scale),
                  decoration: const BoxDecoration(
                    color: PantherColors.cardAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.filter_alt_sharp,
                    color: PantherColors.textPrimary,
                    size: 20 * scale,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Column(
                children: [
                  _buildInsightCard(
                    icon: Icons.attach_money_rounded,
                    iconColor: const Color(0xFFF0B100),
                    iconBgColor: const Color(0x22F0B100),
                    title: 'Dining spending',
                    confidence: '89%',
                    confidenceColor: const Color(0xFF20C55D),
                    description:
                        'Your dining expenses are 23% above your monthly average',
                    scale: scale,
                  ),
                  SizedBox(height: 12 * scale),
                  _buildInsightCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFFF6467),
                    iconBgColor: const Color(0x22FF6467),
                    title: 'BNPL risk detected',
                    confidence: '94%',
                    confidenceColor: const Color(0xFF20C55D),
                    description:
                        'Upcoming BNPL payment may affect your credit score',
                    scale: scale,
                    showFix: true,
                  ),
                  SizedBox(height: 12 * scale),
                  _buildInsightCard(
                    icon: Icons.credit_card,
                    iconColor: const Color(0xFF00D4FF),
                    iconBgColor: const Color(0x2200D4FF),
                    title: 'Unused subscription',
                    confidence: '100%',
                    confidenceColor: const Color(0xFF20C55D),
                    description:
                        'You haven\'t used Netflix in the last 30 days',
                    scale: scale,
                    showFix: true,
                  ),
                  SizedBox(height: 12 * scale),
                  _buildInsightCard(
                    icon: Icons.thumb_up,
                    iconColor: const Color(0xFF20C55D),
                    iconBgColor: const Color(0x2220C55D),
                    title: 'Savings goal',
                    confidence: '100%',
                    confidenceColor: const Color(0xFF20C55D),
                    description:
                        'You\'re on track to reach your emergency fund goal',
                    scale: scale,
                    showFix: false,
                  ),
                  SizedBox(height: 12 * scale),
                  _buildInsightCard(
                    icon: Icons.trending_up,
                    iconColor: const Color(0xFF20C55D),
                    iconBgColor: const Color(0x2220C55D),
                    title: 'Portfolio returns',
                    confidence: '100%',
                    confidenceColor: const Color(0xFF20C55D),
                    description:
                        'Your portfolio has outperformed the market by 4.2%',
                    scale: scale,
                    showFix: false,
                  ),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String confidence,
    required Color confidenceColor,
    required String description,
    required double scale,
    bool showFix = true,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: PantherColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PantherColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                width: 40 * scale,
                height: 40 * scale,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(icon, color: iconColor, size: 20 * scale),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15 * scale,
                  ),
                ),
              ),
              Text(
                confidence,
                style: TextStyles.bodyMedium.copyWith(
                  color: confidenceColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            description,
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 13 * scale,
            ),
          ),
          if (showFix) ...[
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Expanded(
                  child: _buildPillButton(
                    label: 'View',
                    color: const Color(0xFF20C55D),
                    scale: scale,
                    icon: Icons.remove_red_eye_outlined,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: _buildPillButton(
                    label: 'Fix',
                    color: const Color(0xFFB366FF),
                    scale: scale,
                    icon: Icons.bolt,
                  ),
                ),
                SizedBox(width: 8 * scale),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * scale,
                      vertical: 8 * scale,
                    ),
                    decoration: const BoxDecoration(
                      color: PantherColors.cardAlt,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          color: PantherColors.textSecondary,
                          size: 14 * scale,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          'Ignore',
                          style: TextStyles.bodySmall.copyWith(
                            color: PantherColors.textSecondary,
                            fontSize: 13 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required Color color,
    required double scale,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16 * scale, color: color),
          SizedBox(width: 6 * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
