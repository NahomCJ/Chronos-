import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const _kBg = Color(0xFF0A0A14);
const _kCard = Color(0xFF141428);
const _kAccent = Color(0xFF6C5CE7);
const _kAccentLight = Color(0xFF8B5CF6);
const _kSurface = Color(0xFF1C1C32);

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  String _amount = '0';
  String _selectedMethod = 'Debit Card';

  double get _parsedAmount => double.tryParse(_amount) ?? 0;

  // ── Numpad input ─────────────────────────────────────────────────────────

  void _onKey(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == '⌫') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0';
        }
      } else if (key == '.') {
        if (!_amount.contains('.')) {
          _amount = '$_amount.';
        }
      } else {
        // digit
        if (_amount == '0') {
          _amount = key;
        } else {
          // Guard: max 2 decimal places
          final dotIndex = _amount.indexOf('.');
          if (dotIndex != -1 && _amount.length - dotIndex > 2) return;
          // Guard: max 7 digits before decimal
          if (dotIndex == -1 && _amount.length >= 7) return;
          _amount = '$_amount$key';
        }
      }
    });
  }

  void _addQuickAmount(double value) {
    HapticFeedback.lightImpact();
    setState(() {
      final current = _parsedAmount;
      final next = current + value;
      if (next == next.truncateToDouble()) {
        _amount = next.toInt().toString();
      } else {
        _amount = next.toStringAsFixed(2);
      }
    });
  }

  // ── Display string ────────────────────────────────────────────────────────

  String get _displayAmount {
    if (_amount.endsWith('.')) return '\$$_amount';
    return '\$$_amount';
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────

  void _showMethodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MethodSheet(
        selected: _selectedMethod,
        onSelect: (method) {
          setState(() => _selectedMethod = method);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showConfirmSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        amount: _parsedAmount,
        method: _selectedMethod,
        onConfirm: () {
          Navigator.pop(context);
          context.pop();
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildAmountDisplay(),
            const SizedBox(height: 12),
            _buildQuickChips(),
            const SizedBox(height: 16),
            _buildMethodSelector(),
            const SizedBox(height: 16),
            _buildNumpad(),
            const SizedBox(height: 16),
            _buildContinueButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const Text(
            'Add Money',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Amount display ────────────────────────────────────────────────────────

  Widget _buildAmountDisplay() {
    final isZero = _parsedAmount == 0 && !_amount.contains('.');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            _displayAmount,
            style: TextStyle(
              color: isZero
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w300,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 1,
            width: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _kAccent.withValues(alpha: isZero ? 0.3 : 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick chips ───────────────────────────────────────────────────────────

  Widget _buildQuickChips() {
    const amounts = [10.0, 50.0, 100.0, 500.0];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: amounts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final v = amounts[i];
          final label = v == v.truncateToDouble()
              ? '+\$${v.toInt()}'
              : '+\$${v.toStringAsFixed(2)}';
          return GestureDetector(
            onTap: () => _addQuickAmount(v),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _kAccent.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: _kAccentLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Payment method selector ───────────────────────────────────────────────

  Widget _buildMethodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _showMethodSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  color: _kAccentLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Payment method',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _selectedMethod,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Numpad ────────────────────────────────────────────────────────────────

  Widget _buildNumpad() {
    const keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '.', '0', '⌫',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 2.4,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        children: keys
            .map((k) => _NumKey(label: k, onTap: () => _onKey(k)))
            .toList(),
      ),
    );
  }

  // ── Continue button ───────────────────────────────────────────────────────

  Widget _buildContinueButton() {
    final enabled = _parsedAmount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: enabled ? _showConfirmSheet : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [_kAccent, _kAccentLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: enabled ? null : _kSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            'Continue',
            style: TextStyle(
              color: enabled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Numpad key
// ---------------------------------------------------------------------------
class _NumKey extends StatelessWidget {
  const _NumKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '⌫';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: isBackspace
            ? Icon(
                Icons.backspace_outlined,
                color: Colors.white.withValues(alpha: 0.8),
                size: 22,
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment method bottom sheet
// ---------------------------------------------------------------------------
class _MethodSheet extends StatelessWidget {
  const _MethodSheet({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  static const _methods = [
    _MethodOption(
      icon: Icons.account_balance_rounded,
      label: 'Bank Transfer',
    ),
    _MethodOption(
      icon: Icons.credit_card_rounded,
      label: 'Debit Card',
    ),
    _MethodOption(
      icon: Icons.apple_rounded,
      label: 'Apple Pay',
    ),
    _MethodOption(
      icon: Icons.g_mobiledata_rounded,
      label: 'Google Pay',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose Payment Method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._methods.map(
            (m) => _MethodRow(
              option: m,
              isSelected: m.label == selected,
              onTap: () => onSelect(m.label),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodOption {
  const _MethodOption({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _MethodOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? _kAccent.withValues(alpha: 0.12)
              : _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _kAccent.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: isSelected
                  ? _kAccentLight
                  : Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: isSelected
                  ? _kAccentLight
                  : Colors.white.withValues(alpha: 0.25),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirmation bottom sheet
// ---------------------------------------------------------------------------
class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.amount,
    required this.method,
    required this.onConfirm,
  });

  final double amount;
  final String method;
  final VoidCallback onConfirm;

  String get _formattedAmount {
    if (amount == amount.truncateToDouble()) {
      return '\$${amount.toInt()}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_kAccent, _kAccentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kAccent.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formattedAmount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w300,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Adding to your account',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Amount', value: _formattedAmount),
                const SizedBox(height: 10),
                _SummaryRow(label: 'Via', value: method),
                const SizedBox(height: 10),
                const _SummaryRow(label: 'Fee', value: 'Free'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kAccent, _kAccentLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
