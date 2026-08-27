import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../bloc/exchange_bloc.dart';
import '../bloc/exchange_event.dart';
import '../bloc/exchange_state.dart';
import '../../domain/entities/exchange_entity.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage>
    with SingleTickerProviderStateMixin {
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  String _fromCurrencyName = 'US Dollar';
  String _toCurrencyName = 'Euro';
  String _fromFlag = '🇺🇸';
  String _toFlag = '🇪🇺';
  final TextEditingController _amountController = TextEditingController();
  late final ExchangeBloc _exchangeBloc;
  FxQuote? _lastQuote;
  late AnimationController _swapAnim;

  static const double _previewRate = 0.92;

  static const _quickAmounts = ['100', '500', '1,000', '5,000'];

  double get _typedAmount => double.tryParse(
      _amountController.text.replaceAll(',', '')) ?? 0.0;

  String get _previewConverted {
    final converted = _typedAmount * _previewRate;
    if (converted == 0.0) return '—';
    return converted.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    _exchangeBloc = GetIt.I<ExchangeBloc>();
    _amountController.addListener(() => setState(() {}));
    _swapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _swapAnim.dispose();
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

  void _swap() {
    _swapAnim.forward(from: 0);
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
                'toAmount':
                    (_lastQuote?.convertedAmount ?? state.execution.amount)
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
      backgroundColor: const Color(0xFFF0F2F7),
      extendBody: true,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 90),
        child: const ChrisHomeFab(),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 0,
        onItemSelected: (i) {
          switch (i) {
            case 0:
              context.go(RouteConstants.home.toPath);
            case 1:
              context.go(RouteConstants.pantherAi.toPath);
            case 2:
              context.go(RouteConstants.blockHub.toPath);
          }
        },
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildExchangeCard(context),
                  const SizedBox(height: 16),
                  _buildRateBadge(),
                  const SizedBox(height: 20),
                  _buildQuickAmounts(),
                  const SizedBox(height: 20),
                  _buildFeeRow(),
                  const SizedBox(height: 28),
                  _buildExchangeButton(isProcessing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A3E), Color(0xFF2D2060)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Currency Exchange',
                      style: TextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Real-time rates',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.history_rounded,
                    color: Colors.white.withValues(alpha: 0.7), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // From section
          _buildCurrencySection(
            label: 'YOU SEND',
            flag: _fromFlag,
            currency: _fromCurrency,
            currencyName: _fromCurrencyName,
            isFrom: true,
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

          // Swap divider
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 1,
                color: const Color(0xFFF0F0F5),
              ),
              GestureDetector(
                onTap: _swap,
                child: AnimatedBuilder(
                  animation: _swapAnim,
                  builder: (_, __) => Transform.rotate(
                    angle: _swapAnim.value * 3.14159,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.swap_vert_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // To section
          _buildCurrencySection(
            label: 'THEY RECEIVE',
            flag: _toFlag,
            currency: _toCurrency,
            currencyName: _toCurrencyName,
            isFrom: false,
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
    );
  }

  Widget _buildCurrencySection({
    required String label,
    required String flag,
    required String currency,
    required String currencyName,
    required bool isFrom,
    required VoidCallback onTap,
  }) {
    final amount = isFrom
        ? (_amountController.text.isEmpty ? '0.00' : _amountController.text)
        : _previewConverted;
    final amountColor = isFrom
        ? const Color(0xFF1A1A2E)
        : (_previewConverted == '—'
            ? const Color(0xFFBBBBCC)
            : const Color(0xFF22C55E));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyles.labelSmall.copyWith(
              color: const Color(0xFFAAAAAA),
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency,
                            style: TextStyles.bodyMedium.copyWith(
                              color: const Color(0xFF1A1A2E),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            currencyName,
                            style: TextStyles.bodySmall.copyWith(
                              color: const Color(0xFFAAAABB),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFFAAAABB), size: 16),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (isFrom)
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _amountController,
                    textAlign: TextAlign.right,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    style: TextStyles.headlineSmall.copyWith(
                      color: const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: Color(0xFFCCCCDD),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                )
              else
                Text(
                  amount,
                  style: TextStyles.headlineSmall.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A3E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '1 $_fromCurrency = 0.92 $_toCurrency',
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Live',
              style: TextStyles.bodySmall.copyWith(
                color: const Color(0xFF22C55E),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick amounts',
          style: TextStyles.bodySmall.copyWith(
            color: const Color(0xFF888899),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _quickAmounts.map((amt) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _amountController.text = amt.replaceAll(',', '');
                },
                child: Container(
                  margin: EdgeInsets.only(
                      right: amt == _quickAmounts.last ? 0 : 6),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E5F0)),
                  ),
                  child: Text(
                    amt,
                    textAlign: TextAlign.center,
                    style: TextStyles.bodySmall.copyWith(
                      color: const Color(0xFF3A3A5A),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeeRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _feeItem('Exchange rate', '1 $_fromCurrency = 0.92 $_toCurrency'),
          const Divider(height: 12, color: Color(0xFFF0F0F8)),
          _feeItem('Our fee', '0.15% spread'),
          const Divider(height: 12, color: Color(0xFFF0F0F8)),
          _feeItem('Estimated arrival', 'Instant'),
        ],
      ),
    );
  }

  Widget _feeItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: const Color(0xFF888899),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodySmall.copyWith(
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExchangeButton(bool isProcessing) {
    final enabled = _typedAmount > 0 && !isProcessing;
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: GestureDetector(
        onTap: enabled ? _onExchangePressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                  )
                : null,
            color: enabled ? null : const Color(0xFFDDDDEE),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Exchange Now',
                        style: TextStyles.bodyLarge.copyWith(
                          color: enabled ? Colors.white : const Color(0xFFAAAABB),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (enabled) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 15),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
