import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../lifex/data/lifex_service.dart';

const _kBg = 'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  DateTime? _selectedDate;
  int _step = 0;

  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  String _selectedCountry = 'Ethiopia';

  String? _selectedFaith;
  final _customFaithCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _customFaithCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    await showDialog(
      context: context,
      builder: (ctx) => _CalendarDialog(
        initial: _selectedDate ?? DateTime(DateTime.now().year - 25),
        onPicked: (date) {
          setState(() => _selectedDate = date);
        },
      ),
    );
  }

  void _next() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_step < 3) {
      setState(() => _step++);
    } else {
      final faith = _selectedFaith == 'Other' ? _customFaithCtrl.text.trim() : _selectedFaith;
      if (faith != null && faith.isNotEmpty && faith != 'Prefer not to say') {
        // Best-effort — the rest of this onboarding flow doesn't submit to
        // the backend yet either, so this degrades silently if it can't reach it.
        GetIt.I<LifeXService>().setFaith(faith).catchError((_) => <String, dynamic>{});
      }
      context.go(RouteConstants.home.toPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(_kBg, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A))),
          ),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _stepTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _stepSubtitle,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                          ),
                          const SizedBox(height: 22),
                          if (_step == 0) ..._buildPersonalFields(),
                          if (_step == 1) ..._buildAddressFields(),
                          if (_step == 2) ..._buildIdentityFields(),
                          if (_step == 3) ..._buildFaithFields(),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1A0A2E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(
                                _step < 3 ? 'Continue' : 'Complete Setup',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                          ),
                          if (_step < 3) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: TextButton(
                                onPressed: () => context.go(RouteConstants.home.toPath),
                                child: Text(
                                  'Skip for now',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.45),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  String get _stepTitle => switch (_step) {
        0 => 'Personal Details',
        1 => 'Your Address',
        2 => 'Verify Identity',
        _ => 'One Last Thing',
      };

  String get _stepSubtitle => switch (_step) {
        0 => 'Tell us a bit about yourself',
        1 => 'Required for regulatory compliance',
        2 => 'Upload a government-issued ID',
        _ => 'Chris wants to know you better',
      };

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_step > 0) {
                setState(() => _step--);
              } else if (context.canPop()) {
                context.pop();
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Account Setup',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            '${_step + 1} of 4',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: List.generate(4, (i) {
          final active = i <= _step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              height: 3,
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildPersonalFields() => [
        Row(
          children: [
            Expanded(
              child: _field(
                controller: _firstNameCtrl,
                hint: 'First name',
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _field(
                controller: _lastNameCtrl,
                hint: 'Last name',
                icon: Icons.person_outline,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _field(
          controller: _emailCtrl,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter your email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Invalid email';
            return null;
          },
        ),
        const SizedBox(height: 10),
        // Calendar date picker tile
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF374151), size: 17),
                const SizedBox(width: 10),
                Text(
                  _selectedDate == null
                      ? 'Date of birth'
                      : '${_selectedDate!.day.toString().padLeft(2, '0')} / ${_selectedDate!.month.toString().padLeft(2, '0')} / ${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedDate == null ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 18),
              ],
            ),
          ),
        ),
      ];

  List<Widget> _buildAddressFields() => [
        _field(
          controller: _addressCtrl,
          hint: 'Street address',
          icon: Icons.home_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _field(
                controller: _cityCtrl,
                hint: 'City',
                icon: Icons.location_city_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _field(
                controller: _zipCtrl,
                hint: 'Postal code',
                icon: Icons.markunread_mailbox_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _countryDropdown(),
      ];

  List<Widget> _buildIdentityFields() => [
        _kycCard(
          icon: Icons.badge_outlined,
          title: 'National ID / Passport',
          subtitle: 'Upload front and back of your government-issued ID',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _kycCard(
          icon: Icons.face_outlined,
          title: 'Selfie Verification',
          subtitle: 'Take a live selfie to confirm your identity',
          onTap: () {},
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Icon(Icons.security_outlined, color: Colors.white.withValues(alpha: 0.5), size: 15),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Documents are encrypted and used only for identity verification.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ];

  static const _faithOptions = [
    'Christianity',
    'Islam',
    'Judaism',
    'Hinduism',
    'Buddhism',
    'Spiritual, not religious',
    'Other',
    'Prefer not to say',
  ];

  List<Widget> _buildFaithFields() => [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hey, I\'m Chris. Do you follow a faith? I\'ll use it to personalize your LifeX Spiritual space — events, giving, and community that actually fit you.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _faithOptions.map((faith) {
            final isSelected = _selectedFaith == faith;
            return GestureDetector(
              onTap: () => setState(() => _selectedFaith = faith),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: isSelected ? 1 : 0.2)),
                ),
                child: Text(
                  faith,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF1A0A2E) : Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedFaith == 'Other') ...[
          const SizedBox(height: 14),
          _field(
            controller: _customFaithCtrl,
            hint: 'Tell us what you follow',
            icon: Icons.edit_outlined,
          ),
        ],
      ];

  Widget _countryDropdown() {
    const countries = ['Ethiopia', 'United States', 'United Kingdom', 'Kenya', 'Nigeria', 'South Africa', 'Other'];
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Color(0xFF111827), fontSize: 13),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 18),
          isExpanded: true,
          items: countries
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _selectedCountry = v ?? _selectedCountry),
        ),
      ),
    );
  }

  Widget _kycCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF374151), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.upload_outlined, color: Color(0xFF9CA3AF), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 17),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

// ── Inline calendar dialog ────────────────────────────────────────────────────

class _CalendarDialog extends StatefulWidget {
  final DateTime initial;
  final ValueChanged<DateTime> onPicked;
  const _CalendarDialog({required this.initial, required this.onPicked});

  @override
  State<_CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<_CalendarDialog> {
  late int _year;
  late int _month;
  late int? _day;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _month = widget.initial.month;
    _day = widget.initial.day;
  }

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;
  int get _firstWeekday => DateTime(_year, _month, 1).weekday % 7;

  void _confirm() {
    if (_day == null) return;
    widget.onPicked(DateTime(_year, _month, _day!));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month / year nav
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    if (_month == 1) { _month = 12; _year--; } else _month--;
                    _day = null;
                  }),
                  child: const Icon(Icons.chevron_left, color: Color(0xFF374151)),
                ),
                Column(
                  children: [
                    Text(
                      _monthNames[_month],
                      style: const TextStyle(color: Color(0xFF111827), fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '$_year',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    if (_month == 12) { _month = 1; _year++; } else _month++;
                    _day = null;
                  }),
                  child: const Icon(Icons.chevron_right, color: Color(0xFF374151)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Day-of-week headers
            Row(
              children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: _firstWeekday + _daysInMonth,
              itemBuilder: (_, i) {
                if (i < _firstWeekday) return const SizedBox.shrink();
                final day = i - _firstWeekday + 1;
                final selected = day == _day;
                return GestureDetector(
                  onTap: () => setState(() => _day = day),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF7C3AED) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF374151),
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _day != null ? _confirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Select', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
