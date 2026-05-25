import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';

class AddMoneyPage extends StatelessWidget {
  const AddMoneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset('assets/background.png', fit: BoxFit.cover),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: isSmallScreen ? 5 : 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: isSmallScreen ? 24 : 28,
                            ),
                          ),
                        ),
                        Text(
                          'Add Money',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Choose a method to top up your account',
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 40),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildMethodTile(
                          icon: Icons.corporate_fare_outlined,
                          title: 'Bank Transfer',
                          subtitle: 'Transfer from your bank account',
                          isSmallScreen: isSmallScreen,
                          onTap:
                              () => context.push(
                                RouteConstants.bankTransfer.toPath,
                              ),
                        ),
                        _buildMethodTile(
                          icon: Icons.credit_card_outlined,
                          title: 'Debit/Credit Card',
                          subtitle: 'Instant top-up with a card',
                          isSmallScreen: isSmallScreen,
                          onTap: () {},
                        ),
                        _buildMethodTile(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'From Another Wallet',
                          subtitle: 'Transfer from your other wallet',
                          isSmallScreen: isSmallScreen,
                          onTap: () {},
                        ),
                        _buildMethodTile(
                          icon: Icons.location_on_outlined,
                          title: 'Cash Deposit',
                          subtitle: 'Top up using nearby agents',
                          isSmallScreen: isSmallScreen,
                          onTap: () {},
                          isComingSoon: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isSmallScreen,
    bool isComingSoon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 16 : 20,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            color: const Color(0xFF1B2431).withOpacity(0.4),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFCD853F),
                size: isSmallScreen ? 24 : 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isComingSoon)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCD853F).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFCD853F).withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Soon',
                              style: TextStyle(
                                color: const Color(0xFFCD853F),
                                fontSize: isSmallScreen ? 8 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
