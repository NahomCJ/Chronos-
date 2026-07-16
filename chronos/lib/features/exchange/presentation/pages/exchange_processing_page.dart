import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/router/route_constants.dart';

class ExchangeProcessingPage extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;
  final String fromAmount;
  final String toAmount;
  final String fromFlag;
  final String toFlag;

  const ExchangeProcessingPage({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.fromFlag,
    required this.toFlag,
  });

  @override
  State<ExchangeProcessingPage> createState() => _ExchangeProcessingPageState();
}

class _ExchangeProcessingPageState extends State<ExchangeProcessingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat();
    _processExchange();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _processExchange() async {
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      context.pushReplacement(
        RouteConstants.exchangeSuccess.toPath,
        extra: {
          'fromCurrency': widget.fromCurrency,
          'toCurrency': widget.toCurrency,
          'fromAmount': widget.fromAmount,
          'toAmount': widget.toAmount,
          'fromFlag': widget.fromFlag,
          'toFlag': widget.toFlag,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A))),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
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
                        ),
                      ),
                    ],
                  ),
                ),

                // Processing Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading Indicator
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CircularProgressIndicator(
                              value: _animation.value,
                              strokeWidth: 4,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF10B981),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Processing Title
                      Text(
                        'Processing...',
                        style: TextStyles.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Processing Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Please Wait while we process your deposit...',
                          style: TextStyles.bodyLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
