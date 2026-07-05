import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/theme/text_theme.dart';
import '../../bloc/trade/trade_bloc.dart';
import '../../bloc/trade/trade_event.dart';
import '../../bloc/trade/trade_state.dart';
import 'sell_btc_success_page.dart';

// Dark gradient fill for input/text boxes — keeps white text readable
// regardless of what's behind the (now-ungradiented) background photo.
const _kFieldGradient = LinearGradient(
  colors: [Color(0xFF1C1C2E), Color(0xFF0D0D18)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SellBtcReviewPage extends StatefulWidget {
  final double btcAmount;
  final double usdAmount;
  final String orderType;
  final double limitPrice;

  const SellBtcReviewPage({
    super.key,
    required this.btcAmount,
    required this.usdAmount,
    required this.orderType,
    required this.limitPrice,
  });

  @override
  State<SellBtcReviewPage> createState() => _SellBtcReviewPageState();
}

class _SellBtcReviewPageState extends State<SellBtcReviewPage> {
  late final TradeBloc _tradeBloc;

  double get fee => widget.usdAmount * 0.01;
  double get totalReceived => widget.usdAmount - fee;

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
                builder: (_) => SellBtcSuccessPage(
                  btcAmount: widget.btcAmount,
                  usdAmount: widget.usdAmount,
                  totalReceived: totalReceived,
                ),
              ),
            );
          } else if (state is TradeFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),

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

                      // Progress Indicator (Step 3 of 3 - All completed)
                      Row(
                        children: [
                          _buildProgressStep(true), // Step 1 completed
                          _buildProgressLine(true), // Line completed
                          _buildProgressStep(true), // Step 2 completed
                          _buildProgressLine(true), // Line completed
                          _buildProgressStep(true), // Step 3 current/completed
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

                        // Review Order Title
                        Text(
                          'Review Order',
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 18 : 20,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Order Details Container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: _kFieldGradient,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
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
                              _buildOrderDetailRow('Order Type', widget.orderType),
                              const SizedBox(height: 14),
                              // Divider
                              Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.14),
                              ),
                              const SizedBox(height: 14),
                              _buildOrderDetailRow(
                                'Subtotal',
                                '\$${widget.usdAmount.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 12),
                              _buildOrderDetailRow(
                                'Fee (1%)',
                                '-\$${fee.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 14),
                              // Total Received (highlighted)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Received',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '\$${totalReceived.toStringAsFixed(2)}',
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
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

                        // Warning Message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_outlined,
                                color: const Color(0xFFF59E0B),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'This transaction is subject to market conditions. Actual execution price may vary slightly.',
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
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

                // Confirm Sale Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<TradeBloc, TradeState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is TradeLoading
                              ? null
                              : () => _tradeBloc.add(
                                    SellCryptoRequested('BTC', widget.btcAmount),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state is TradeLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.black),
                                )
                              : Text(
                                  'Confirm Sale',
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        );
                      },
                    ),
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

  Widget _buildOrderDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
