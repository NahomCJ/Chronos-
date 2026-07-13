import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../../../../core/theme/panther_colors.dart';
import '../../../../../core/router/route_constants.dart';

class RebalanceSuccessPage extends StatelessWidget {
  const RebalanceSuccessPage({super.key});

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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildSuccessHeader(),
                        const SizedBox(height: 32),
                        _buildTransactionCard(),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
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

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: PantherColors.positive.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: PantherColors.positive, width: 1.5),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: PantherColors.positive,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Portfolio Rebalanced!',
          textAlign: TextAlign.center,
          style: TextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Your portfolio has been successfully rebalanced to match your target allocation',
            textAlign: TextAlign.center,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard() {
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
          Text(
            'Transaction Details',
            style: TextStyles.titleMedium.copyWith(
              color: PantherColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          _buildDetailRow('BTC Sold', '\$9,456'),
          _buildDivider(),
          _buildDetailRow('Allocated to ETH', '\$4,728'),
          _buildDivider(),
          _buildDetailRow('Allocated to USDC', '\$4,728'),
          _buildDivider(),
          _buildDetailRow('Total Fees', '\$12.50'),
          const SizedBox(height: 16),
          _buildRiskReductionCard(),
          const SizedBox(height: 14),
          _buildAIMonitoringCard(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
              color: PantherColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: PantherColors.border,
      height: 1,
      thickness: 0.5,
    );
  }

  Widget _buildRiskReductionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: PantherColors.cardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PantherColors.border),
      ),
      child: Column(
        children: [
          Text(
            'Risk Reduction',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '45 → 38',
            textAlign: TextAlign.center,
            style: TextStyles.titleLarge.copyWith(
              color: PantherColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '-15.6%',
            textAlign: TextAlign.center,
            style: TextStyles.bodyMedium.copyWith(
              color: PantherColors.positive,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMonitoringCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PantherColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PantherColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: PantherColors.warning,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Monitoring Active',
                  style: TextStyles.bodyMedium.copyWith(
                    color: PantherColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Panther will continue monitoring this action and notify you of any important changes',
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

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            Icons.remove_red_eye_outlined,
            'Details',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _buildQuickActionButton(Icons.share_outlined, 'Share')),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionButton(Icons.download_outlined, 'Export'),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PantherColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: PantherColors.brand, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: PantherColors.textSecondary,
              fontSize: 12,
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
            onPressed: () => context.go(RouteConstants.home.toPath),
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
              'Back to Home',
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
                borderRadius: BorderRadius.circular(50),
                side: const BorderSide(color: PantherColors.border),
              ),
            ),
            child: Text(
              'View Portfolio',
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
