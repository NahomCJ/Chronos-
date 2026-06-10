import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/exchange_bloc.dart';
import '../bloc/exchange_event.dart';
import '../bloc/exchange_state.dart';

class ReviewExchangePage extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;
  final String fromCurrencyName;
  final String toCurrencyName;
  final String fromFlag;
  final String toFlag;
  final String amount;
  final bool isRateLocked;

  const ReviewExchangePage({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromCurrencyName,
    required this.toCurrencyName,
    required this.fromFlag,
    required this.toFlag,
    required this.amount,
    this.isRateLocked = false,
  });

  @override
  State<ReviewExchangePage> createState() => _ReviewExchangePageState();
}

class _ReviewExchangePageState extends State<ReviewExchangePage> {
  late final ExchangeBloc _exchangeBloc;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _exchangeBloc = GetIt.I<ExchangeBloc>();
    _exchangeBloc.add(ExchangeQuoteRequested(
      fromCurrency: widget.fromCurrency,
      toCurrency: widget.toCurrency,
      amount: double.tryParse(widget.amount) ?? 0.0,
    ));
  }

  @override
  void dispose() {
    _exchangeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _exchangeBloc,
      child: BlocConsumer<ExchangeBloc, ExchangeState>(
        listener: (context, state) {
          if (state is ExchangeExecuted) {
            context.go(RouteConstants.exchangeSuccess.toPath);
          }
        },
        builder: (context, state) => _buildContent(context, state),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExchangeState state) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    final quote = state is ExchangeQuoteLoaded ? state.quote : null;
    final convertedAmount = quote != null
        ? quote.convertedAmount.toStringAsFixed(2)
        : '-';
    final exchangeRate = quote != null
        ? quote.rate.toStringAsFixed(4)
        : '-';
    final fee = quote?.fee ?? 0.0;
    final isLoading = state is ExchangeLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Review Exchange',
                          style: TextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 20),

                  // Exchange Summary Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        // From Currency
                        _buildCurrencyRow(
                          label: 'From',
                          flag: widget.fromFlag,
                          currency: widget.fromCurrency,
                          amount: widget.amount,
                          isPositive: false,
                          isSmallScreen: isSmallScreen,
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Exchange Icon
                        Container(
                          width: isSmallScreen ? 40 : 48,
                          height: isSmallScreen ? 40 : 48,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF10B981),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_downward,
                                  color: const Color(0xFF10B981),
                                  size: isSmallScreen ? 20 : 24,
                                ),
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // To Currency
                        _buildCurrencyRow(
                          label: 'To',
                          flag: widget.toFlag,
                          currency: widget.toCurrency,
                          amount: convertedAmount,
                          isPositive: true,
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Exchange Details
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exchange Details',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),

                        _buildDetailRow(
                          'Exchange Rate',
                          '1 ${widget.fromCurrency} = $exchangeRate ${widget.toCurrency}',
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildDetailRow(
                          'Fee',
                          '\$${fee.toStringAsFixed(2)}',
                          valueColor: const Color(0xFF10B981),
                          isSmallScreen: isSmallScreen,
                        ),
                        _buildDetailRow(
                          'Total Amount',
                          '${widget.amount} ${widget.fromCurrency}',
                          isSmallScreen: isSmallScreen,
                        ),
                        if (widget.isRateLocked)
                          _buildDetailRow(
                            'Rate Status',
                            'Locked for 60 seconds',
                            valueColor: Colors.orange,
                            icon: Icons.lock,
                            isSmallScreen: isSmallScreen,
                          ),

                        if (state is ExchangeError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.message,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Processing Time Info
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        Expanded(
                          child: Text(
                            'Exchange will be processed instantly. Funds will be available immediately.',
                            style: TextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 32 : 40),

                  // Confirm Button white pill
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isProcessing || isLoading || quote == null)
                          ? null
                          : () => _confirmExchange(quote.quoteId, convertedAmount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0A0A14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      child: (_isProcessing || isLoading)
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF0A0A14),
                                ),
                              ),
                            )
                          : Text(
                              'Confirm Exchange',
                              style: TextStyles.bodyLarge.copyWith(
                                color: const Color(0xFF0A0A14),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 100),
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
    required String amount,
    required bool isPositive,
    required bool isSmallScreen,
  }) {
    return Row(
      children: [
        // Flag and Currency
        Row(
          children: [
            Text(flag, style: TextStyle(fontSize: isSmallScreen ? 20 : 24)),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currency,
                  style: TextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),

        const Spacer(),

        // Amount
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isPositive ? '+$amount' : '-$amount',
              style: TextStyles.headlineSmall.copyWith(
                color: isPositive ? const Color(0xFF10B981) : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 20 : 24,
              ),
            ),
            Text(
              currency,
              style: TextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: isSmallScreen ? 10 : 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    IconData? icon,
    required bool isSmallScreen,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: valueColor ?? Colors.white,
                  size: isSmallScreen ? 14 : 16,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: TextStyles.bodyMedium.copyWith(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmExchange(String quoteId, String convertedAmount) {
    setState(() => _isProcessing = true);
    _exchangeBloc.add(ExchangeExecuteRequested(quoteId));
  }
}
