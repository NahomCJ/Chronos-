import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';

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
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
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
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/background.png', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.45)),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      Text(
                        'Exchange',
                        style: TextStyles.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Currency Selectors Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                              ),
                              child: Column(
                                children: [
                                  _buildCurrencyRow(
                                    label: 'You send',
                                    flag: _fromFlag,
                                    currency: _fromCurrency,
                                    currencyName: _fromCurrencyName,
                                    showInput: true,
                                    onTap: () async {
                                      final result = await context.push(
                                        RouteConstants.selectCurrency.toPath,
                                        extra: {
                                          'currentCurrency': _fromCurrency,
                                          'isFromCurrency': true,
                                        },
                                      );
                                      if (result != null && result is Map<String, dynamic>) {
                                        setState(() {
                                          _fromCurrency = result['currency'] ?? _fromCurrency;
                                          _fromCurrencyName = result['name'] ?? _fromCurrencyName;
                                          _fromFlag = result['flag'] ?? _fromFlag;
                                        });
                                      }
                                    },
                                  ),

                                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),

                                  // Swap button centered on divider
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const SizedBox(height: 0),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
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
                                          width: 30,
                                          height: 30,
                                          margin: const EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.10),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                                          ),
                                          child: Icon(
                                            Icons.swap_vert_rounded,
                                            color: Colors.white.withValues(alpha: 0.6),
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  _buildCurrencyRow(
                                    label: 'They receive',
                                    flag: _toFlag,
                                    currency: _toCurrency,
                                    currencyName: _toCurrencyName,
                                    showInput: false,
                                    onTap: () async {
                                      final result = await context.push(
                                        RouteConstants.selectCurrency.toPath,
                                        extra: {
                                          'currentCurrency': _toCurrency,
                                          'isFromCurrency': false,
                                        },
                                      );
                                      if (result != null && result is Map<String, dynamic>) {
                                        setState(() {
                                          _toCurrency = result['currency'] ?? _toCurrency;
                                          _toCurrencyName = result['name'] ?? _toCurrencyName;
                                          _toFlag = result['flag'] ?? _toFlag;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Rate pill
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                                ),
                                child: Text(
                                  '1 $_fromCurrency = 0.92 $_toCurrency',
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Rate info cards
                        Row(
                          children: [
                            Expanded(child: _buildInfoCard(
                              icon: Icons.trending_up,
                              iconColor: const Color(0xFF10B981),
                              title: 'Best Rate',
                              subtitle: '0.92 EUR',
                            )),
                            const SizedBox(width: 10),
                            Expanded(child: _buildInfoCard(
                              icon: Icons.shield_outlined,
                              iconColor: Colors.blue,
                              title: 'No hidden fees',
                              subtitle: '0.15% spread',
                            )),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Review Exchange Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
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
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A0A14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(
                              'Review Exchange',
                              style: TextStyles.bodyLarge.copyWith(
                                color: const Color(0xFF0A0A14),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
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

  Widget _buildCurrencyRow({
    required String label,
    required String flag,
    required String currency,
    required String currencyName,
    required bool showInput,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            // Currency selector tap area
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  // Flag
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        flag,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency,
                        style: TextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        currencyName,
                        style: TextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Amount
            if (showInput)
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _amountController,
                  textAlign: TextAlign.right,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  style: TextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: Color(0xFF555570),
                      fontSize: 15,
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              )
            else
              Text(
                '-',
                style: TextStyles.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
