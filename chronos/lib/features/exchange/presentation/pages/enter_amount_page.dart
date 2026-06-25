import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';

class EnterAmountPage extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;
  final String fromCurrencyName;
  final String toCurrencyName;
  final String fromFlag;
  final String toFlag;

  const EnterAmountPage({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromCurrencyName,
    required this.toCurrencyName,
    required this.fromFlag,
    required this.toFlag,
  });

  @override
  State<EnterAmountPage> createState() => _EnterAmountPageState();
}

class _EnterAmountPageState extends State<EnterAmountPage> {
  String _amount = '0';
  bool _isRateLocked = false;
  final double _exchangeRate = 0.9234;
  // ignore: unused_field
  final double _fee = 0.00;
  // ignore: unused_field
  final double _balance = 2100.75;

  String get _convertedAmount {
    final amount = double.tryParse(_amount) ?? 0.0;
    final converted = amount * _exchangeRate;
    if (converted == 0.0) return '0';
    return converted.toStringAsFixed(4).replaceAll(RegExp(r'\.?0*$'), '');
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_amount == '0') {
        _amount = number;
      } else {
        _amount += number;
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (!_amount.contains('.')) {
        _amount += '.';
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A))),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100, // Account for bottom navigation
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Enter Amount',
                              style: TextStyles.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 20 : 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Currency Cards
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            // You Send Card
                            _buildCurrencyCard(
                              label: 'You Send',
                              flag: widget.fromFlag,
                              currency: widget.fromCurrency,
                              amount: _amount,
                              balance:
                                  'Balance: \${_balance.toStringAsFixed(2)}',
                              isInput: true,
                              isSmallScreen: isSmallScreen,
                            ),

                            SizedBox(height: isSmallScreen ? 12 : 16),

                            // You Receive Card
                            _buildCurrencyCard(
                              label: 'You Receive',
                              flag: widget.toFlag,
                              currency: widget.toCurrency,
                              amount: _convertedAmount,
                              isInput: false,
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 24),

                      // Exchange Rate and Fee
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Rate: 1 ${widget.fromCurrency} = $_exchangeRate ${widget.toCurrency}',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ),
                            Text(
                              'Fee: \${_fee.toStringAsFixed(2)}',
                              style: TextStyles.bodyMedium.copyWith(
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Rate Lock Toggle
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Expanded(
                              child: Text(
                                'Lock rate for 60 seconds',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: isSmallScreen ? 0.8 : 1.0,
                              child: Switch(
                                value: _isRateLocked,
                                onChanged: (value) {
                                  setState(() {
                                    _isRateLocked = value;
                                  });
                                },
                                activeColor: const Color(0xFFB0B0B0),
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.white.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Flexible spacer to push number pad down
                      const Spacer(),

                      // Number Pad
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            // Row 1: 1, 2, 3
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNumberButton('1', isSmallScreen),
                                _buildNumberButton('2', isSmallScreen),
                                _buildNumberButton('3', isSmallScreen),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            // Row 2: 4, 5, 6
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNumberButton('4', isSmallScreen),
                                _buildNumberButton('5', isSmallScreen),
                                _buildNumberButton('6', isSmallScreen),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            // Row 3: 7, 8, 9
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildNumberButton('7', isSmallScreen),
                                _buildNumberButton('8', isSmallScreen),
                                _buildNumberButton('9', isSmallScreen),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            // Row 4: ., 0, delete
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSpecialButton(
                                  '.',
                                  _onDecimalPressed,
                                  isSmallScreen: isSmallScreen,
                                ),
                                _buildNumberButton('0', isSmallScreen),
                                _buildSpecialButton(
                                  '⌫',
                                  _onDeletePressed,
                                  isDelete: true,
                                  isSmallScreen: isSmallScreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 24 : 32),

                      // Review Button
                      Container(
                        margin: EdgeInsets.all(horizontalPadding),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _amount != '0' && _amount.isNotEmpty
                                  ? () {
                                    context.push(
                                      RouteConstants.reviewExchange.toPath,
                                      extra: {
                                        'fromCurrency': widget.fromCurrency,
                                        'toCurrency': widget.toCurrency,
                                        'fromCurrencyName':
                                            widget.fromCurrencyName,
                                        'toCurrencyName': widget.toCurrencyName,
                                        'fromFlag': widget.fromFlag,
                                        'toFlag': widget.toFlag,
                                        'amount': _amount,
                                        'isRateLocked': _isRateLocked,
                                      },
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB0B0B0),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 14 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          child: Text(
                            'Review Exchange',
                            style: TextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 15 : 16,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard({
    required String label,
    required String flag,
    required String currency,
    required String amount,
    String? balance,
    required bool isInput,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 5 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              ),
              const Spacer(),
              if (balance != null)
                Text(
                  balance,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isSmallScreen ? 10 : 11,
                  ),
                ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            children: [
              // Flag
              Container(
                width: isSmallScreen ? 28 : 32,
                height: isSmallScreen ? 20 : 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    flag,
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                currency,
                style: TextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
              const Spacer(),
              Text(
                amount,
                style: TextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 28 : 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number, bool isSmallScreen) {
    final buttonSize = isSmallScreen ? 70.0 : 80.0;

    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialButton(
    String symbol,
    VoidCallback onTap, {
    bool isDelete = false,
    required bool isSmallScreen,
  }) {
    final buttonSize = isSmallScreen ? 70.0 : 80.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isDelete
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color:
                isDelete
                    ? Colors.red.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child:
              isDelete
                  ? Icon(
                    Icons.backspace_outlined,
                    color: Colors.red,
                    size: isSmallScreen ? 20 : 24,
                  )
                  : Text(
                    symbol,
                    style: TextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: isSmallScreen ? 20 : 24,
                    ),
                  ),
        ),
      ),
    );
  }
}
