import 'package:chronos_bank/features/blockhub/presentation/pages/nft/nft_marketplace_page.dart';
import 'package:chronos_bank/features/blockhub/presentation/pages/portfolio/blockhub_portfolio_page.dart';
import 'package:chronos_bank/features/blockhub/presentation/pages/wallets/wallets_funds_page.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';
import '../pages/markets_page.dart';
import '../pages/trade_page.dart';

class MoreOptionsModal {
  static void show(BuildContext context) {
    // Get the position of the More button to position the dropdown
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(
        double.infinity,
        180,
        20,
        0,
      ), // Position from top-right
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      elevation: 8,
      items: [
        _buildMenuItem(
          context,
          icon: Icons.show_chart,
          label: 'Markets',
          onTap: () {
            // Navigate after menu closes automatically
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const MarketsPage()),
              );
            });
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.trending_up,
          label: 'Trade',
          onTap: () {
            // Navigate after menu closes automatically
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => const TradePage()),
              );
            });
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.pie_chart_outline,
          label: 'Portfolio',
          onTap: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => const BlockHubPortfolioPage(),
                ),
              );
            });
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Wallets',
          onTap: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => const WalletsFundsPage(),
                ),
              );
            });
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.hexagon_outlined,
          label: 'NFTs',
          onTap: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NftMarketplacePage(),
                ),
              );
            });
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.auto_awesome_outlined,
          label: 'AI Hub',
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          icon: Icons.credit_card_outlined,
          label: 'Card & Pay',
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          icon: Icons.support_agent_outlined,
          label: 'Support',
          onTap: () {},
        ),
        _buildMenuItem(
          context,
          icon: Icons.shield_outlined,
          label: 'Security',
          onTap: () {},
        ),
      ],
    );
  }

  static PopupMenuItem _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      height: 48,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
