import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/theme/preset_colors.dart';
import '../../../../core/utils/error_toast.dart';

class TransferSuccessPage extends StatelessWidget {
  final String amount;
  final String recipientName;
  final String method;

  const TransferSuccessPage({
    super.key,
    this.amount = "1000.00",
    this.recipientName = "Alex Johnson",
    this.method = "Chronos User",
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = size.width / 390;
    final double textScale = math.min(scale, 1.1);
    final isShortScreen = size.height < 700;

    final String transactionId = "TXN52749822";
    final String timestamp = DateFormat(
      'MMM dd, yyyy â€¢ HH:mm',
    ).format(DateTime.now());

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
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go(RouteConstants.home.toPath),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24 * scale,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: (isShortScreen ? 10 : 20) * scale,
                                ),
                                // Success Icon
                                Container(
                                  width: 80 * scale,
                                  height: 80 * scale,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00C077),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 50 * scale,
                                  ),
                                ),
                                SizedBox(height: 24 * scale),
                                Text(
                                  'Transfer Successful',
                                  style: TextStyles.titleMedium.copyWith(
                                    color: Colors.white70,
                                    fontSize: 16 * textScale,
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                Text(
                                  'USD $amount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40 * textScale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 32 * scale),
                                // Recipient Info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 48 * scale,
                                      height: 48 * scale,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                        color: Colors.white.withValues(alpha: 0.1),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        recipientName.isNotEmpty
                                            ? recipientName[0]
                                            : '?',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16 * textScale,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12 * scale),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipientName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18 * textScale,
                                          ),
                                        ),
                                        Text(
                                          method,
                                          style: TextStyle(
                                            color: const Color(0xFF00C077),
                                            fontSize: 14 * textScale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 32 * scale),
                                const Divider(color: Colors.white24),
                                SizedBox(height: 24 * scale),
                                // Details
                                _buildDetailRow(
                                  'Timestamp',
                                  timestamp,
                                  textScale,
                                ),
                                SizedBox(height: 16 * scale),
                                _buildTransactionIdRow(
                                  context,
                                  transactionId,
                                  scale,
                                  textScale,
                                ),
                                const Spacer(),
                                SizedBox(height: 24 * scale),
                                // Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSecondaryButton(
                                        icon: Icons.file_download_outlined,
                                        label: 'Receipt',
                                        scale: scale,
                                        textScale: textScale,
                                        onTap: () {},
                                      ),
                                    ),
                                    SizedBox(width: 16 * scale),
                                    Expanded(
                                      child: _buildSecondaryButton(
                                        icon: Icons.share_outlined,
                                        label: 'Share',
                                        scale: scale,
                                        textScale: textScale,
                                        onTap: () {},
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16 * scale),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54 * scale,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => context.go(
                                          RouteConstants.transfer.toPath,
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CColor.primaryButton,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12 * scale,
                                        ),
                                      ),
                                    ),
                                    icon: Icon(Icons.refresh, size: 20 * scale),
                                    label: Text(
                                      'Send Again',
                                      style: TextStyle(
                                        fontSize: 16 * textScale,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20 * scale),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double textScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white60, fontSize: 14 * textScale),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 14 * textScale),
        ),
      ],
    );
  }

  Widget _buildTransactionIdRow(
    BuildContext context,
    String id,
    double scale,
    double textScale,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transaction ID',
          style: TextStyle(color: Colors.white60, fontSize: 14 * textScale),
        ),
        Row(
          children: [
            Text(
              id,
              style: TextStyle(color: Colors.white, fontSize: 14 * textScale),
            ),
            SizedBox(width: 8 * scale),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: id));
                ErrorToast.show(
                  context,
                  "ID Copied to clipboard",
                  backgroundColor: Colors.blueGrey,
                );
              },
              child: Icon(
                Icons.copy,
                color: const Color(0xFF00C077),
                size: 18 * scale,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required double scale,
    required double textScale,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * scale),
      child: Container(
        height: 54 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 20 * scale),
            SizedBox(width: 8 * scale),
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14 * textScale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
