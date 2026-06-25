import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../pages/wallet_analytics_page.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ───────── Header ─────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Features',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyles.bodyMedium.copyWith(
                  color: const Color(0xFFB8860B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildFeatureItem(
          icon: Icons.bar_chart_rounded,
          title: 'Spending Analytics',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletAnalyticsPage()),
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.swap_horiz,
          title: 'Exchange Currency',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.account_balance_outlined,
          title: 'Fund Wallet',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.send_outlined,
          title: 'Withdraw Funds',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.account_balance,
          title: 'Unit Banking',
          onTap: () => context.go(RouteConstants.unitBanking.toPath),
        ),
      ],
    );
  }

  /// ───────── Feature Item ─────────
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            /// Circular Leading Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            /// Title
            Expanded(
              child: Text(
                title,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            /// Chevron
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
