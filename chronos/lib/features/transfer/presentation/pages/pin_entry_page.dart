import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/preset_colors.dart';
import '../../../../core/utils/error_toast.dart';
import '../../../../core/router/route_constants.dart';

class PinEntryPage extends StatefulWidget {
  const PinEntryPage({super.key});

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  String _pin = "";
  final String _correctPin = "1234"; // Hardcoded for app logic simulation

  void _onKeyPress(String value) {
    if (_pin.length < 4) {
      setState(() => _pin += value);
      if (_pin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _validatePin() {
    if (_pin == _correctPin) {
      ErrorToast.show(context, "PIN Verified", backgroundColor: Colors.green);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.go(RouteConstants.transferSuccess.toPath);
      });
    } else {
      ErrorToast.show(context, "Incorrect PIN. Please try again.");
      setState(() => _pin = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isShortScreen = size.height < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: isSmallScreen ? 24 : 28,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Enter App PIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Enter your 4-digit security PIN to confirm',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 30 : 40),
                _buildPinDots(isSmallScreen),
                const Spacer(),
                _buildNumericKeypad(isSmallScreen, isShortScreen),
                SizedBox(height: isShortScreen ? 20 : 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinDots(bool isSmallScreen) {
    final dotSize = isSmallScreen ? 14.0 : 16.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? CColor.primaryButton : Colors.transparent,
            border: Border.all(color: Colors.white38, width: 2),
          ),
        );
      }),
    );
  }

  Widget _buildNumericKeypad(bool isSmallScreen, bool isShortScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 40),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3'], isSmallScreen, isShortScreen),
          _buildKeypadRow(['4', '5', '6'], isSmallScreen, isShortScreen),
          _buildKeypadRow(['7', '8', '9'], isSmallScreen, isShortScreen),
          _buildKeypadRow(['', '0', 'backspace'], isSmallScreen, isShortScreen),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(
    List<String> keys,
    bool isSmallScreen,
    bool isShortScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isShortScreen ? 4 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            keys.map((key) {
              if (key == 'backspace') {
                return IconButton(
                  onPressed: _onBackspace,
                  icon: Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: isSmallScreen ? 24 : 28,
                  ),
                );
              }
              if (key == '') return SizedBox(width: isSmallScreen ? 40 : 48);

              final buttonSize = isSmallScreen ? 60.0 : 70.0;

              return InkWell(
                onTap: () => _onKeyPress(key),
                borderRadius: BorderRadius.circular(buttonSize),
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
