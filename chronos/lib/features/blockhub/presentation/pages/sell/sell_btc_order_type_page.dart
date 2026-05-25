import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'sell_btc_review_page.dart';

enum SellOrderType { market, limit }

class SellBtcOrderTypePage extends StatefulWidget {
  final double btcAmount;
  final double usdAmount;

  const SellBtcOrderTypePage({
    super.key,
    required this.btcAmount,
    required this.usdAmount,
  });

  @override
  State<SellBtcOrderTypePage> createState() => _SellBtcOrderTypePageState();
}

class _SellBtcOrderTypePageState extends State<SellBtcOrderTypePage> {
  SellOrderType _selectedOrderType = SellOrderType.limit;
  final TextEditingController _limitPriceController = TextEditingController();
  final double _currentMarketPrice = 64250.0;

  @override
  void initState() {
    super.initState();
    _limitPriceController.text = _currentMarketPrice.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _limitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Sell BTC',
                            style: TextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 18 : 20,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 24), // Balance the back button
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Progress Indicator (Step 2 of 3)
                      Row(
                        children: [
                          _buildProgressStep(true), // Step 1 completed
                          _buildProgressLine(true), // Line completed
                          _buildProgressStep(true), // Step 2 current
                          _buildProgressLine(false), // Line not completed
                          _buildProgressStep(false), // Step 3 not reached
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Select Order Type Title
                        Text(
                          'Select Order Type',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 18 : 20,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Market Order Option
                        _buildOrderTypeOption(
                          orderType: SellOrderType.market,
                          title: 'Market Order',
                          description:
                              'Execute immediately\nat current market price',
                          isSelected:
                              _selectedOrderType == SellOrderType.market,
                          onTap: () {
                            setState(() {
                              _selectedOrderType = SellOrderType.market;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Limit Order Option
                        _buildOrderTypeOption(
                          orderType: SellOrderType.limit,
                          title: 'Limit Order',
                          description:
                              'Execute only when price\nreaches your target',
                          isSelected: _selectedOrderType == SellOrderType.limit,
                          onTap: () {
                            setState(() {
                              _selectedOrderType = SellOrderType.limit;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        // Limit Price Input (only show when Limit Order is selected)
                        if (_selectedOrderType == SellOrderType.limit) ...[
                          Text(
                            'Limit Price (USD)',
                            style: TextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '\$',
                                  style: TextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _limitPriceController,
                                    style: TextStyles.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '64250',
                                      hintStyle: TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle continue to next step
                        _handleContinueToReview();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyles.titleMedium.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildProgressStep(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.red : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildOrderTypeOption({
    required SellOrderType orderType,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? Colors.red : Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      )
                      : null,
            ),

            const SizedBox(width: 16),

            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinueToReview() {
    // Navigate to review page
    final limitPrice =
        _selectedOrderType == SellOrderType.limit
            ? double.tryParse(_limitPriceController.text) ?? _currentMarketPrice
            : _currentMarketPrice;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SellBtcReviewPage(
              btcAmount: widget.btcAmount,
              usdAmount: widget.usdAmount,
              orderType:
                  _selectedOrderType == SellOrderType.market
                      ? 'Market'
                      : 'Limit',
              limitPrice: limitPrice,
            ),
      ),
    );
  }
}
