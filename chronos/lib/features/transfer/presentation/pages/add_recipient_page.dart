import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/preset_colors.dart';

class AddRecipientPage extends StatefulWidget {
  const AddRecipientPage({super.key});

  @override
  State<AddRecipientPage> createState() => _AddRecipientPageState();
}

class _AddRecipientPageState extends State<AddRecipientPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  Country? _selectedCountry;
  bool _isButtonEnabled = false;
  int? _selectedRecipientIndex;

  final List<Map<String, String>> _recentRecipients = [
    {'name': 'Alex Johnson', 'initial': 'A', 'lastActivity': '2 days ago'},
    {'name': 'Sara Williams', 'initial': 'S', 'lastActivity': '4 days ago'},
    {'name': 'Mike Chen', 'initial': 'M', 'lastActivity': '6 days ago'},
  ];

  late AnimationController _controller;
  late List<Animation<double>> _listAnimations;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('US');
    _phoneController.addListener(_validateInput);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _listAnimations = List.generate(
      4,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.1 * index,
          0.4 + (0.1 * index),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    final text = _phoneController.text;
    setState(() {
      _isButtonEnabled =
          (text.length >= 8 && text.length <= 15) ||
          _selectedRecipientIndex != null;
    });
  }

  void _onRecipientTap(int index) {
    setState(() {
      if (_selectedRecipientIndex == index) {
        _selectedRecipientIndex = null;
      } else {
        _selectedRecipientIndex = index;
        _phoneController.clear();
      }
      _validateInput();
    });
  }

  void _onContinue() {
    String name = "Unknown";
    String method = "Transfer";

    if (_selectedRecipientIndex != null) {
      name = _recentRecipients[_selectedRecipientIndex!]['name']!;
      method = "Chronos User";
    } else {
      name = "+${_selectedCountry?.phoneCode ?? '1'} ${_phoneController.text}";
      method = "Phone Number";
    }

    context.push(
      RouteConstants.enterAmount.toPath,
      extra: {'recipientName': name, 'method': method},
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = size.width / 390;
    final double textScale = math.min(scale, 1.1);
    final bool isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A))),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, scale, textScale, isSmallScreen),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: (isSmallScreen ? 10 : 20) * scale),
                        _buildAnimatedWidget(
                          animation: _listAnimations[0],
                          child: _buildPhoneInput(
                            scale,
                            textScale,
                            isSmallScreen,
                          ),
                        ),
                        SizedBox(height: (isSmallScreen ? 20 : 32) * scale),
                        ...List.generate(3, (index) {
                          final recipient = _recentRecipients[index];
                          return _buildAnimatedWidget(
                            animation: _listAnimations[index + 1],
                            child: _buildRecentRecipient(
                              index: index,
                              name: recipient['name']!,
                              initial: recipient['initial']!,
                              lastActivity: recipient['lastActivity']!,
                              scale: scale,
                              textScale: textScale,
                              isSmallScreen: isSmallScreen,
                            ),
                          );
                        }),
                        SizedBox(height: (isSmallScreen ? 24 : 40) * scale),
                        _buildContinueButton(scale, textScale, isSmallScreen),
                        SizedBox(height: 24 * scale),
                      ],
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

  Widget _buildAnimatedWidget({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    double scale,
    double textScale,
    bool isSmallScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
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
                    'Add Recipient',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 48 * scale),
            ],
          ),
          Text(
            'Phone Number',
            style: TextStyle(color: Colors.white70, fontSize: 16 * textScale),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(double scale, double textScale, bool isSmallScreen) {
    return Container(
      height: 60 * scale,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: Colors.white24),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
              );
            },
            child: Row(
              children: [
                Text(
                  _selectedCountry?.flagEmoji ?? 'ðŸ‡ºðŸ‡¸',
                  style: TextStyle(fontSize: 24 * scale),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 20 * scale,
                ),
                SizedBox(width: 8 * scale),
                Container(height: 24 * scale, width: 1, color: Colors.white24),
                SizedBox(width: 12 * scale),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: Colors.white, fontSize: 18 * textScale),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              onChanged: (_) {
                setState(() => _selectedRecipientIndex = null);
                _validateInput();
              },
              decoration: InputDecoration(
                hintText: '123 4567 890',
                hintStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: 18 * textScale,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecipient({
    required int index,
    required String name,
    required String initial,
    required String lastActivity,
    required double scale,
    required double textScale,
    required bool isSmallScreen,
  }) {
    bool isSelected = _selectedRecipientIndex == index;
    final avatarSize = 48.0 * scale;

    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: InkWell(
        onTap: () => _onRecipientTap(index),
        borderRadius: BorderRadius.circular(12 * scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: isSelected ? CColor.primaryButton : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
            color:
                isSelected
                    ? CColor.primaryButton.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
          ),
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38),
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * textScale,
                  ),
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * textScale,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Row(
                      children: [
                        Text(
                          'Chronos',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12 * textScale,
                          ),
                        ),
                        Text(
                          ' . $lastActivity',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12 * textScale,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                  size: 20 * scale,
                )
              else
                Container(
                  width: 8 * scale,
                  height: 8 * scale,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    double scale,
    double textScale,
    bool isSmallScreen,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 54 * scale,
      child: ElevatedButton(
        onPressed: _isButtonEnabled ? _onContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isButtonEnabled
                  ? CColor.primaryButton
                  : Colors.white.withValues(alpha: 0.1),
          foregroundColor: _isButtonEnabled ? Colors.white : Colors.white38,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
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
