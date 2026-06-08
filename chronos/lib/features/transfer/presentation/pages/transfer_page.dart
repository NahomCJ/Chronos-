import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/widgets/chris_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Professional Responsive Scaling
    final size = MediaQuery.of(context).size;
    // Calculate a scale factor based on a standard design width of 390
    final double scale = size.width / 390;
    final double textScale = math.min(
      scale,
      1.1,
    ); // Cap scaling for large screens
    return Scaffold(
      backgroundColor: Colors.black,
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
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20 * scale),
                  Text(
                    'Transfer Money',
                    style: TextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24 * textScale,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to send money',
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontSize: 14 * textScale,
                    ),
                  ),
                  SizedBox(height: 40 * scale),
                  // Grid of options
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: size.width > 600 ? 3 : 2,
                      mainAxisSpacing: 16 * scale,
                      crossAxisSpacing: 16 * scale,
                      childAspectRatio: size.width > 600 ? 1.5 : 1.3,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildTransferOption(
                          icon: Icons.swap_horiz,
                          title: 'My Accounts',
                          subtitle: 'Move between accounts',
                          onTap:
                              () => context.push(
                                RouteConstants.selectMethod.toPath,
                              ),
                          scale: scale,
                          textScale: textScale,
                        ),
                        _buildTransferOption(
                          icon: Icons.person_outline,
                          title: 'Chronos User',
                          subtitle: 'Send to a friend',
                          onTap:
                              () => context.push(
                                RouteConstants.selectMethod.toPath,
                              ),
                          scale: scale,
                          textScale: textScale,
                        ),
                        _buildTransferOption(
                          icon: Icons.account_balance,
                          title: 'Bank Account',
                          subtitle: 'External transfer',
                          onTap:
                              () => context.push(
                                RouteConstants.selectMethod.toPath,
                              ),
                          scale: scale,
                          textScale: textScale,
                        ),
                        _buildTransferOption(
                          icon: Icons.public,
                          title: 'International',
                          subtitle: 'External transfer',
                          isComingSoon: true,
                          onTap: () {},
                          scale: scale,
                          textScale: textScale,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40 * scale),
                  // Recent Recipients
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Recipients',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * textScale,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'See All >',
                            style: TextStyles.labelLarge.copyWith(
                              color: const Color(0xFFB8860B),
                              fontSize: 14 * textScale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildRecipientCircle('A', scale, textScale),
                          SizedBox(width: 12 * scale),
                          _buildRecipientCircle('S', scale, textScale),
                          SizedBox(width: 12 * scale),
                          _buildRecipientCircle('M', scale, textScale),
                          SizedBox(width: 12 * scale),
                          _buildRecipientCircle('E', scale, textScale),
                          SizedBox(width: 12 * scale),
                          _buildRecipientCircle('B', scale, textScale),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const ChrisFabPositioned(),
        ],
      ),
    );
  }

  Widget _buildTransferOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double scale,
    required double textScale,
    bool isComingSoon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12 * scale),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.orangeAccent,
                    size: 24 * scale,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * textScale,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white60,
                    fontSize: 10 * textScale,
                  ),
                ),
              ],
            ),
            if (isComingSoon)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8860B).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFFB8860B).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    'Soon',
                    style: TextStyle(
                      color: const Color(0xFFB8860B),
                      fontSize: 8 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientCircle(String initial, double scale, double textScale) {
    final size = 60.0 * scale;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyles.titleMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18 * textScale,
        ),
      ),
    );
  }
}
