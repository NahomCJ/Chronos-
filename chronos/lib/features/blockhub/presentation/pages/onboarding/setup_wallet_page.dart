import 'package:flutter/material.dart';
import '../../widgets/wallet_connected_modal.dart';

class SetupWalletPage extends StatefulWidget {
  const SetupWalletPage({super.key});

  @override
  State<SetupWalletPage> createState() => _SetupWalletPageState();
}

class _SetupWalletPageState extends State<SetupWalletPage> {
  String? _selectedNetwork;
  String? _selectedWalletType;

  static const _bg = Color(0xFF06060E);
  static const _card = Color(0xFF0F0F1C);
  static const _amber = Color(0xFFF59E0B);

  static const _networks = [
    _Network('ethereum', 'Ethereum', 'ETH', Color(0xFF627EEA),
        Icons.currency_exchange_rounded, 'Largest DeFi ecosystem'),
    _Network('polygon', 'Polygon', 'MATIC', Color(0xFF8247E5),
        Icons.hexagon_rounded, 'Low fees, fast transactions'),
    _Network('arbitrum', 'Arbitrum', 'ARB', Color(0xFF12AAFF),
        Icons.bolt_rounded, 'Ethereum Layer 2 scaling'),
    _Network('base', 'Base', 'BASE', Color(0xFF0052FF),
        Icons.layers_rounded, 'Coinbase\'s L2 network'),
  ];

  static const _walletTypes = [
    _WalletType('create', Icons.add_circle_outline_rounded, 'Create New Wallet',
        'Generate a fresh wallet with a seed phrase you control',
        Color(0xFF22C55E)),
    _WalletType('import', Icons.download_rounded, 'Import Existing Wallet',
        'Connect using your seed phrase or private key',
        Color(0xFF3B82F6)),
    _WalletType('connect', Icons.link_rounded, 'Connect External Wallet',
        'Link MetaMask, Trust Wallet or WalletConnect',
        Color(0xFFF59E0B)),
  ];

  void _proceed() {
    if (_selectedNetwork == null || _selectedWalletType == null) return;
    WalletConnectedModal.show(context);
  }

  bool get _canProceed =>
      _selectedNetwork != null && _selectedWalletType != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 28),
                    _sectionLabel('Select Network'),
                    const SizedBox(height: 12),
                    _buildNetworkGrid(),
                    const SizedBox(height: 28),
                    _sectionLabel('Wallet Setup'),
                    const SizedBox(height: 12),
                    ..._walletTypes.map((w) => _buildWalletOption(w)),
                    const SizedBox(height: 24),
                    _buildSecurityNote(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Setup Wallet',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Step 3 of 3',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11)),
              ],
            ),
          ),
          Row(
            children: List.generate(
              3,
              (i) => Container(
                margin: const EdgeInsets.only(left: 5),
                width: i == 2 ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == 2
                      ? _amber
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Set up your\nwallet.',
            style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'Choose the blockchain network and how you\'d like to manage your wallet.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.5),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8));
  }

  Widget _buildNetworkGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: _networks.map((n) => _buildNetworkTile(n)).toList(),
    );
  }

  Widget _buildNetworkTile(_Network n) {
    final isSelected = _selectedNetwork == n.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedNetwork = n.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? n.color.withValues(alpha: 0.1) : _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? n.color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.07),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(n.icon, color: n.color, size: 18),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: n.color),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 10),
                  ),
              ],
            ),
            const Spacer(),
            Text(n.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text(n.tagline,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 9,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletOption(_WalletType w) {
    final isSelected = _selectedWalletType == w.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedWalletType = w.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? w.color.withValues(alpha: 0.08) : _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? w.color.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.07),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: w.color.withValues(alpha: 0.12),
              ),
              child: Icon(w.icon, color: w.color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(w.subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                          height: 1.3)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? w.color : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                    color: isSelected
                        ? w.color
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1.5),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 11)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF22C55E).withValues(alpha: 0.15), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              color: Color(0xFF22C55E), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your keys, your crypto. Chronos never stores your seed phrase or private keys.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: GestureDetector(
        onTap: _canProceed ? _proceed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _canProceed ? _amber : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _canProceed
                ? [
                    BoxShadow(
                        color: _amber.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Text('Connect Wallet',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _canProceed
                      ? Colors.black
                      : Colors.white.withValues(alpha: 0.3),
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _Network {
  final String id;
  final String name;
  final String symbol;
  final Color color;
  final IconData icon;
  final String tagline;
  const _Network(
      this.id, this.name, this.symbol, this.color, this.icon, this.tagline);
}

class _WalletType {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _WalletType(
      this.id, this.icon, this.title, this.subtitle, this.color);
}
