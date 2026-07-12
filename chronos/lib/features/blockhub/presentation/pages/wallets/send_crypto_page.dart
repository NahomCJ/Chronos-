import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

const _k3dAssets = {
  'BTC':  'assets/crypto/btc.png',
  'ETH':  'assets/crypto/eth.png',
  'BNB':  'assets/Blockhub/extracted/bnb.png',
  'SOL':  'assets/crypto/sol.png',
  'XRP':  'assets/crypto/xrp.png',
  'ADA':  'assets/crypto/ada.png',
  'DOT':  'assets/crypto/dot.png',
  'MATIC':'assets/crypto/matic.png',
  'LINK': 'assets/crypto/link.png',
  'AVAX': 'assets/crypto/avax.png',
  'LTC':  'assets/crypto/ltc.png',
  'USDT': 'assets/crypto/usdt.png',
};

class _Coin {
  final String symbol;
  final String name;
  final double balance;
  final double price;
  final Color color;
  const _Coin(this.symbol, this.name, this.balance, this.price, this.color);
}

const _kCoins = [
  _Coin('ETH', 'Ethereum', 2.45, 3512.0, Color(0xFF627EEA)),
  _Coin('BTC', 'Bitcoin', 0.062, 64250.0, Color(0xFFF7931A)),
  _Coin('SOL', 'Solana', 8.5, 178.5, Color(0xFF9945FF)),
  _Coin('BNB', 'BNB', 0.8, 608.0, Color(0xFFF3BA2F)),
  _Coin('MATIC', 'Polygon', 1200.0, 1.05, Color(0xFF8247E5)),
];

class SendCryptoPage extends StatefulWidget {
  const SendCryptoPage({super.key});

  @override
  State<SendCryptoPage> createState() => _SendCryptoPageState();
}

class _SendCryptoPageState extends State<SendCryptoPage> {
  int _coinIndex = 0;
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  _Coin get _coin => _kCoins[_coinIndex];

  static const _contacts = [
    ('Alice', '0x742d...3'),
    ('Bob', '0x123e...7'),
    ('Charlie', '0x987f...2'),
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _setPct(double pct) {
    _amountController.text = (_coin.balance * pct).toStringAsFixed(6);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.58))),
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
                        _coinSelector(),
                        const SizedBox(height: 14),
                        _balanceCard(),
                        const SizedBox(height: 14),
                        _recipientCard(),
                        const SizedBox(height: 14),
                        _recentContacts(),
                        const SizedBox(height: 14),
                        _amountCard(),
                        const SizedBox(height: 14),
                        _memoCard(),
                        const SizedBox(height: 14),
                        _feeRow(),
                        const SizedBox(height: 16),
                        _sendButton(),
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
          Text('Send ${_coin.symbol}', style: TextStyles.titleMedium.copyWith(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20,
          )),
        ],
      ),
    );
  }

  Widget _coinSelector() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kCoins.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = _kCoins[i];
          final sel = i == _coinIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _coinIndex = i;
              _amountController.clear();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? c.color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? c.color.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: _k3dAssets.containsKey(c.symbol)
                        ? Image.asset(_k3dAssets[c.symbol]!, width: 22, height: 22, fit: BoxFit.cover)
                        : Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                            child: Center(child: Text(c.symbol[0], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Text(c.symbol, style: TextStyle(
                    color: sel ? Colors.white : Colors.white.withValues(alpha: 0.55),
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          ClipOval(
            child: _k3dAssets.containsKey(_coin.symbol)
                ? Image.asset(_k3dAssets[_coin.symbol]!, width: 40, height: 40, fit: BoxFit.cover)
                : Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _coin.color, shape: BoxShape.circle),
                    child: Center(child: Text(_coin.symbol[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                  ),
          ),
          const SizedBox(height: 8),
          Text('Available Balance', style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.5), fontSize: 12,
          )),
          const SizedBox(height: 4),
          Text('${_coin.balance.toStringAsFixed(6)} ${_coin.symbol}',
              style: TextStyles.titleLarge.copyWith(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          Text('\$${(_coin.balance * _coin.price).toStringAsFixed(2)}',
              style: TextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _recipientCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('Recipient Address', style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 12,
            )),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addressController,
                  style: TextStyles.bodyMedium.copyWith(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '0x... or ENS name',
                    hintStyle: TextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_scanner, color: Color(0xFFAB7FF8), size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentContacts() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.5), size: 16),
            const SizedBox(width: 6),
            Text('Recent Contacts', style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 12,
            )),
          ]),
          const SizedBox(height: 12),
          Row(
            children: _contacts.map((c) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => setState(() => _addressController.text = c.$2),
                child: Column(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _coin.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, color: _coin.color, size: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(c.$1, style: TextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    Text(c.$2, style: TextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amount', style: TextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyles.titleMedium.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyles.titleMedium.copyWith(color: Colors.white.withValues(alpha: 0.25), fontSize: 20),
                    border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(_coin.symbol, style: TextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 14, fontWeight: FontWeight.w600,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _pctBtn('25%', () => _setPct(0.25))),
              const SizedBox(width: 8),
              Expanded(child: _pctBtn('50%', () => _setPct(0.50))),
              const SizedBox(width: 8),
              Expanded(child: _pctBtn('75%', () => _setPct(0.75))),
              const SizedBox(width: 8),
              Expanded(child: _pctBtn('MAX', () => _setPct(1.0))),
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
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _memoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('Memo (Optional)', style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.5), fontSize: 12,
            )),
          ),
          TextField(
            controller: _memoController,
            style: TextStyles.bodyMedium.copyWith(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add a note...',
              hintStyle: TextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              Text('Network Fee', style: TextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.55), fontSize: 13)),
              Text('0.0015 ${_coin.symbol} (\$${(0.0015 * _coin.price).toStringAsFixed(2)})',
                  style: TextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Processing Time', style: TextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.55), fontSize: 13)),
              Row(children: [
                Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.5), size: 14),
                const SizedBox(width: 4),
                Text('~2-5 min', style: TextStyles.bodySmall.copyWith(color: Colors.white, fontSize: 13)),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sendButton() {
    final hasInput = _amountController.text.isNotEmpty && _addressController.text.isNotEmpty;
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: hasInput
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sending ${_amountController.text} ${_coin.symbol}...'),
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                )
            : null,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: hasInput
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                  )
                : null,
            color: hasInput ? null : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                hasInput ? 'Send ${_coin.symbol}' : 'Enter address & amount',
                style: TextStyle(
                  color: hasInput ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  fontSize: 15, fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
