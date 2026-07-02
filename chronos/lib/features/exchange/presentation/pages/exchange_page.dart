import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/fluid_glass.dart';
import '../../../../core/widgets/app_background.dart';
import '../bloc/exchange_bloc.dart';
import '../bloc/exchange_event.dart';
import '../bloc/exchange_state.dart';
import '../../domain/entities/exchange_entity.dart';

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
  late final ExchangeBloc _exchangeBloc;
  FxQuote? _lastQuote;

  static const double _previewRate = 0.92;

  double get _typedAmount => double.tryParse(_amountController.text) ?? 0.0;

  String get _previewConverted {
    final converted = _typedAmount * _previewRate;
    if (converted == 0.0) return '-';
    return converted.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    _exchangeBloc = GetIt.I<ExchangeBloc>();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _exchangeBloc.close();
    super.dispose();
  }

  void _onExchangePressed() {
    if (_typedAmount <= 0) return;
    _exchangeBloc.add(ExchangeQuoteRequested(
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
      amount: _typedAmount,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _exchangeBloc,
      child: BlocConsumer<ExchangeBloc, ExchangeState>(
        listener: (context, state) {
          if (state is ExchangeQuoteLoaded) {
            _lastQuote = state.quote;
            _exchangeBloc.add(ExchangeExecuteRequested(state.quote.quoteId));
          } else if (state is ExchangeExecuted) {
            context.go(
              RouteConstants.exchangeSuccess.toPath,
              extra: {
                'fromCurrency': _fromCurrency,
                'toCurrency': _toCurrency,
                'fromAmount': _amountController.text,
                'toAmount': (_lastQuote?.convertedAmount ?? state.execution.amount)
                    .toStringAsFixed(2),
                'fromFlag': _fromFlag,
                'toFlag': _toFlag,
              },
            );
          } else if (state is ExchangeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) => _buildScaffold(context, state),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, ExchangeState state) {
    final isProcessing = state is ExchangeLoading;
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
      body: AppBackground(
        overlayOpacity: 0.45,
        child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: FluidGlass.dark(
                    borderRadius: BorderRadius.circular(14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18)),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Exchange',
                            textAlign: TextAlign.center,
                            style: TextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 34),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Currency Selectors Card
                        FluidGlass.dark(
                          borderRadius: BorderRadius.circular(18),
                          blur: 16,
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
                                          margin: const EdgeInsets.symmetric(vertical: 3),
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
                                    previewAmount: _previewConverted,
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

                        const SizedBox(height: 12),

                        // Rate pill
                        Center(
                          child: FluidGlass.dark(
                            borderRadius: BorderRadius.circular(20),
                            blur: 8,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded,
                                    color: Colors.white.withValues(alpha: 0.7), size: 13),
                                const SizedBox(width: 5),
                                Text(
                                  '1 $_fromCurrency = 0.92 $_toCurrency',
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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

                        // Exchange Now Button
                        FluidGlass.dark(
                          borderRadius: BorderRadius.circular(26),
                          padding: const EdgeInsets.all(4),
                          showShadow: false,
                          child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: (_typedAmount <= 0 || isProcessing)
                                ? null
                                : _onExchangePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A0A14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              disabledBackgroundColor: Colors.white.withValues(alpha: 0.4),
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF0A0A14),
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Exchange Now',
                                    style: TextStyles.bodyLarge.copyWith(
                                      color: const Color(0xFF0A0A14),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
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
    String? previewAmount,
  }) {
    return SizedBox(
      height: 46,
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
                previewAmount ?? '-',
                style: TextStyles.bodyLarge.copyWith(
                  color: Colors.white.withValues(
                    alpha: previewAmount == null || previewAmount == '-' ? 0.35 : 1,
                  ),
                  fontWeight: previewAmount == null || previewAmount == '-'
                      ? FontWeight.normal
                      : FontWeight.w600,
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
    return FluidGlass.dark(
      borderRadius: BorderRadius.circular(14),
      blur: 10,
      padding: const EdgeInsets.all(12),
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
    );
  }
}
