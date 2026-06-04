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

  void _showWalletConnectedModal() => WalletConnectedModal.show(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ── Dark header ──────────────────────────────────────────────
          Container(
            color: const Color(0xFF0D0A1E),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ChooseExperiencePage())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      ),
                    ),
                    Expanded(
                      child: Text('BlockHub',
                          textAlign: TextAlign.center,
                          style: TextStyles.titleLarge.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(width: 34),
                  ],
                ),
              ),
            ),
          ),

          // ── White scrollable body ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text('Set Up Wallet',
                      style: TextStyles.headlineMedium.copyWith(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.bold,
                          fontSize: 24)),
                  const SizedBox(height: 6),
                  Text('Choose how to manage your assets',
                      style: TextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF888888), fontSize: 14)),
                  const SizedBox(height: 24),

                  _buildWalletOption(
                    icon: Icons.add,
                    title: 'Create BlockHub Wallet',
                    subtitle: 'Secure, non-custodial wallet managed by BlockHub',
                    isPrimary: true,
                    onTap: _showWalletConnectedModal,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Or connect external',
                        style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13)),
                  ),
                  const SizedBox(height: 20),
                  _buildWalletOption(
                    icon: Icons.account_balance_wallet,
                    title: 'Connect MetaMask',
                    subtitle: '',
                    isPrimary: false,
                    onTap: _showWalletConnectedModal,
                  ),
                  const SizedBox(height: 10),
                  _buildWalletOption(
                    icon: Icons.link,
                    title: 'Connect WalletConnect',
                    subtitle: '',
                    isPrimary: false,
                    onTap: _showWalletConnectedModal,
                  ),
                  const SizedBox(height: 10),
                  _buildWalletOption(
                    icon: Icons.account_balance,
                    title: 'Connect Coinbase Wallet',
                    subtitle: '',
                    isPrimary: false,
                    onTap: _showWalletConnectedModal,
                  ),
                  const SizedBox(height: 24),

                  Text('Preferred Network',
                      style: TextStyles.titleMedium.copyWith(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _networks.map((network) {
                      final isSelected = _selectedNetwork == network;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedNetwork = network),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0D0A1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0D0A1E)
                                  : const Color(0xFFDDDDDD),
                            ),
                          ),
                          child: Text(network,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF444444),
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Security note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFDC8F4A).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: Color(0xFFDC8F4A), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              'Your keys, your crypto. We never store your private keys.',
                              style: TextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF555555),
                                  fontSize: 12,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom buttons ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A1A),
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 18),
                        SizedBox(width: 8),
                        Text('Exit BlockHub',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedNetwork != null
                        ? _showWalletConnectedModal
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D0A1E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFDDDDDD),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Continue',
                        style: TextStyle(
                          color: _selectedNetwork != null
                              ? Colors.white
                              : const Color(0xFF999999),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        )),
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
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                : const Color(0xFFEEEEEE),
            width: isPrimary ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFF59E0B), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyles.bodySmall.copyWith(
                            color: const Color(0xFF888888), fontSize: 12)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.open_in_new,
                color: Color(0xFFCCCCCC), size: 18),
          ],
        ),
      ),
    );
  }
}
