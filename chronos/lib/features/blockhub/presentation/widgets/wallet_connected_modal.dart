import 'package:flutter/material.dart';
import '../../../../core/theme/text_theme.dart';
import '../pages/onboarding/wallet_connected_success_page.dart';

class WalletConnectedModal extends StatelessWidget {
  final String walletAddress;

  const WalletConnectedModal({super.key, this.walletAddress = '0x742d...f8a3'});

  static void show(BuildContext context, {String? walletAddress}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useRootNavigator: true,
      builder:
          (context) => WalletConnectedModal(
            walletAddress: walletAddress ?? '0x742d...f8a3',
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    // Responsive sizing
    final iconSize = isSmallScreen ? 80.0 : (isMediumScreen ? 90.0 : 100.0);
    final titleFontSize = isSmallScreen ? 20.0 : (isMediumScreen ? 22.0 : 24.0);
    final bodyFontSize = isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);
    final horizontalPadding = isSmallScreen ? 20.0 : 24.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.55  ,
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
      child: Column(
        children: [
        


  

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 40 : 60),

                  // Success icon
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: const Color(0xFF10B981),
                      size: iconSize * 0.5,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Success message
                  Text(
                    'BlockHub Wallet connected\nsuccessfully',
                    textAlign: TextAlign.center,
                    style: TextStyles.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: bodyFontSize,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Success title
                  Text(
                    'Wallet Connected!',
                    textAlign: TextAlign.center,
                    style: TextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: titleFontSize,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 32),

                  // Wallet Address
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      walletAddress,
                      textAlign: TextAlign.center,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 10 : 20),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => const WalletConnectedSuccessPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyles.bodyLarge.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 15 : 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
