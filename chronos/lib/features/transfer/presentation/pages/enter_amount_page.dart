import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/preset_colors.dart';
import '../../../../core/utils/error_toast.dart';
import '../../../home/data/data_source/home_remote_data_source.dart';

class EnterAmountPage extends StatefulWidget {
  final String recipientName;
  final String method;

  const EnterAmountPage({
    super.key,
    this.recipientName = "Alex Johnson",
    this.method = "Chronos User",
  });

  @override
  State<EnterAmountPage> createState() => _EnterAmountPageState();
}

class _EnterAmountPageState extends State<EnterAmountPage> {
  String _amountStr = "0";
  double _availableBalance = 0.0;
  bool _isBalanceLoading = true;
  final NumberFormat _formatter = NumberFormat("#,##0.##");

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final summary = await GetIt.I<HomeRemoteDataSource>().getSummary();
      if (mounted) {
        setState(() {
          _availableBalance = summary.accountBalance;
          _isBalanceLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isBalanceLoading = false);
    }
  }

  void _onKeyPress(String value) {
    setState(() {
      if (_amountStr == "0" && value != ".") {
        _amountStr = value;
      } else {
        if (value == "." && _amountStr.contains(".")) return;
        if (_amountStr.contains(".")) {
          final parts = _amountStr.split(".");
          if (parts.length > 1 && parts[1].length >= 2) return;
        }
        _amountStr += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = "0";
      }
    });
  }

  String _formatAmount(String amount) {
    if (amount == "0") return "0";
    try {
      double val = double.parse(amount);
      if (amount.endsWith(".")) return "${_formatter.format(val)}.";
      if (amount.contains(".") && amount.split(".")[1].isEmpty) {
        return "${_formatter.format(val)}.";
      }
      return _formatter.format(val);
    } catch (e) {
      return amount;
    }
  }

  void _onContinue() {
    double amount = double.tryParse(_amountStr) ?? 0;
    if (amount <= 0) {
      ErrorToast.show(context, "Please enter a valid amount");
      return;
    }
    if (!_isBalanceLoading && amount > _availableBalance) {
      ErrorToast.show(context, "Insufficient balance");
      return;
    }

    context.push(
      RouteConstants.transferConfirmation.toPath,
      extra: {
        'amount': _amountStr,
        'recipientName': widget.recipientName,
        'method': widget.method,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = size.width / 390;
    final double textScale = math.min(scale, 1.1);
    final isShortScreen = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.15)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, scale, textScale),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                SizedBox(height: 12 * scale),
                                _buildAmountDisplay(scale, textScale),
                                SizedBox(height: 16 * scale),
                                _buildAccountSelector(scale, textScale),
                                SizedBox(height: 12 * scale),
                                _buildNoteInput(scale, textScale),
                                const Spacer(),
                                _buildNumericKeypad(
                                  scale,
                                  textScale,
                                  isShortScreen,
                                ),
                                SizedBox(height: 16 * scale),
                                _buildContinueButton(scale, textScale),
                                SizedBox(height: 16 * scale),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double scale, double textScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24 * scale,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Enter Amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 48 * scale),
            ],
          ),
          Text(
            widget.recipientName,
            style: TextStyle(color: Colors.white70, fontSize: 14 * textScale),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(double scale, double textScale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '\$${_formatAmount(_amountStr)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30 * textScale,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      'USD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12 * textScale,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 14 * scale,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isBalanceLoading
                ? 'Loading balance...'
                : 'Available: \$${_formatter.format(_availableBalance)}',
            style: TextStyle(
              color: _isBalanceLoading ? Colors.white38 : Colors.greenAccent,
              fontSize: 12 * textScale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSelector(double scale, double textScale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 32 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white24),
            ),
            alignment: Alignment.center,
            child: Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12 * textScale,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Main Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * textScale,
                  ),
                ),
                Text(
                  _isBalanceLoading
                      ? '...'
                      : '\$${_formatter.format(_availableBalance)}',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11 * textScale,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white70,
            size: 20 * scale,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput(double scale, double textScale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white, fontSize: 14 * textScale),
        decoration: InputDecoration(
          hintText: 'Add a note (optional)',
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14 * textScale),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildNumericKeypad(
    double scale,
    double textScale,
    bool isShortScreen,
  ) {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3'], scale, textScale, isShortScreen),
        _buildKeypadRow(['4', '5', '6'], scale, textScale, isShortScreen),
        _buildKeypadRow(['7', '8', '9'], scale, textScale, isShortScreen),
        _buildKeypadRow(
          ['.', '0', 'backspace'],
          scale,
          textScale,
          isShortScreen,
        ),
      ],
    );
  }

  Widget _buildKeypadRow(
    List<String> keys,
    double scale,
    double textScale,
    bool isShortScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            keys.map((key) {
              if (key == 'backspace') {
                return IconButton(
                  onPressed: _onBackspace,
                  icon: Icon(
                    Icons.backspace_outlined,
                    color: Colors.redAccent,
                    size: 24 * scale,
                  ),
                );
              }
              return InkWell(
                onTap: () => _onKeyPress(key),
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 90 * scale,
                  height: (isShortScreen ? 50 : 70) * scale,
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30 * textScale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildContinueButton(double scale, double textScale) {
    bool isEnabled = _amountStr != "0" && _amountStr != "0.";
    return SizedBox(
      width: double.infinity,
      height: 50 * scale,
      child: ElevatedButton(
        onPressed: isEnabled ? _onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? CColor.primaryButton : Colors.white.withValues(alpha: 0.1),
          foregroundColor: isEnabled ? Colors.white : Colors.white38,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16 * textScale,
          ),
        ),
      ),
    );
  }
}
