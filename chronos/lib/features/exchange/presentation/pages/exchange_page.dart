import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_fab.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  String _fromCurrencyName = 'US Dollar';
  String _toCurrencyName = 'Euro';
  String _fromFlag = '🇺🇸';
  String _toFlag = '🇪🇺';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(RouteConstants.home.toPath);
                            }
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Text(
                              'Exchange',
                              style: TextStyles.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 20 : 24,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 2 : 4),
                            Text(
                              'Convert currencies instantly',
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 24), // Balance for back button
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Live Market Banner
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.trending_up,
                            color: const Color(0xFF10B981),
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live Market',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                              Text(
                                'USD → EUR',
                                style: TextStyles.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: isSmallScreen ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: isSmallScreen ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+0.34% today',
                            style: TextStyles.bodySmall.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 10 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Exchange Cards
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: horizontalPadding - 4,
                    ),
                    padding: EdgeInsets.only(
                      top: isSmallScreen ? 12 : 15,
                      bottom: isSmallScreen ? 12 : 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // From Currency Card
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                              ),
                              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: _buildCurrencySelector(
                                label: 'From',
                                flag: _fromFlag,
                                currency: _fromCurrency,
                                currencyName: _fromCurrencyName,
                                isSmallScreen: isSmallScreen,
                                onTap: () async {
                                  final result = await context.push(
                                    RouteConstants.selectCurrency.toPath,
                                    extra: {
                                      'currentCurrency': _fromCurrency,
                                      'isFromCurrency': true,
                                    },
                                  );

                                  if (result != null &&
                                      result is Map<String, dynamic>) {
                                    setState(() {
                                      _fromCurrency =
                                          result['currency'] ?? _fromCurrency;
                                      _fromCurrencyName =
                                          result['name'] ?? _fromCurrencyName;
                                      _fromFlag = result['flag'] ?? _fromFlag;
                                    });
                                  }
                                },
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 20 : 25),

                            // To Currency Card
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 16 : 20,
                              ),
                              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: _buildCurrencySelector(
                                label: 'To',
                                flag: _toFlag,
                                currency: _toCurrency,
                                currencyName: _toCurrencyName,
                                isSmallScreen: isSmallScreen,
                                onTap: () async {
                                  final result = await context.push(
                                    RouteConstants.selectCurrency.toPath,
                                    extra: {
                                      'currentCurrency': _toCurrency,
                                      'isFromCurrency': false,
                                    },
                                  );

                                  if (result != null &&
                                      result is Map<String, dynamic>) {
                                    setState(() {
                                      _toCurrency =
                                          result['currency'] ?? _toCurrency;
                                      _toCurrencyName =
                                          result['name'] ?? _toCurrencyName;
                                      _toFlag = result['flag'] ?? _toFlag;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        // Swap Button - Positioned between cards
                        Positioned(
                          top: isSmallScreen ? 75 : 90,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Swap currencies
                                  final tempCurrency = _fromCurrency;
                                  final tempName = _fromCurrencyName;
                                  final tempFlag = _fromFlag;

                                  _fromCurrency = _toCurrency;
                                  _fromCurrencyName = _toCurrencyName;
                                  _fromFlag = _toFlag;

                                  _toCurrency = tempCurrency;
                                  _toCurrencyName = tempName;
                                  _toFlag = tempFlag;
                                });
                              },
                              child: Container(
                                width: isSmallScreen ? 40 : 48,
                                height: isSmallScreen ? 40 : 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.swap_vert,
                                  color: Colors.black,
                                  size: isSmallScreen ? 18 : 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Rate Information - Responsive Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Use column layout on smaller screens
                      if (constraints.maxWidth < 400) {
                        return Column(
                          children: [
                            _buildRateCard(
                              icon: Icons.trending_up,
                              iconColor: const Color(0xFF10B981),
                              title: 'Best Rate',
                              subtitle: '1 USD → 0.92 EUR',
                              margin: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            _buildRateCard(
                              icon: Icons.security,
                              iconColor: Colors.orange,
                              title: 'No hidden fees',
                              subtitle: '0.15% FX spread',
                              subtitleColor: const Color(0xFF10B981),
                              margin: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        );
                      }

                      // Use row layout on larger screens
                      return Row(
                        children: [
                          Expanded(
                            child: _buildRateCard(
                              icon: Icons.trending_up,
                              iconColor: const Color(0xFF10B981),
                              title: 'Best Rate',
                              subtitle: '1 USD → 0.92 EUR',
                              margin: EdgeInsets.only(
                                left: horizontalPadding,
                                right: 10,
                              ),
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                          Expanded(
                            child: _buildRateCard(
                              icon: Icons.security,
                              iconColor: Colors.orange,
                              title: 'No hidden fees',
                              subtitle: '0.15% FX spread',
                              subtitleColor: const Color(0xFF10B981),
                              margin: EdgeInsets.only(
                                left: 10,
                                right: horizontalPadding,
                              ),
                              isSmallScreen: isSmallScreen,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Panther AI Insight
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.psychology,
                            color: Colors.orange,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Panther AI Insight',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 6 : 8),
                              Text(
                                'EUR is currently strong. Waiting 24h may improve your rate by ~0.2%.',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add spacing instead of Spacer
                  SizedBox(height: isSmallScreen ? 32 : 40),

                  // Continue Button
                  Container(
                    margin: EdgeInsets.all(horizontalPadding),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          RouteConstants.enterExchangeAmount.toPath,
                          extra: {
                            'fromCurrency': _fromCurrency,
                            'toCurrency': _toCurrency,
                            'fromCurrencyName': _fromCurrencyName,
                            'toCurrencyName': _toCurrencyName,
                            'fromFlag': _fromFlag,
                            'toFlag': _toFlag,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB0B0B0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue to Exchange',
                            style: TextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 14 : 14,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Add bottom padding for bottom navigation
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          const ChrisFabPositioned(),
        ],
      ),
    );
  }

  Widget _buildRateCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    required EdgeInsets margin,
    required bool isSmallScreen,
  }) {
    return Container(
      margin: margin,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: isSmallScreen ? 14 : 16),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            subtitle,
            style: TextStyles.bodyMedium.copyWith(
              color: subtitleColor ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String label,
    required String flag,
    required String currency,
    required String currencyName,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 11 : 12,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Row(
            children: [
              // Flag container
              Container(
                width: isSmallScreen ? 36 : 40,
                height: isSmallScreen ? 24 : 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    flag,
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              // Currency info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency,
                      style: TextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyName,
                      style: TextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white.withValues(alpha: 0.6),
                size: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
