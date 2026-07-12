import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'buy_btc_order_type_page.dart';

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
  final double price;
  final Color color;
  const _Coin(this.symbol, this.name, this.price, this.color);
}

const _kCoins = [
  _Coin('BTC', 'Bitcoin', 64250.0, Color(0xFFF7931A)),
  _Coin('ETH', 'Ethereum', 3512.0, Color(0xFF627EEA)),
  _Coin('SOL', 'Solana', 178.5, Color(0xFF9945FF)),
  _Coin('BNB', 'BNB', 608.0, Color(0xFFF3BA2F)),
  _Coin('ADA', 'Cardano', 0.62, Color(0xFF0033AD)),
];

// Light fill for input/text boxes — a clean white card with dark text,
// readable regardless of what's behind the (now-ungradiented) background photo.
const _kFieldGradient = LinearGradient(
  colors: [Color(0xFFFFFFFF), Color(0xFFF3F3F8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kFieldBorder = Color(0x14000000);
const _kFieldTextPrimary = Color(0xFF12122A);
const _kFieldTextSecondary = Color(0xFF6B6B7A);

class BuyBtcPage extends StatefulWidget {
  const BuyBtcPage({super.key});

  @override
  State<BuyBtcPage> createState() => _BuyBtcPageState();
}

class _BuyBtcPageState extends State<BuyBtcPage> {
  int _coinIndex = 0;
  double _selectedAmount = 1000.0;
  double _sliderValue = 0.25;
  final double _maxAmount = 48750.25;
  final TextEditingController _amountController = TextEditingController();

  _Coin get _coin => _kCoins[_coinIndex];
  double get _coinAmount => _selectedAmount / _coin.price;
  double get _fee => _selectedAmount * 0.01;

  @override
  void initState() {
    super.initState();
    _amountController.text = '1000';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(double percentage) {
    setState(() {
      _sliderValue = percentage;
      _selectedAmount = _maxAmount * percentage;
      _amountController.text = _selectedAmount.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          ),
                          const Spacer(),
                          Text(
                            'Buy ${_coin.symbol}',
                            style: TextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 18 : 20,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 24),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Coin selector
                      SizedBox(
                        height: 56,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _kCoins.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final c = _kCoins[i];
                            final selected = i == _coinIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _coinIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? c.color.withValues(alpha: 0.25)
                                      : Colors.white.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected ? c.color.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.12),
                                  ),
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
                                    Text(
                                      c.symbol,
                                      style: TextStyle(
                                        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _dot(true),
                          _line(false),
                          _dot(false),
                          _line(false),
                          _dot(false),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // 3D coin display
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: _k3dAssets.containsKey(_coin.symbol)
                                ? SizedBox(
                                    key: ValueKey(_coin.symbol),
                                    width: 100, height: 100,
                                    child: Transform(
                                      alignment: const Alignment(0, -0.15),
                                      transform: Matrix4.identity()..scale(1.6, 1.2),
                                      child: Image.asset(
                                        _k3dAssets[_coin.symbol]!,
                                        fit: BoxFit.contain,
                                        width: 100, height: 100,
                                      ),
                                    ),
                                  )
                                : Container(
                                    key: ValueKey(_coin.symbol),
                                    width: 80, height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _coin.color.withValues(alpha: 0.15),
                                      border: Border.all(color: _coin.color.withValues(alpha: 0.4), width: 1.5),
                                    ),
                                    child: ClipOval(
                                      child: _k3dAssets.containsKey(_coin.symbol)
                                          ? Image.asset(_k3dAssets[_coin.symbol]!, fit: BoxFit.cover)
                                          : Center(child: Text(_coin.symbol[0], style: TextStyle(color: _coin.color, fontSize: 28, fontWeight: FontWeight.bold))),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Amount (USD)',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _kFieldGradient,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _kFieldBorder),
                          ),
                          child: Row(
                            children: [
                              Text('\$', style: TextStyles.bodyMedium.copyWith(color: _kFieldTextPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  style: TextStyles.bodyMedium.copyWith(color: _kFieldTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '1000',
                                    hintStyle: TextStyle(color: _kFieldTextSecondary),
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final a = double.tryParse(v) ?? 0;
                                    setState(() {
                                      _selectedAmount = a;
                                      _sliderValue = a / _maxAmount;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You\'ll receive',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _kFieldGradient,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _kFieldBorder),
                          ),
                          child: Row(
                            children: [
                              ClipOval(
                                child: _k3dAssets.containsKey(_coin.symbol)
                                    ? Image.asset(_k3dAssets[_coin.symbol]!, width: 24, height: 24, fit: BoxFit.cover)
                                    : Container(width: 24, height: 24, decoration: BoxDecoration(color: _coin.color, shape: BoxShape.circle)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_coinAmount.toStringAsFixed(6)} ${_coin.symbol}',
                                style: TextStyles.bodyMedium.copyWith(color: _kFieldTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Select amount', style: TextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                            Text('${(_sliderValue * 100).toInt()}%', style: TextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF8B5CF6),
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                          ),
                          child: Slider(
                            value: _sliderValue.clamp(0.0, 1.0),
                            onChanged: (v) {
                              setState(() {
                                _sliderValue = v;
                                _selectedAmount = _maxAmount * v;
                                _amountController.text = _selectedAmount.toStringAsFixed(0);
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0%', style: TextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.5))),
                            Text('100%', style: TextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.5))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _pctBtn('25%', 0.25),
                            _pctBtn('50%', 0.50),
                            _pctBtn('75%', 0.75),
                            _pctBtn('100%', 1.0),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: _kFieldGradient,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Color(0xFF8B5CF6), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Fee: \$${_fee.toStringAsFixed(2)} (1%)',
                                    style: TextStyles.bodySmall.copyWith(color: _kFieldTextPrimary, fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Price: \$${_coin.price.toStringAsFixed(2)} / ${_coin.symbol}',
                                  style: TextStyles.bodySmall.copyWith(color: _kFieldTextSecondary, fontSize: 12)),
                              const SizedBox(height: 3),
                              Text('Available: \$${_maxAmount.toStringAsFixed(2)}',
                                  style: TextStyles.bodySmall.copyWith(color: _kFieldTextSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyBtcOrderTypePage(
                            amount: _selectedAmount,
                            btcAmount: _coinAmount,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Continue', style: TextStyles.bodyMedium.copyWith(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
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

  Widget _dot(bool active) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.3),
    ),
  );

  Widget _line(bool active) => Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    ),
  );

  Widget _pctBtn(String label, double value) {
    final sel = (_sliderValue - value).abs() < 0.01;
    return GestureDetector(
      onTap: () => _updateAmount(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF8B5CF6).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(label, style: TextStyles.bodySmall.copyWith(color: sel ? const Color(0xFF8B5CF6) : Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
}
