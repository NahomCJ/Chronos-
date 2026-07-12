import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../bloc/trade/trade_bloc.dart';
import '../../bloc/trade/trade_event.dart';
import '../../bloc/trade/trade_state.dart';
import 'buy_btc_success_page.dart';

// Light fill for input/text boxes — a clean white card with dark text,
// readable regardless of what's behind the (now-ungradiented) background photo.
const _kFieldGradient = LinearGradient(
  colors: [Color(0xFFFFFFFF), Color(0xFFF3F3F8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kFieldBorder = Color(0x14000000);
const _kFieldTextPrimary = Color(0xFF12122A);
const _kFieldTextSecondary = Color(0xFF6B6B7A);

class BuyBtcReviewPage extends StatefulWidget {
  final double amount;
  final double btcAmount;
  final String orderType;
  final double limitPrice;

  const BuyBtcReviewPage({
    super.key,
    required this.amount,
    required this.btcAmount,
    required this.orderType,
    required this.limitPrice,
  });

  @override
  State<BuyBtcReviewPage> createState() => _BuyBtcReviewPageState();
}

class _BuyBtcReviewPageState extends State<BuyBtcReviewPage> {
  late final TradeBloc _tradeBloc;

  double get fee => widget.amount * 0.01;
  double get totalCost => widget.amount + fee;

  @override
  void initState() {
    super.initState();
    _tradeBloc = GetIt.I<TradeBloc>();
  }

  @override
  void dispose() {
    _tradeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return BlocProvider.value(
      value: _tradeBloc,
      child: BlocListener<TradeBloc, TradeState>(
        listener: (context, state) {
          if (state is TradeSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BuyBtcSuccessPage(
                  amount: widget.amount,
                  btcAmount: state.result.filledAmount,
                  totalCost: totalCost,
                ),
              ),
            );
          } else if (state is TradeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
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
                                'Buy BTC',
                                style: TextStyles.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 18 : 20,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 24),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildProgressStep(true),
                              _buildProgressLine(true),
                              _buildProgressStep(true),
                              _buildProgressLine(true),
                              _buildProgressStep(true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Review Order',
                              style: TextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 18 : 20,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: _kFieldGradient,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _kFieldBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildOrderDetailRow('Asset', 'Bitcoin (BTC)'),
                                  const SizedBox(height: 12),
                                  _buildOrderDetailRow(
                                    'Amount',
                                    '${widget.btcAmount.toStringAsFixed(6)} BTC',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildOrderDetailRow(
                                    'Price',
                                    '\$${widget.limitPrice.toStringAsFixed(0)}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildOrderDetailRow(
                                      'Order Type', widget.orderType),
                                  const SizedBox(height: 14),
                                  Container(
                                    height: 1,
                                    color: _kFieldBorder,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildOrderDetailRow(
                                    'Subtotal',
                                    '\$${widget.amount.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildOrderDetailRow(
                                    'Fee (1%)',
                                    '\$${fee.toStringAsFixed(2)}',
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Cost',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: _kFieldTextPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '\$${totalCost.toStringAsFixed(2)}',
                                        style: TextStyles.bodyMedium.copyWith(
                                          color: _kFieldTextPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.warning_outlined,
                                    color: Color(0xFFF59E0B),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'This transaction is subject to market conditions. Actual execution price may vary slightly.',
                                      style: TextStyles.bodySmall.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
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
                    BlocBuilder<TradeBloc, TradeState>(
                      builder: (context, state) {
                        final isLoading = state is TradeLoading;
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _tradeBloc.add(BuyCryptoRequested(
                                          'BTC', widget.amount));
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.9),
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'Confirm Purchase',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildProgressStep(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? const Color(0xFF10B981)
            : Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF10B981)
              : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: _kFieldTextSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodySmall.copyWith(
            color: _kFieldTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
