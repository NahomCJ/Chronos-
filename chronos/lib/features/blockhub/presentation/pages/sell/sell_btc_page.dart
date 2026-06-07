import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';
import 'sell_btc_order_type_page.dart';

class SellBtcPage extends StatefulWidget {
  const SellBtcPage({super.key});

  @override
  State<SellBtcPage> createState() => _SellBtcPageState();
}

class _SellBtcPageState extends State<SellBtcPage> {
  double _selectedBtcAmount = 0.015564;
  double _sliderValue = 0.25; // 25%
  final double _maxBtcAmount = 0.062256; // Available BTC balance
  final double _btcPrice = 64250.0;
  final TextEditingController _btcAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _btcAmountController.text = _selectedBtcAmount.toStringAsFixed(6);
  }

  @override
  void dispose() {
    _btcAmountController.dispose();
    super.dispose();
  }

  void _updateBtcAmount(double percentage) {
    setState(() {
      _sliderValue = percentage;
      _selectedBtcAmount = _maxBtcAmount * percentage;
      _btcAmountController.text = _selectedBtcAmount.toStringAsFixed(6);
    });
  }

  double get _usdAmount => _selectedBtcAmount * _btcPrice;
  double get _fee => _usdAmount * 0.01; // 1% fee

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

                      // Progress Indicator
                      Row(
                        children: [
                          _buildProgressStep(true), // Current step
                          _buildProgressLine(false),
                          _buildProgressStep(false),
                          _buildProgressLine(false),
                          _buildProgressStep(false),
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

                        // Select Order Type
                        Text(
                          'Select Order Type',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 18 : 20,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BTC Amount Input
                        Text(
                          'BTC Amount',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
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
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _btcAmountController,
                                  style: TextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0.015564',
                                    hintStyle: TextStyle(color: Colors.white54),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final amount = double.tryParse(value) ?? 0;
                                    setState(() {
                                      _selectedBtcAmount = amount;
                                      _sliderValue = amount / _maxBtcAmount;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'BTC',
                                style: TextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // You'll receive
                        Text(
                          'You\'ll receive',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            '\$${_usdAmount.toStringAsFixed(2)}',
                            style: TextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Select amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select amount',
                              style: TextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            Text(
                              '${(_sliderValue * 100).toInt()}%',
                              style: TextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.red,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20,
                            ),
                          ),
                          child: Slider(
                            value: _sliderValue,
                            onChanged: (value) {
                              setState(() {
                                _sliderValue = value;
                                _selectedBtcAmount = _maxBtcAmount * value;
                                _btcAmountController.text = _selectedBtcAmount
                                    .toStringAsFixed(6);
                              });
                            },
                          ),
                        ),

                        // Percentage labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0%',
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            Text(
                              '100%',
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Percentage Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPercentageButton('25%', 0.25),
                            _buildPercentageButton('50%', 0.50),
                            _buildPercentageButton('75%', 0.75),
                            _buildPercentageButton('100%', 1.0),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Info Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: const Color(0xFF3B82F6),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Fee: \$${_fee.toStringAsFixed(2)} (1%)',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Estimated price: \$${_btcPrice.toStringAsFixed(0)}',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Available balance: ${_maxBtcAmount.toStringAsFixed(6)} BTC',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

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
                        // Navigate to order type selection
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SellBtcOrderTypePage(
                                  btcAmount: _selectedBtcAmount,
                                  usdAmount: _usdAmount,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
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
        color: isActive ? Colors.red : Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildPercentageButton(String label, double value) {
    final isSelected = (_sliderValue - value).abs() < 0.01;

    return GestureDetector(
      onTap: () => _updateBtcAmount(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.red : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
