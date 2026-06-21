import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'sell_btc_order_type_page.dart';

class _Coin {
  final String symbol;
  final String name;
  final double price;
  final double balance;
  final String logoUrl;
  final Color color;
  const _Coin(this.symbol, this.name, this.price, this.balance, this.logoUrl, this.color);
}

const _kCoins = [
  _Coin('BTC', 'Bitcoin', 64250.0, 0.062256, 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png', Color(0xFFF7931A)),
  _Coin('ETH', 'Ethereum', 3512.0, 1.24, 'https://assets.coingecko.com/coins/images/279/large/ethereum.png', Color(0xFF627EEA)),
  _Coin('SOL', 'Solana', 178.5, 8.5, 'https://assets.coingecko.com/coins/images/4128/large/solana.png', Color(0xFF9945FF)),
  _Coin('BNB', 'BNB', 608.0, 0.8, 'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png', Color(0xFFF3BA2F)),
  _Coin('ADA', 'Cardano', 0.62, 500.0, 'https://assets.coingecko.com/coins/images/975/large/cardano.png', Color(0xFF0033AD)),
];

class SellBtcPage extends StatefulWidget {
  const SellBtcPage({super.key});

  @override
  State<SellBtcPage> createState() => _SellBtcPageState();
}

class _SellBtcPageState extends State<SellBtcPage> {
  int _coinIndex = 0;
  double _sliderValue = 0.25;
  final TextEditingController _amountController = TextEditingController();

  _Coin get _coin => _kCoins[_coinIndex];
  double get _selectedAmount => _coin.balance * _sliderValue;
  double get _usdAmount => _selectedAmount * _coin.price;
  double get _fee => _usdAmount * 0.01;

  @override
  void initState() {
    super.initState();
    _amountController.text = (_kCoins[0].balance * 0.25).toStringAsFixed(6);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(double pct) {
    setState(() {
      _sliderValue = pct;
      _amountController.text = (_coin.balance * pct).toStringAsFixed(6);
    });
  }

  void _onCoinChanged(int i) {
    setState(() {
      _coinIndex = i;
      _sliderValue = 0.25;
      _amountController.text = (_kCoins[i].balance * 0.25).toStringAsFixed(6);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
          Positioned.fill(child: Stack(fit: StackFit.expand, children: [CachedNetworkImage(imageUrl: 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, placeholder: (_, __) => Container(color: const Color(0xFF0A1628)), errorWidget: (_, __, ___) => Container(color: const Color(0xFF0A1628))), Container(color: Colors.black.withValues(alpha: 0.58))])),
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
                            'Sell ${_coin.symbol}',
                            style: TextStyles.titleLarge.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 18 : 20,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 24),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                              onTap: () => _onCoinChanged(i),
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
                                      child: CachedNetworkImage(
                                        imageUrl: c.logoUrl, width: 22, height: 22, fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => Container(
                                          width: 22, height: 22,
                                          decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                                          child: Center(child: Text(c.symbol[0], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(c.symbol, style: TextStyle(
                                      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                      fontSize: 13,
                                    )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [_dot(true), _line(false), _dot(false), _line(false), _dot(false)]),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text('${_coin.symbol} Amount',
                            style: TextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: isSmallScreen ? 14 : 16)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  style: TextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0.015564',
                                    hintStyle: const TextStyle(color: Colors.white54),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final a = double.tryParse(v) ?? 0;
                                    setState(() => _sliderValue = (a / _coin.balance).clamp(0.0, 1.0));
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_coin.symbol, style: TextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('You\'ll receive',
                            style: TextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: isSmallScreen ? 14 : 16)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text('\$${_usdAmount.toStringAsFixed(2)}',
                              style: TextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
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
                                _amountController.text = (_coin.balance * v).toStringAsFixed(6);
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
                          children: [_pctBtn('25%', 0.25), _pctBtn('50%', 0.50), _pctBtn('75%', 0.75), _pctBtn('100%', 1.0)],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.info_outline, color: Color(0xFF8B5CF6), size: 20),
                                const SizedBox(width: 8),
                                Text('Fee: \$${_fee.toStringAsFixed(2)} (1%)',
                                    style: TextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                              ]),
                              const SizedBox(height: 8),
                              Text('Price: \$${_coin.price.toStringAsFixed(2)} / ${_coin.symbol}',
                                  style: TextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 4),
                              Text('Balance: ${_coin.balance.toStringAsFixed(6)} ${_coin.symbol}',
                                  style: TextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8))),
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
                          builder: (_) => SellBtcOrderTypePage(
                            btcAmount: _selectedAmount,
                            usdAmount: _usdAmount,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Continue', style: TextStyles.titleMedium.copyWith(color: Colors.black, fontWeight: FontWeight.w600)),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF8B5CF6).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(label, style: TextStyles.bodyMedium.copyWith(
          color: sel ? const Color(0xFF8B5CF6) : Colors.white,
          fontWeight: FontWeight.w600,
        )),
      ),
    );
  }
}
