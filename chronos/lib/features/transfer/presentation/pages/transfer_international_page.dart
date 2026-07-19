import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';

class TransferInternationalPage extends StatefulWidget {
  const TransferInternationalPage({super.key});

  @override
  State<TransferInternationalPage> createState() =>
      _TransferInternationalPageState();
}

class _TransferInternationalPageState
    extends State<TransferInternationalPage> {
  Country? _country;
  final _nameCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _swiftCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  int _step = 0; // 0=country, 1=details, 2=amount

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ibanCtrl.dispose();
    _swiftCtrl.dispose();
    _bankCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _step1Valid =>
      _nameCtrl.text.isNotEmpty &&
      _ibanCtrl.text.length >= 10 &&
      _swiftCtrl.text.length >= 8 &&
      _bankCtrl.text.isNotEmpty;

  void _onReview() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ReviewSheet(
        country: _country!,
        name: _nameCtrl.text,
        iban: _ibanCtrl.text,
        swift: _swiftCtrl.text,
        bank: _bankCtrl.text,
        amount: _amountCtrl.text,
        onConfirm: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'International transfer of \$${_amountCtrl.text} initiated'),
            backgroundColor: const Color(0xFF14B8A6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
              child:
                  Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(
              child: Container(
                  color: Colors.black.withValues(alpha: 0.45))),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildStepper(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _step == 0
                        ? _buildCountryStep()
                        : _step == 1
                            ? _buildDetailsStep()
                            : _buildAmountStep(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _step > 0
                ? setState(() => _step--)
                : Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 22),
          ),
          const Expanded(
            child: Text('International',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    const labels = ['Country', 'Details', 'Amount'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: List.generate(3, (i) {
          final active = i == _step;
          final done = i < _step;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? const Color(0xFF14B8A6)
                                  : active
                                      ? Colors.white
                                      : Colors.white
                                          .withValues(alpha: 0.12),
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 14)
                                  : Text('${i + 1}',
                                      style: TextStyle(
                                          color: active
                                              ? const Color(0xFF0A0A14)
                                              : Colors.white
                                                  .withValues(alpha: 0.5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(labels[i],
                          style: TextStyle(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                              fontSize: 10)),
                    ],
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin:
                          const EdgeInsets.only(bottom: 16),
                      color: i < _step
                          ? const Color(0xFF14B8A6)
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCountryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Where are you sending to?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Select the destination country',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13)),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () => showCountryPicker(
            context: context,
            showPhoneCode: false,
            onSelect: (c) => setState(() {
              _country = c;
              _step = 1;
            }),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.public_rounded,
                          color: Color(0xFFF59E0B), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _country == null
                                ? 'Select country'
                                : '${_country!.flagEmoji}  ${_country!.name}',
                            style: TextStyle(
                                color: _country == null
                                    ? Colors.white.withValues(alpha: 0.45)
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                          if (_country != null) ...[
                            const SizedBox(height: 2),
                            Text(_country!.countryCode,
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.45),
                                    fontSize: 12)),
                          ]
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _PopularCountriesSection(
          onCountrySelected: (country) => setState(() {
            _country = country;
            _step = 1;
          }),
        ),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(_country!.flagEmoji,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text('${_country!.name} · Bank Details',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 24),
        _buildField(
            ctrl: _nameCtrl,
            label: 'Recipient Name',
            hint: 'Full legal name',
            icon: Icons.person_rounded),
        const SizedBox(height: 14),
        _buildField(
            ctrl: _ibanCtrl,
            label: 'IBAN / Account Number',
            hint: 'e.g. GB29NWBK60161331926819',
            icon: Icons.numbers_rounded,
            caps: TextCapitalization.characters),
        const SizedBox(height: 14),
        _buildField(
            ctrl: _swiftCtrl,
            label: 'SWIFT / BIC Code',
            hint: 'e.g. CHASUS33',
            icon: Icons.code_rounded,
            caps: TextCapitalization.characters),
        const SizedBox(height: 14),
        _buildField(
            ctrl: _bankCtrl,
            label: 'Bank Name',
            hint: 'Recipient\'s bank',
            icon: Icons.account_balance_rounded),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _step1Valid
                ? () => setState(() => _step = 2)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              disabledBackgroundColor:
                  Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              disabledForegroundColor:
                  Colors.white.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Continue',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('How much to send?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 28),
        Center(
          child: TextField(
            controller: _amountCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
            ],
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w300,
                letterSpacing: -1.5),
            cursorColor: const Color(0xFF14B8A6),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.18),
                  fontSize: 48,
                  fontWeight: FontWeight.w300),
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 32),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '≈ Local currency equivalent at live rate',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12),
          ),
        ),
        const SizedBox(height: 32),
        _buildFeeRow(),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _amountCtrl.text.isNotEmpty ? _onReview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              disabledBackgroundColor:
                  Colors.white.withValues(alpha: 0.08),
              foregroundColor: Colors.white,
              disabledForegroundColor:
                  Colors.white.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Review Transfer',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            children: [
              _feeItem('Transfer fee', '\$2.99'),
              const SizedBox(height: 8),
              _feeItem('Exchange rate', 'Live market rate'),
              const SizedBox(height: 8),
              _feeItem('Estimated arrival', '1–3 business days'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feeItem(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      );

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextCapitalization caps = TextCapitalization.words,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          textCapitalization: caps,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: const Color(0xFF14B8A6),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 14),
            prefixIcon: Icon(icon,
                color: Colors.white.withValues(alpha: 0.4), size: 18),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.07),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF14B8A6), width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Popular countries
// ─────────────────────────────────────────────────────────────────────────────

class _PopularCountriesSection extends StatelessWidget {
  const _PopularCountriesSection({required this.onCountrySelected});
  final ValueChanged<Country> onCountrySelected;

  static const _popular = [
    ('🇬🇧', 'UK', 'GBP'),
    ('🇪🇺', 'EU', 'EUR'),
    ('🇨🇦', 'Canada', 'CAD'),
    ('🇦🇺', 'Australia', 'AUD'),
    ('🇯🇵', 'Japan', 'JPY'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Popular Destinations',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _popular
              .map((c) => GestureDetector(
                    onTap: () => showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      onSelect: onCountrySelected,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c.$1,
                              style:
                                  const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(c.$2,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                              Text(c.$3,
                                  style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.45),
                                      fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewSheet extends StatelessWidget {
  const _ReviewSheet({
    required this.country,
    required this.name,
    required this.iban,
    required this.swift,
    required this.bank,
    required this.amount,
    required this.onConfirm,
  });
  final Country country;
  final String name;
  final String iban;
  final String swift;
  final String bank;
  final String amount;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1E),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Text('Review Transfer',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              children: [
                _row('To', '${ country.flagEmoji }  $name'),
                _row('IBAN', iban),
                _row('SWIFT', swift),
                _row('Bank', bank),
                _row('Amount', '\$$amount USD'),
                _row('Fee', '\$2.99'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Confirm & Send',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13)),
            const Spacer(),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}
