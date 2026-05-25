import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

class CryptoTransferPage extends StatefulWidget {
  const CryptoTransferPage({super.key});

  @override
  State<CryptoTransferPage> createState() => _CryptoTransferPageState();
}

class _CryptoTransferPageState extends State<CryptoTransferPage> {
  String _fromWallet = 'Main Wallet';
  String _toWallet = 'Trading Wallet';
  final _amountController = TextEditingController();
  final _wallets = [
    'Main Wallet',
    'Trading Wallet',
    'Savings Wallet',
    'ETH Wallet',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _swapWallets() {
    setState(() {
      final tmp = _fromWallet;
      _fromWallet = _toWallet;
      _toWallet = tmp;
    });
  }

  void _setPercent(double pct) {
    setState(() {
      _amountController.text = (5000 * pct).toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildFromToSection(),
                        const SizedBox(height: 16),
                        _buildAmountCard(),
                        const SizedBox(height: 12),
                        _buildFeeRow(),
                        const SizedBox(height: 16),
                        _buildTransferButton(),
                        const SizedBox(height: 22),
                        _buildRecentTransfers(),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          Text(
            'Transfer',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFromToSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            _buildWalletDropdown('From', _fromWallet, (val) {
              if (val != null) setState(() => _fromWallet = val);
            }),
            const SizedBox(height: 8),
            _buildWalletDropdown('To', _toWallet, (val) {
              if (val != null) setState(() => _toWallet = val);
            }),
          ],
        ),
        // Swap button
        GestureDetector(
          onTap: _swapWallets,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF7C3AED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A0F2E),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20,
              ),
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
              items:
                  _wallets
                      .map(
                        (w) => DropdownMenuItem(
                          value: w,
                          child: Text(
                            w,
                            style: TextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyles.titleMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 22,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'USD',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _pctBtn('25%', () => _setPercent(0.25))),
              const SizedBox(width: 8),
              Expanded(child: _pctBtn('50%', () => _setPercent(0.50))),
              const SizedBox(width: 8),
              Expanded(child: _pctBtn('75%', () => _setPercent(0.75))),
              const SizedBox(width: 8),
              Expanded(child: _pctBtn('MAX', () => _setPercent(1.0))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pctBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFeeRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transfer Fee',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
              Text(
                'Free',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Processing Time',
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Instant',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: Text(
          'Transfer',
          style: TextStyles.labelLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransfers() {
    final transfers = [
      _Transfer('Main Wallet', 'Trading Wallet', '\$5,000', '2h ago'),
      _Transfer('Trading Wallet', 'Savings Wallet', '\$10,000', '1d ago'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transfers',
          style: TextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children:
                transfers.asMap().entries.map((e) {
                  final isLast = e.key == transfers.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF7C3AED,
                                ).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Color(0xFFAB7FF8),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${e.value.from} → ${e.value.to}',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    e.value.time,
                                    style: TextStyles.bodySmall.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              e.value.amount,
                              style: TextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          color: Colors.white.withValues(alpha: 0.06),
                          height: 1,
                          thickness: 0.5,
                          indent: 14,
                          endIndent: 14,
                        ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Transfer {
  final String from, to, amount, time;
  const _Transfer(this.from, this.to, this.amount, this.time);
}
