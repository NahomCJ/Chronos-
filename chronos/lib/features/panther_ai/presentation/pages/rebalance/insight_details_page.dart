import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/theme/panther_colors.dart';
import '../../../../../core/router/route_constants.dart';

class InsightDetailsPage extends StatelessWidget {
  const InsightDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantherColors.bg,
      body: SafeArea(
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
                    _buildTopCard(),
                    const SizedBox(height: 20),
                    _buildKeyMetrics(),
                    const SizedBox(height: 20),
                    _buildAIAnalysis(),
                    const SizedBox(height: 20),
                    _buildConfidenceScore(),
                    const SizedBox(height: 28),
                    _buildActionButtons(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: PantherColors.textPrimary, size: 22),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insight Details',
                style: TextStyles.titleMedium.copyWith(
                  color: PantherColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                '87% confidence',
                style: TextStyles.bodySmall.copyWith(
                  color: PantherColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PantherColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PantherColors.warning,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Medium Risk',
                  style: TextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Portfolio rebalance recommended',
            style: TextStyles.titleMedium.copyWith(
              color: PantherColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your BTC exposure is 22% above optimal allocation based on your risk profile and market conditions.',
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: TextStyles.titleMedium.copyWith(
            color: PantherColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        _buildMetricRow(
          'Current BTC allocation',
          '42%',
          PantherColors.warning,
        ),
        _buildMetricRow('Target BTC allocation', '20%', PantherColors.textPrimary),
        _buildMetricRow(
          'Recommended action',
          'Reduce by 22%',
          PantherColors.textPrimary,
          valueBold: true,
        ),
        _buildMetricRow(
          'Estimated impact',
          '+\$2,340',
          PantherColors.positive,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    Color valueColor, {
    bool valueBold = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PantherColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: valueColor,
              fontSize: 14,
              fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: PantherColors.brand,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'AI Analysis',
              style: TextStyles.titleMedium.copyWith(
                color: PantherColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PantherColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              _buildAnalysisPoint(
                'BTC has outperformed other assets by 28% this quarter',
              ),
              const SizedBox(height: 14),
              _buildAnalysisPoint(
                'Your risk profile suggests 20% crypto allocation',
              ),
              const SizedBox(height: 14),
              _buildAnalysisPoint(
                'Market volatility increased 15% in the last week',
              ),
              const SizedBox(height: 14),
              _buildAnalysisPoint(
                'Rebalancing would reduce portfolio risk by 12%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: PantherColors.brand.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: PantherColors.brand, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.textPrimary,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceScore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence Score',
              style: TextStyles.titleMedium.copyWith(
                color: PantherColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              '87%',
              style: TextStyles.titleMedium.copyWith(
                color: PantherColors.positive,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.87,
            minHeight: 7,
            backgroundColor: PantherColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(PantherColors.positive),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Based on 83 data points and historical patterns',
          style: TextStyles.bodySmall.copyWith(
            color: PantherColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.push(RouteConstants.rebalanceConfirmation.toPath);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PantherColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Rebalance automatically',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: PantherColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: PantherColors.border),
              ),
            ),
            child: Text(
              'View rebalance strategy',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: PantherColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => context.pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'Dismiss insight',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: PantherColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
