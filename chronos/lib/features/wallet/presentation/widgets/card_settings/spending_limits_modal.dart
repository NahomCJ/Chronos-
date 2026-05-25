import 'package:flutter/material.dart';
import '../../../../../core/theme/text_theme.dart';

class SpendingLimitsModal extends StatefulWidget {
  const SpendingLimitsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SpendingLimitsModal(),
    );
  }

  @override
  State<SpendingLimitsModal> createState() => _SpendingLimitsModalState();
}

class _SpendingLimitsModalState extends State<SpendingLimitsModal> {
  // 1. Define State Variables
  double _dailyLimit = 500.0;
  double _monthlyLimit = 5000.0;
  double _atmLimit = 300.0;

  // 2. Define Constraints
  final double _minLimit = 50.0;
  final double _maxDailyLimit = 2000.0;
  final double _maxMonthlyLimit = 20000.0;
  final double _maxAtmLimit = 1000.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Header Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Limits',
                      style: TextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chronos Platinum •••• 4829',
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Container(
            margin: EdgeInsets.all(16),
              height: 1,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.2),
            ),

            // --- Scrollable Content Section ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Daily Limit Section
                    _buildLimitSection(
                      title: 'Daily Spending Limit',
                      icon: Icons.wb_sunny_outlined,
                      currentValue: _dailyLimit,
                      maxValue: _maxDailyLimit,
                      onChanged: (value) => setState(() => _dailyLimit = value),
                    ),

                    const SizedBox(height: 24),

                    // 2. Monthly Limit Section
                    _buildLimitSection(
                      title: 'Monthly Spending Limit',
                      icon: Icons.calendar_month_outlined,
                      currentValue: _monthlyLimit,
                      maxValue: _maxMonthlyLimit,
                      onChanged:
                          (value) => setState(() => _monthlyLimit = value),
                    ),

                    const SizedBox(height: 24),

                    // 3. ATM Limit Section
                    _buildLimitSection(
                      title: 'ATM Withdrawal Limit',
                      icon: Icons.local_atm_outlined,
                      currentValue: _atmLimit,
                      maxValue: _maxAtmLimit,
                      onChanged: (value) => setState(() => _atmLimit = value),
                    ),

                    const SizedBox(height: 32),

                    // Info Warning Box
                    Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1F2937), Color(0xFF111827)],
    ),
    borderRadius: BorderRadius.circular(12),
    // Updated Border: Bold and new Color
    border: Border.all(
      color: const Color(0xFFDC8F4A), // Your requested color
      width: 2.0, // Increased width to make it bold
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Icon Box
      // Container(
      //   padding: const EdgeInsets.all(10),
      //   decoration: BoxDecoration(
      //     color: const Color(0xFFDC8F4A).withValues(alpha: 0.15),
      //     borderRadius: BorderRadius.circular(10),
      //   ),
      //   child: const Icon(
      //     Icons.auto_awesome_outlined,
      //     color: Color(0xFFDC8F4A), // Matching icon color
      //     size: 24,
      //   ),
      // ),
      const SizedBox(width: 16),
      
      // Text Content
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology_alt,
                  color: Color(0xFFDC8F4A), // Matching header icon color
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Panther AI',
                  style: TextStyles.titleSmall.copyWith(
                    color: const Color(0xFFDC8F4A), // Matching header text color
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Based on your spending habits, a daily limit of \$500 covers 95% of your transactions while protecting against fraud.',
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      
      Icon(
        Icons.chevron_right,
        color: Colors.white.withValues(alpha: 0.3),
        size: 20,
      ),
    ],
  ),
)
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Save Button ---
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Spending limits updated successfully'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB0B0B0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB0B0B0).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Save Changes',
                  textAlign: TextAlign.center,
                  style: TextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Widget for the Limits ---
  Widget _buildLimitSection({
    required String title,
    required IconData icon,
    required double currentValue,
    required double maxValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // THE REQUESTED UI CONTAINER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Value Display Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Grouping Icon and Title to keep them together on the left
                  Row(
                    children: [
                      Icon(icon, color: const Color(0xFFB0B0B0), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Amount stays on the right
                  Text(
                    '\$${currentValue.toStringAsFixed(0)}',
                    style: TextStyles.bodyMedium.copyWith(
                      color: const Color(0xFFDC8F4A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              // Subtitle aligned to the left
              const SizedBox(height: 4), // Small gap between rows
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Limit Amount',
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFDC8F4A),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFFDC8F4A).withValues(alpha: 0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                ),
                child: Slider(
                  value: currentValue,
                  min: _minLimit,
                  max: maxValue,
                  divisions: (maxValue / 50).round(),
                  onChanged: onChanged,
                ),
              ),

              // Min/Max Labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${_minLimit.toInt()}',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    Text(
                      '\$${maxValue.toInt()}',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
