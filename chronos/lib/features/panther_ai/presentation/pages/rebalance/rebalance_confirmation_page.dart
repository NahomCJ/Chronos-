import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/theme/panther_colors.dart';
import '../../../../../core/router/route_constants.dart';

class RebalanceConfirmationPage extends StatelessWidget {
  const RebalanceConfirmationPage({super.key});

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
                        _buildActionCard(),
                        const SizedBox(height: 22),
                        _buildWhatWillHappen(),
                        const SizedBox(height: 22),
                        _buildImpactSummary(),
                        const SizedBox(height: 16),
                        _buildImportantNotice(),
                        const SizedBox(height: 16),
                        _buildAIRecommendation(),
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
                'Confirm Action',
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                'Review before proceeding',
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

  Widget _buildActionCard() {
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PantherColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.trending_up,
              color: PantherColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Auto-Rebalance Portfolio',
            style: TextStyles.titleMedium.copyWith(
              color: PantherColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Panther AI will automatically adjust your portfolio to match your target allocation',
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatWillHappen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What will happen',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
              _buildStepItem('1', 'Sell 22% of BTC holdings (\$9,456)'),
              const SizedBox(height: 14),
              _buildStepItem(
                '2',
                'Distribute proceeds across ETH and stablecoins',
              ),
              const SizedBox(height: 14),
              _buildStepItem('3', 'Maintain 20% target crypto allocation'),
              const SizedBox(height: 14),
              _buildStepItem('4', 'Execute at optimal market prices'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: PantherColors.brand.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyles.bodySmall.copyWith(
                color: PantherColors.brand,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: TextStyles.bodyMedium.copyWith(
                color: PantherColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impact Summary',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              _buildImpactRow(
                'Risk Impact',
                'Risk Score: 45 → 38',
                PantherColors.positive,
              ),

              _buildImpactRow('Fees', 'Estimated fees: \$12.50', PantherColors.textPrimary),

              _buildImpactRow(
                'Time',
                'Execution time: ~2 minutes',
                PantherColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildImpactRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PantherColors.warning.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: PantherColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: PantherColors.warning.withValues(alpha: 0.5),
              ),
            ),
            child: const Center(
              child: Text(
                '!',
                style: TextStyle(
                  color: PantherColors.warning,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Notice',
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This action will execute market orders. Review carefully before confirming.',
                  style: TextStyles.bodySmall.copyWith(
                    color: PantherColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PantherColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: PantherColors.brand,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'AI Recommendation Strength',
                style: TextStyles.bodyMedium.copyWith(
                  color: PantherColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '95%',
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.positive,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.push(RouteConstants.rebalanceSuccess.toPath);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PantherColors.brand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
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
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: PantherColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: const BorderSide(color: PantherColors.border),
              ),
            ),
            child: Text(
              'Go back',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: PantherColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
