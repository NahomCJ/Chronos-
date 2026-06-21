import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/text_theme.dart';
import 'deposit_page.dart';
import 'deposit_fiat_page.dart';
import 'withdraw_page.dart';
import 'transfer_page.dart';
import 'send_crypto_page.dart';
import 'receive_crypto_page.dart';

class WalletsFundsPage extends StatelessWidget {
  const WalletsFundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
          Positioned.fill(
            child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))]),
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
                        _buildTotalBalanceCard(context),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Fiat Wallet'),
                        const SizedBox(height: 10),
                        _buildFiatWalletCard(context),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Crypto Wallets'),
                        const SizedBox(height: 10),
                        _buildCryptoWallet(
                          context,
                          icon: Icons.currency_exchange,
                          iconColor: const Color(0xFF627EEA),
                          iconBg: const Color(
                            0xFF627EEA,
                          ).withValues(alpha: 0.15),
                          name: 'Ethereum',
                          address: '0x742d...0bEb',
                          totalUsd: '\$15,240.5',
                          tokens: [
                            _Token('ETH', '3.5 ETH', '\$11,01\n75'),
                            _Token('LINK', '165 LINK', '\$2,930.4'),
                            _Token('MATIC', '356 MATIC', '\$307.52'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildCryptoWallet(
                          context,
                          icon: Icons.currency_bitcoin,
                          iconColor: const Color(0xFFF7931A),
                          iconBg: const Color(
                            0xFFF7931A,
                          ).withValues(alpha: 0.15),
                          name: 'Bitcoin',
                          address: '1AtJP1...vfNe f(',
                          totalUsd: '\$16,06\n2.5',
                          tokens: [_Token('BTC', '0.25 BTC', '2.5')],
                        ),
                        const SizedBox(height: 12),
                        _buildCryptoWallet(
                          context,
                          icon: Icons.circle,
                          iconColor: const Color(0xFF9945FF),
                          iconBg: const Color(
                            0xFF9945FF,
                          ).withValues(alpha: 0.15),
                          name: 'Solana',
                          address: '7bH0WK...7ARj',
                          totalUsd: '\$6,974.4',
                          tokens: [_Token('SOL', '48 SOL', '\$6,974.4')],
                        ),
                        const SizedBox(height: 20),
                        _buildBlockHubCards(),
                        const SizedBox(height: 20),
                        _buildRecentActivity(),
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
            'Wallets & Funds',
            style: TextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B0764), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$50,728.15',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DepositPage()),
                      ),
                  child: _actionBtn(
                    Icons.download_outlined,
                    'Deposit',
                    const Color(0xFF22C55E),
                    const Color(0xFF22C55E).withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WithdrawPage()),
                      ),
                  child: _actionBtn(
                    Icons.upload_outlined,
                    'Withdraw',
                    const Color(0xFFEF4444),
                    const Color(0xFFEF4444).withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CryptoTransferPage(),
                        ),
                      ),
                  child: _actionBtn(
                    Icons.swap_horiz,
                    'Transfer',
                    const Color(0xFF3B82F6),
                    const Color(0xFF3B82F6).withValues(alpha: 0.2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color iconColor, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyles.titleMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Widget _buildFiatWalletCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Color(0xFF22C55E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USD',
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'US Dollar',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$12,450.75',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Available: \$12,450.75',
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DepositFiatPage(),
                        ),
                      ),
                  child: _walletBtn('Add Funds', Colors.white, Colors.black),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _walletBtn(
                  'Withdraw',
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white,
                  border: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoWallet(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String name,
    required String address,
    required String totalUsd,
    required List<_Token> tokens,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          address,
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap:
                              () => Clipboard.setData(
                                ClipboardData(text: address),
                              ),
                          child: Icon(
                            Icons.copy_outlined,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    totalUsd,
                    textAlign: TextAlign.right,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'View on Explorer',
                          style: TextStyles.bodySmall.copyWith(
                            color: const Color(0xFF00D4FF),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.open_in_new,
                          color: Color(0xFF00D4FF),
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tokens.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.symbol,
                    style: TextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        t.amount,
                        style: TextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        t.usdValue,
                        style: TextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SendCryptoPage(),
                        ),
                      ),
                  child: _walletBtn(
                    'Send',
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white,
                    border: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReceiveCryptoPage(),
                        ),
                      ),
                  child: _walletBtn(
                    'Receive',
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white,
                    border: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletBtn(
    String label,
    Color bg,
    Color textColor, {
    bool border = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
        border:
            border
                ? Border.all(color: Colors.white.withValues(alpha: 0.15))
                : null,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyles.labelMedium.copyWith(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBlockHubCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('BlockHub Cards'),
            Text(
              'Manage →',
              style: TextStyles.bodySmall.copyWith(
                color: const Color(0xFF00D4FF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card_outlined,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Physical & Virtual Cards',
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Spend crypto as fiat instantly',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '3 active cards • Tap to manage limits & spending',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Recent Activity'),
            Text(
              'View All →',
              style: TextStyles.bodySmall.copyWith(
                color: const Color(0xFF00D4FF),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            'View your transaction history',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _Token {
  final String symbol, amount, usdValue;
  const _Token(this.symbol, this.amount, this.usdValue);
}
