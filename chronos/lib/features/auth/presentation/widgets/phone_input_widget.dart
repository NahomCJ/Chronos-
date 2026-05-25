import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';


class PhoneInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  final String? hintText;
  final String? labelText;
  final Country? selectedCountry;
  final ValueChanged<Country>? onCountryChanged;

  const PhoneInputWidget({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.hintText,
    this.labelText,
    this.selectedCountry,
    this.onCountryChanged,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry =
        widget.selectedCountry ?? CountryParser.parseCountryCode('ET');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        backgroundColor: Colors.black,
        textStyle: const TextStyle(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
        inputDecoration: const InputDecoration(
          labelText: 'Search country',
          labelStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
        widget.onCountryChanged?.call(country);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            // Country selector
            InkWell(
              onTap: _openCountryPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCountry.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+${_selectedCountry.phoneCode}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Phone input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  // inputFormatters: const [
                  //   FilteringTextInputFormatter.digitsOnly,
                  //   LengthLimitingTextInputFormatter(15),
                  // ],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Enter phone number',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
