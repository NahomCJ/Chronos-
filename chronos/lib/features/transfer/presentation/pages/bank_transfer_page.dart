import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';

class BankTransferPage extends StatelessWidget {
  const BankTransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/background.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: isSmallScreen ? 24 : 28,
                          ),
                        ),
                      ),
                      Text(
                        'Bank Transfer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use your bank account',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Tip Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ðŸ’¡',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Transfer from your bank using these details. Funds typically arrive within 1-2 business days.',
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    height: 1.5,
                                    fontSize: isSmallScreen ? 11 : 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Details Card
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2431).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Account Name',
                                'Chronos Financial Inc.',
                                isSmallScreen,
                              ),
                              _buildDetailRow(
                                'Account Number',
                                '8271 4829 1093',
                                isSmallScreen,
                              ),
                              _buildDetailRow(
                                'Routing Number',
                                '021000021',
                                isSmallScreen,
                              ),
                              _buildDetailRow(
                                'Bank Name',
                                'Chase Bank',
                                isSmallScreen,
                              ),
                              _buildDetailRow(
                                'SWIFT Code',
                                'CHASUS33',
                                isSmallScreen,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.file_download_outlined,
                                label: 'Download PDF',
                                isSmallScreen: isSmallScreen,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.share_outlined,
                                label: 'Share',
                                isSmallScreen: isSmallScreen,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 48 : 56,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF62A991),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Confirm Transfer',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isSmallScreen, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                },
                icon: Icon(
                  Icons.copy,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: isSmallScreen ? 18 : 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ),
          if (isLast) const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: isSmallScreen ? 48 : 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: isSmallScreen ? 18 : 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
