import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';

class _Coin {
  final String symbol;
  final String name;
  final double price;
  final String logoUrl;
  final Color color;
  const _Coin(this.symbol, this.name, this.price, this.logoUrl, this.color);
}

const _kCoins = [
  _Coin('BTC', 'Bitcoin', 64250.0, 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png', Color(0xFFF7931A)),
  _Coin('ETH', 'Ethereum', 3512.0, 'https://assets.coingecko.com/coins/images/279/large/ethereum.png', Color(0xFF627EEA)),
  _Coin('SOL', 'Solana', 178.5, 'https://assets.coingecko.com/coins/images/4128/large/solana.png', Color(0xFF9945FF)),
  _Coin('BNB', 'BNB', 608.0, 'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png', Color(0xFFF3BA2F)),
  _Coin('ADA', 'Cardano', 0.62, 'https://assets.coingecko.com/coins/images/975/large/cardano.png', Color(0xFF0033AD)),
  _Coin('MATIC', 'Polygon', 1.05, 'https://assets.coingecko.com/coins/images/4713/large/matic-token-icon.png', Color(0xFF8247E5)),
];

class TradePage extends StatefulWidget {
  const TradePage({super.key});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  int _fromIndex = 0;
  int _toIndex = 1;
  final _fromController = TextEditingController(text: '1');
  int _slippage = 1; // 0.5, 1, 2 indices

  static const _slippageOptions = ['0.5%', '1%', '2%'];

  _Coin get _from => _kCoins[_fromIndex];
  _Coin get _to => _kCoins[_toIndex];

  double get _fromAmount => double.tryParse(_fromController.text) ?? 0;
  double get _toAmount => _fromAmount * (_from.price / _to.price);
  double get _rate => _from.price / _to.price;
  double get _fee => _fromAmount * _from.price * 0.003;

  @override
  void dispose() {
    _fromController.dispose();
    super.dispose();
  }

  void _flipCoins() {
    setState(() {
      final tmp = _fromIndex;
      _fromIndex = _toIndex;
      _toIndex = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.65))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      children: [
                        // From card
                        _buildSwapCard(
                          label: 'You Pay',
                          coinIndex: _fromIndex,
                          isFrom: true,
                          amount: _fromController.text,
                          usd: _fromAmount * _from.price,
                        ),
                        // Flip button
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: GestureDetector(
                              onTap: _flipCoins,
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
                                ),
                                child: const Icon(Icons.swap_vert, color: Color(0xFF8B5CF6), size: 22),
                              ),
                            ),
                          ),
                        ),
                        // To card
                        _buildSwapCard(
                          label: 'You Receive',
                          coinIndex: _toIndex,
                          isFrom: false,
                          amount: _toAmount.toStringAsFixed(6),
                          usd: _toAmount * _to.price,
                        ),
                        const SizedBox(height: 20),
                        // Rate info
                        _buildRateCard(),
                        const SizedBox(height: 16),
                        // Slippage
                        _buildSlippage(),
                        const SizedBox(height: 28),
                        // Swap button
                        _buildSwapButton(),
                        const SizedBox(height: 80),
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
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          Text('Swap', style: TextStyles.titleLarge.copyWith(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20,
          )),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune, color: Colors.white.withValues(alpha: 0.7), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapCard({
    required String label,
    required int coinIndex,
    required bool isFrom,
    required String amount,
    required double usd,
  }) {
    final coin = _kCoins[coinIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              // Coin selector
              GestureDetector(
                onTap: () => _showCoinPicker(context, isFrom),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: coin.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: coin.color.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: coin.logoUrl, width: 24, height: 24, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(color: coin.color, shape: BoxShape.circle),
                            child: Center(child: Text(coin.symbol[0], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(coin.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.6), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isFrom
                    ? TextField(
                        controller: _fromController,
                        textAlign: TextAlign.right,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 24),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      )
                    : Text(
                        _toAmount > 0 ? _toAmount.toStringAsFixed(6) : '0',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 20, fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '≈ \$${usd.toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
          ),
          if (isFrom) ...[
            const SizedBox(height: 12),
            Row(
              children: ['25%', '50%', '75%', 'MAX'].asMap().entries.map((e) {
                final pcts = [0.25, 0.5, 0.75, 1.0];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      const balances = [0.062256, 1.24, 8.5, 0.8, 500.0, 1200.0];
                      final bal = balances[_fromIndex];
                      _fromController.text = (bal * pcts[e.key]).toStringAsFixed(6);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(e.value, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _rateRow('Rate', '1 ${_from.symbol} = ${_rate.toStringAsFixed(4)} ${_to.symbol}'),
          const SizedBox(height: 8),
          _rateRow('Network Fee', '~\$${_fee.toStringAsFixed(2)} (0.3%)'),
          const SizedBox(height: 8),
          _rateRow('Route', '${_from.symbol} → ${_to.symbol}'),
          const SizedBox(height: 8),
          _rateRow('Est. Time', '~15 seconds'),
        ],
      ),
    );
  }

  Widget _rateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSlippage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Max Slippage', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        const SizedBox(height: 10),
        Row(
          children: _slippageOptions.asMap().entries.map((e) {
            final sel = _slippage == e.key;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _slippage = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF8B5CF6).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Text(e.value, style: TextStyle(
                    color: sel ? const Color(0xFF8B5CF6) : Colors.white.withValues(alpha: 0.6),
                    fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                  )),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwapButton() {
    final hasAmount = _fromAmount > 0;
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: hasAmount
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Swapping ${_fromController.text} ${_from.symbol} → ${_to.symbol}'),
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                );
              }
            : null,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: hasAmount
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: hasAmount ? null : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_horiz, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                hasAmount ? 'Swap ${_from.symbol} → ${_to.symbol}' : 'Enter an amount',
                style: TextStyle(
                  color: hasAmount ? Colors.white : Colors.white.withValues(alpha: 0.4),
                  fontSize: 16, fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoinPicker(BuildContext context, bool isFrom) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Select Token', style: TextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ..._kCoins.asMap().entries.map((e) {
              final c = e.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: c.logoUrl, width: 40, height: 40, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(width: 40, height: 40, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
                  ),
                ),
                title: Text(c.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                subtitle: Text(c.name, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                trailing: Text('\$${c.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                onTap: () {
                  setState(() {
                    if (isFrom) {
                      _fromIndex = e.key;
                      if (_toIndex == e.key) _toIndex = e.key == 0 ? 1 : 0;
                    } else {
                      _toIndex = e.key;
                      if (_fromIndex == e.key) _fromIndex = e.key == 0 ? 1 : 0;
                    }
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
