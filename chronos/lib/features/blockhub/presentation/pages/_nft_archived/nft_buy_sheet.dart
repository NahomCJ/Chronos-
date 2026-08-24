import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

class NftBuySheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NftBuySheetContent(),
    );
  }
}

class _NftBuySheetContent extends StatefulWidget {
  const _NftBuySheetContent();

  @override
  State<_NftBuySheetContent> createState() => _NftBuySheetContentState();
}

class _NftBuySheetContentState extends State<_NftBuySheetContent> {
  int _step = 1;
  String _selectedWallet = 'MetaMask';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_step > 1) {
                      setState(() => _step--);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buy NFT',
                      style: TextStyles.titleMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Step $_step of 3',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                _step == 1
                    ? _buildStep1()
                    : _step == 2
                    ? _buildStep2()
                    : _buildStep3(),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Price Breakdown ───────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNftSummaryCard(),
        const SizedBox(height: 20),
        _buildPriceBreakdown(),
        const SizedBox(height: 16),
        _buildGasWarning(),
        const SizedBox(height: 20),
        _buildContinueButton(() => setState(() => _step = 2), false),
      ],
    );
  }

  // ── Step 2: Select Wallet ─────────────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNftSummaryCard(),
        const SizedBox(height: 20),
        _buildWalletSelection(),
        const SizedBox(height: 20),
        _buildContinueButton(
          () => setState(() => _step = 3),
          _selectedWallet != 'MetaMask',
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _buildNftSummaryCard(),
        const SizedBox(height: 32),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF22C55E), width: 2),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF22C55E),
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Purchase Successful!',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your NFT has been added to your portfolio',
          textAlign: TextAlign.center,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.grey[500],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Text(
              'View in Portfolio',
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              'Continue Browsing',
              style: TextStyles.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNftSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/btc.png',
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => const Icon(
                      Icons.image_outlined,
                      color: Colors.white54,
                      size: 28,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Holographic Futures',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Holographic #9012',
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '3.5 ETH',
                style: TextStyles.bodySmall.copyWith(
                  color: const Color(0xFF00D4FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Breakdown',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 14),
        _priceRow('Item Price', '3.5 ETH'),
        _divider(),
        _priceRow('Creator Royalty (10%)', '0.3500 ETH'),
        _divider(),
        _priceRow('Network Gas Fee', '0.015 ETH'),
        _divider(),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '3.8650 ETH',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '\$9276.00',
                  style: TextStyles.bodySmall.copyWith(
                    color: const Color(0xFF00D4FF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: Colors.grey[200], height: 1, thickness: 0.5);

  Widget _buildGasWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF0B100).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF0B100),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gas fees are currently elevated. Consider waiting for lower network activity.',
              style: TextStyles.bodySmall.copyWith(
                color: Colors.grey[700],
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSelection() {
    final wallets = [
      _Wallet('MetaMask', '5.2 ETH', true),
      _Wallet('Coinbase Wallet', '3.8 ETH', false),
      _Wallet('WalletConnect', '1.5 ETH', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Select Wallet',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                wallets.asMap().entries.map((e) {
                  final isLast = e.key == wallets.length - 1;
                  return _buildWalletRow(e.value, isLast);
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletRow(_Wallet wallet, bool isLast) {
    final isSelected = _selectedWallet == wallet.name;
    final hasSufficientBalance = wallet.hasSufficientBalance;

    return Column(
      children: [
        GestureDetector(
          onTap:
              hasSufficientBalance
                  ? () => setState(() => _selectedWallet = wallet.name)
                  : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Balance: ${wallet.balance}',
                        style: TextStyles.bodySmall.copyWith(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      if (!hasSufficientBalance) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Insufficient balance',
                          style: TextStyles.bodySmall.copyWith(
                            color: const Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC8F4A).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFDC8F4A).withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFFDC8F4A),
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.grey[100],
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildContinueButton(VoidCallback onTap, bool disabled) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey[300] : Colors.grey[350],
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: TextStyles.labelLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: disabled ? Colors.black38 : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _Wallet {
  final String name, balance;
  final bool hasSufficientBalance;
  const _Wallet(this.name, this.balance, this.hasSufficientBalance);
}
