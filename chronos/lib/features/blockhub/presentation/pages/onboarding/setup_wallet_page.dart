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

  static const _bg = Color(0xFFF7F8FA);
  static const _titleColor = Color(0xFF1A1A2E);
  static const _subtitleColor = Color(0xFF6B7080);
  static const _border = Color(0xFFEEEEEE);

  static const _networks = [
    _Network('ethereum', 'Ethereum', Color(0xFF627EEA),
        Icons.currency_exchange_rounded, 'Largest DeFi ecosystem'),
    _Network('polygon', 'Polygon', Color(0xFF8247E5), Icons.hexagon_rounded,
        'Low fees, fast'),
    _Network('arbitrum', 'Arbitrum', Color(0xFF12AAFF), Icons.bolt_rounded,
        'Layer 2 scaling'),
    _Network('base', 'Base', Color(0xFF0052FF), Icons.layers_rounded,
        'Coinbase\'s L2'),
  ];

  static const _walletTypes = [
    _WalletType('create', Icons.add_circle_outline_rounded, 'Create New Wallet',
        'Fresh wallet with a seed phrase you control', Color(0xFF22C55E)),
    _WalletType('import', Icons.download_rounded, 'Import Existing Wallet',
        'Connect using your seed phrase or private key', Color(0xFF3B82F6)),
    _WalletType('connect', Icons.link_rounded, 'Connect External Wallet',
        'Link MetaMask, Trust Wallet or WalletConnect', Color(0xFFF59E0B)),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 18),
                    _sectionLabel('Select Network'),
                    const SizedBox(height: 10),
                    _buildNetworkGrid(),
                    const SizedBox(height: 18),
                    _sectionLabel('Wallet Setup'),
                    const SizedBox(height: 10),
                    ..._walletTypes.map(_buildWalletOption),
                    const SizedBox(height: 14),
                    _buildSecurityNote(),
                    const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _border, width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _titleColor, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Setup Wallet',
                    style: TextStyle(
                        color: _titleColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const Text('Step 3 of 3',
                    style: TextStyle(color: _subtitleColor, fontSize: 11)),
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
                  color: i == 2 ? _titleColor : const Color(0xFFDADEE6),
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
                color: _titleColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.1)),
        const SizedBox(height: 8),
        const Text(
          'Choose a network and how you\'d like to manage your wallet.',
          style: TextStyle(color: _subtitleColor, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            color: _subtitleColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8));
  }

  Widget _buildNetworkGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: _networks.map(_buildNetworkTile).toList(),
    );
  }

  Widget _buildNetworkTile(_Network n) {
    final isSelected = _selectedNetwork == n.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedNetwork = n.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? n.color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? n.color.withValues(alpha: 0.5) : _border,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: n.color.withValues(alpha: 0.12)),
              child: Icon(n.icon, color: n.color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(n.name,
                      style: const TextStyle(
                          color: _titleColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                  Text(n.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _subtitleColor, fontSize: 9.5)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(shape: BoxShape.circle, color: n.color),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 10),
              ),
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? w.color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? w.color.withValues(alpha: 0.4) : _border,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: w.color.withValues(alpha: 0.12),
              ),
              child: Icon(w.icon, color: w.color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.title,
                      style: const TextStyle(
                          color: _titleColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(w.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _subtitleColor, fontSize: 10.5)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? w.color : Colors.transparent,
                border: Border.all(
                    color: isSelected ? w.color : const Color(0xFFD5D8DE),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF22C55E).withValues(alpha: 0.18), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              color: Color(0xFF22C55E), size: 15),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your keys, your crypto. Chronos never stores your seed phrase.',
              style: TextStyle(color: _subtitleColor, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: GestureDetector(
        onTap: _canProceed ? _proceed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _canProceed ? _titleColor : const Color(0xFFE9EBEF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('Connect Wallet',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _canProceed ? Colors.white : _subtitleColor,
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
  final Color color;
  final IconData icon;
  final String tagline;
  const _Network(this.id, this.name, this.color, this.icon, this.tagline);
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
