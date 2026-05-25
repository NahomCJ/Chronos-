import 'package:chronos_bank/features/blockhub/presentation/pages/onboarding/choose_experience_page.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../widgets/wallet_connected_modal.dart';

class SetupWalletPage extends StatefulWidget {
  const SetupWalletPage({super.key});

  @override
  State<SetupWalletPage> createState() => _SetupWalletPageState();
}

class _SetupWalletPageState extends State<SetupWalletPage> {
  String? _selectedNetwork;

  final List<String> _networks = ['Ethereum', 'Polygon', 'Arbitrum', 'Base'];

  void _showWalletConnectedModal() {
    WalletConnectedModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

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
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ChooseExperiencePage(),
                              ),
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'BlockHub',
                        style: TextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 18 : 20,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        Text(
                          'Set Up Wallet',
                          style: TextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 24 : 28,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Choose how to manage your assets',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Create BlockHub Wallet (Primary)
                        _buildWalletOption(
                          icon: Icons.add,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Create BlockHub Wallet',
                          subtitle:
                              'Secure, non-custodial wallet managed by BlockHub',
                          isPrimary: true,
                          onTap: _showWalletConnectedModal,
                          isSmallScreen: isSmallScreen,
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: Text(
                            'Or connect external',
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: isSmallScreen ? 12 : 13,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // MetaMask
                        _buildWalletOption(
                          icon: Icons.account_balance_wallet,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Connect MetaMask',
                          subtitle: '',
                          isPrimary: false,
                          onTap: _showWalletConnectedModal,
                          isSmallScreen: isSmallScreen,
                        ),

                        const SizedBox(height: 16),

                        // WalletConnect
                        _buildWalletOption(
                          icon: Icons.link,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Connect WalletConnect',
                          subtitle: '',
                          isPrimary: false,
                          onTap: _showWalletConnectedModal,
                          isSmallScreen: isSmallScreen,
                        ),

                        const SizedBox(height: 16),

                        // Coinbase Wallet
                        _buildWalletOption(
                          icon: Icons.account_balance,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Connect Coinbase Wallet',
                          subtitle: '',
                          isPrimary: false,
                          onTap: _showWalletConnectedModal,
                          isSmallScreen: isSmallScreen,
                        ),

                        const SizedBox(height: 32),

                        // Preferred Network
                        Text(
                          'Preferred Network',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Network Selection
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              _networks.map((network) {
                                final isSelected = _selectedNetwork == network;
                                return GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _selectedNetwork = network,
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.white.withValues(
                                                alpha: 0.2,
                                              )
                                              : Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Colors.white.withValues(
                                                  alpha: 0.4,
                                                )
                                                : Colors.white.withValues(
                                                  alpha: 0.1,
                                                ),
                                      ),
                                    ),
                                    child: Text(
                                      network,
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        fontSize: isSmallScreen ? 13 : 14,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // Security Note
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: const Color(0xFFF59E0B),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your keys, your crypto. We never store your private keys.',
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: isSmallScreen ? 12 : 13,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Exit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
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
                            children: [
                              const Icon(Icons.close, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Exit BlockHub',
                                style: TextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              _selectedNetwork != null
                                  ? _showWalletConnectedModal
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedNetwork != null
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
                                  _selectedNetwork != null
                                      ? Colors.black
                                      : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
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

  Widget _buildWalletOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isPrimary
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: isPrimary ? 0.2 : 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 15,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: isSmallScreen ? 12 : 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: const Color(0xFFF59E0B), size: 20),
          ],
        ),
      ),
    );
  }
}
