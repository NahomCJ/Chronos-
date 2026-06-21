import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const _kBg = Color(0xFF0A0A14);
  static const _kCard = Color(0xFF1A1A2E);
  static const _kTeal = Color(0xFF14B8A6);

  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  bool get _has8Chars => _newCtrl.text.length >= 8;
  bool get _hasUppercase => _newCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _newCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _newCtrl.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  int get _strengthScore =>
      [_has8Chars, _hasUppercase, _hasNumber, _hasSpecial]
          .where((b) => b)
          .length;

  Color _strengthColor(int index) {
    final score = _strengthScore;
    if (index >= score) return Colors.white.withValues(alpha: 0.12);
    if (score <= 1) return Colors.red;
    if (score <= 2) return Colors.orange;
    if (score <= 3) return Colors.yellow;
    return _kTeal;
  }

  String get _strengthLabel {
    switch (_strengthScore) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      default:
        return 'Strong';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Feature coming soon',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/background.png', fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.45))),
            SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordCard(),
                      const SizedBox(height: 20),
                      _buildStrengthSection(),
                      const SizedBox(height: 20),
                      _buildRequirementsCard(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _kCard,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Change Password',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _passwordField(
            label: 'Current Password',
            controller: _currentCtrl,
            show: _showCurrent,
            onToggle: () => setState(() => _showCurrent = !_showCurrent),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter current password' : null,
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          _passwordField(
            label: 'New Password',
            controller: _newCtrl,
            show: _showNew,
            onToggle: () => setState(() => _showNew = !_showNew),
            onChanged: (_) => setState(() {}),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter new password';
              if (v.length < 8) return 'At least 8 characters required';
              return null;
            },
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          _passwordField(
            label: 'Confirm New Password',
            controller: _confirmCtrl,
            show: _showConfirm,
            onToggle: () => setState(() => _showConfirm = !_showConfirm),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your password';
              if (v != _newCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: !show,
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthSection() {
    if (_newCtrl.text.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'PASSWORD STRENGTH',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: _strengthColor(i),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _strengthLabel,
                style: TextStyle(
                  color: _strengthColor(_strengthScore - 1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'REQUIREMENTS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              _req('At least 8 characters', _has8Chars),
              _req('One uppercase letter', _hasUppercase),
              _req('One number', _hasNumber),
              _req('One special character', _hasSpecial),
            ],
          ),
        ),
      ],
    );
  }

  Widget _req(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: met ? _kTeal : Colors.white.withValues(alpha: 0.25),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: met
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : _submit,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF0A0A14)),
                  )
                : const Text(
                    'Update Password',
                    style: TextStyle(
                      color: Color(0xFF0A0A14),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
