import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';

class SelectMethodPage extends StatefulWidget {
  const SelectMethodPage({super.key});

  @override
  State<SelectMethodPage> createState() => _SelectMethodPageState();
}

class _SelectMethodPageState extends State<SelectMethodPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animations = List.generate(
      5,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.2 + (index * 0.1),
          0.6 + (index * 0.1),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Professional Responsive Scaling
    final size = MediaQuery.of(context).size;
    final double scale = size.width / 390;
    final double textScale = math.min(
      scale,
      1.1,
    ); // Cap scaling for large screens
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Select Method',
                  style: TextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24 * textScale,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                  child: Text(
                    'How would you like to identify the recipient?',
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontSize: 14 * textScale,
                    ),
                  ),
                ),
                SizedBox(height: 32 * scale),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildAnimatedMethodTile(
                        index: 0,
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        subtitle: 'Send to anyone using their phone number',
                        scale: scale,
                        textScale: textScale,
                        onTap:
                            () => context.push(
                              RouteConstants.addRecipient.toPath,
                            ),
                      ),
                      _buildAnimatedMethodTile(
                        index: 1,
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: 'Send using recipient email address',
                        scale: scale,
                        textScale: textScale,
                        onTap: () {},
                      ),
                      _buildAnimatedMethodTile(
                        index: 2,
                        icon: Icons.qr_code_scanner,
                        title: 'Scan QR Code',
                        subtitle: 'Scan recipient\'s chronos QR code',
                        scale: scale,
                        textScale: textScale,
                        onTap: () {},
                      ),
                      _buildAnimatedMethodTile(
                        index: 3,
                        icon: Icons.account_balance_outlined,
                        title: 'Bank Account',
                        subtitle: 'Enter bank details manually',
                        scale: scale,
                        textScale: textScale,
                        onTap: () {},
                      ),
                      _buildAnimatedMethodTile(
                        index: 4,
                        icon: Icons.star_border,
                        title: 'Saved Beneficiaries',
                        subtitle: 'Choose from your saved contacts',
                        scale: scale,
                        textScale: textScale,
                        onTap: () {},
                      ),
                      SizedBox(height: 40 * scale),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMethodTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required double scale,
    required double textScale,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _animations[index],
      child: SlideTransition(
        position: _animations[index].drive(
          Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 16 * scale),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12 * scale),
            child: Container(
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.orangeAccent, size: 28 * scale),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * textScale,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          subtitle,
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.white60,
                            fontSize: 12 * textScale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
