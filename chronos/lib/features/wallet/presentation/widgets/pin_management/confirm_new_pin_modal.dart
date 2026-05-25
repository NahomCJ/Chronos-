import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'pin_success_modal.dart';

class ConfirmNewPinModal extends StatefulWidget {
  final String originalPin;

  const ConfirmNewPinModal({super.key, required this.originalPin});

  static void show(BuildContext context, String originalPin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ConfirmNewPinModal(originalPin: originalPin),
    );
  }

  @override
  State<ConfirmNewPinModal> createState() => _ConfirmNewPinModalState();
}

class _ConfirmNewPinModalState extends State<ConfirmNewPinModal> {
  final List<String> _pin = ['', '', '', ''];
  bool _showPin = false;
  int _currentIndex = 0;
  bool _hasError = false;

  // Hidden keyboard controller & focus node
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyboardChanged(String value) {
    if (value.length > 4) return;

    setState(() {
      _currentIndex = value.length;
      for (int i = 0; i < 4; i++) {
        _pin[i] = i < value.length ? value[i] : '';
      }
      _hasError = false;
    });

    if (value.length == 4) {
      Future.delayed(const Duration(milliseconds: 300), () {
        final enteredPin = value;
        if (enteredPin == widget.originalPin) {
          Navigator.of(context).pop();
          PinSuccessModal.show(context);
        } else {
          setState(() {
            _hasError = true;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            setState(() {
              _pin.fillRange(0, 4, '');
              _currentIndex = 0;
              _controller.clear();
              _hasError = false;
            });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          minHeight: MediaQuery.of(context).size.height * 0.48,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF302B48), Color(0xFF6D64A5)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(
                    'Set Card PIN',
                    style: TextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Card Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '****',
                      style: TextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chronos Platinum',
                          style: TextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '****4849',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title & subtitle
              Text(
                'Confirm New PIN',
                style: TextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _hasError
                    ? 'PINs do not match. Please try again.'
                    : 'Re-enter your 4-digit PIN to confirm',
                style: TextStyles.bodyMedium.copyWith(
                  color:
                      _hasError
                          ? Colors.red
                          : Colors.white.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 20),

              // PIN boxes - Make them tappable
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(_focusNode);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _hasError
                                    ? Colors.red
                                    : _currentIndex == index
                                    ? const Color(0xFF5DAA9A)
                                    : Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _showPin
                                ? _pin[index]
                                : (_pin[index].isEmpty ? '' : '•'),
                            style: TextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Show PIN toggle
              GestureDetector(
                onTap: () => setState(() => _showPin = !_showPin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showPin ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Show PIN',
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Hidden input field - positioned at the bottom
              SizedBox(
                height: 1,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  onChanged: _onKeyboardChanged,
                  style: const TextStyle(color: Colors.transparent),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Add extra space when keyboard is visible
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
