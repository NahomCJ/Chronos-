import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';

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
          icon: Icons.account_balance_wallet_outlined,
          title: 'Crypto balance (live price)',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.swap_horiz,
          title: 'Convert Crypto to Cash',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.add_chart,
          title: 'Buy Crypto',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.trending_down,
          title: 'Sell Crypto',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.network_check,
          title: 'View Network Fees',
          onTap: () {},
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
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            /// Circular Leading Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
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
              color: Colors.white.withOpacity(0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
