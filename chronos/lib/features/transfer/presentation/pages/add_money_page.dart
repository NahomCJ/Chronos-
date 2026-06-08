import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';

// ---------------------------------------------------------------------------
// Constants — unified dark-glass design language
// ---------------------------------------------------------------------------
const _kBg = Color(0xFF0A0A14);
const _kCard = Color(0xFF1A1A2E);
const _kSheetBg = Color(0xFF0F0F1E);
const _kBorderSubtle = Color(0x1AFFFFFF); // white 10%
const _kBorderUnselected = Color(0x4DFFFFFF); // white 30%

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------
class _BankOption {
  const _BankOption(this.name, this.location, this.asset);
  final String name;
  final String location;
  final String asset; // asset path — may not exist, fallback icon used
}

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
        if (_amount == '0') {
          _amount = key;
        } else {
          final dotIndex = _amount.indexOf('.');
          if (dotIndex != -1 && _amount.length - dotIndex > 2) return;
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
          Navigator.pop(context);
          if (method == 'Bank Transfer') {
            // Show bank picker after method sheet closes
            Future.microtask(() => _showBankPickerSheet());
          } else {
            setState(() => _selectedMethod = method);
          }
        },
      ),
    );
  }

  void _showBankPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BankPickerSheet(
        onSelect: (bankName) {
          Navigator.pop(context);
          setState(() => _selectedMethod = bankName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connecting to $bankName...'),
              backgroundColor: _kCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
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
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 0,
        onItemSelected: (i) {
          switch (i) {
            case 0: context.go(RouteConstants.home.toPath);
            case 1: context.go(RouteConstants.pantherAi.toPath);
            case 2: context.go(RouteConstants.blockHub.toPath);
          }
        },
      ),
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
          // White/light underline bar — no purple gradient
          Container(
            height: 1,
            width: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: isZero ? 0.15 : 0.55),
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
                color: _kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _kBorderSubtle,
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _kBorderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
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

  // ── Continue button — white pill ──────────────────────────────────────────

  Widget _buildContinueButton() {
    final enabled = _parsedAmount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: enabled ? _showConfirmSheet : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            'Continue',
            style: TextStyle(
              color: enabled
                  ? const Color(0xFF0A0A14)
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
    _MethodOption(icon: Icons.account_balance_rounded, label: 'Bank Transfer'),
    _MethodOption(icon: Icons.credit_card_rounded, label: 'Debit Card'),
    _MethodOption(icon: Icons.apple_rounded, label: 'Apple Pay'),
    _MethodOption(icon: Icons.g_mobiledata_rounded, label: 'Google Pay'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
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
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.45)
                : _kBorderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: isSelected
                  ? Colors.white
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
            // Selected: white fill circle with dark checkmark
            // Unselected: outlined circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : _kBorderUnselected,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Color(0xFF0A0A14), size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bank picker bottom sheet
// ---------------------------------------------------------------------------
class _BankPickerSheet extends StatefulWidget {
  const _BankPickerSheet({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const _sfBanks = [
    _BankOption('First Republic Bank', 'San Francisco, CA',
        'assets/banks/frb.png'),
    _BankOption(
        'Wells Fargo', 'San Francisco, CA', 'assets/banks/wf.png'),
    _BankOption(
        'Bank of America', 'San Francisco, CA', 'assets/banks/boa.png'),
    _BankOption(
        'Chase Bank', 'San Francisco, CA', 'assets/banks/chase.png'),
    _BankOption(
        'Silicon Valley Bank', 'Santa Clara, CA', 'assets/banks/svb.png'),
    _BankOption('Citibank', 'San Francisco, CA', 'assets/banks/citi.png'),
    _BankOption('US Bank', 'San Francisco, CA', 'assets/banks/usb.png'),
    _BankOption(
        'East West Bank', 'San Francisco, CA', 'assets/banks/ewb.png'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_BankOption> get _filtered => _query.isEmpty
      ? _sfBanks
      : _sfBanks
          .where((b) => b.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: _kSheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08), width: 1),
          ),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title row + Plaid badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Your Bank',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect your bank account securely via Plaid',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Green "Connect with Plaid" badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Connect with Plaid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorderSubtle, width: 1),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  cursorColor: Colors.white,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search banks…',
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.white.withValues(alpha: 0.4), size: 18),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Bank list
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final bank = _filtered[i];
                  return GestureDetector(
                    onTap: () => widget.onSelect(bank.name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorderSubtle, width: 1),
                      ),
                      child: Row(
                        children: [
                          // Bank icon — fallback since assets won't exist
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bank.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bank.location,
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.45),
                                    fontSize: 12,
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
                  );
                },
              ),
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
      decoration: BoxDecoration(
        color: _kSheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
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
          // Icon circle — white bg, dark icon (no purple gradient)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: Color(0xFF0A0A14),
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
              color: _kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorderSubtle, width: 1),
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
          // Confirm button — white pill
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Color(0xFF0A0A14),
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
