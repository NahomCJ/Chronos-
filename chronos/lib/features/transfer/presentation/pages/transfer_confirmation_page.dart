import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/preset_colors.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';

class TransferConfirmationPage extends StatefulWidget {
  final String amount;
  final String recipientName;
  final String method;

  const TransferConfirmationPage({
    super.key,
    required this.amount,
    this.recipientName = "Alex Johnson",
    this.method = "Chronos User",
  });

  @override
  State<TransferConfirmationPage> createState() =>
      _TransferConfirmationPageState();
}

class _TransferConfirmationPageState extends State<TransferConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  final LocalAuthentication auth = LocalAuthentication();
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool isSupported = await auth.isDeviceSupported();
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      if (!canAuthenticateWithBiometrics ||
          !isSupported ||
          availableBiometrics.isEmpty) {
        _navigateToPinEntry();
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to complete the transfer',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        _handleSuccess();
      } else {
        _navigateToPinEntry();
      }
    } catch (e) {
      _navigateToPinEntry();
    }
  }

  void _navigateToPinEntry() {
    context.push(RouteConstants.pinEntry.toPath);
  }

  void _handleSuccess() {
    if (_isSuccess) return;
    setState(() => _isSuccess = true);
    context.read<TransferBloc>().add(TransferSubmitted(
          amount: double.tryParse(widget.amount) ?? 0.0,
          recipientName: widget.recipientName,
          method: widget.method,
        ));
    // Navigation happens via BlocListener on TransferSuccess/Failure
  }

  void _onConfirmLongPressStart(LongPressStartDetails details) {
    if (_isSuccess) return;
    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isSuccess) {
        _authenticate();
      }
    });
  }

  void _onConfirmLongPressEnd(LongPressEndDetails details) {
    if (_isSuccess) return;
    if (!_progressController.isCompleted) {
      _progressController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state is TransferSuccess) {
          context.go(
            RouteConstants.transferSuccess.toPath,
            extra: {
              'amount': widget.amount,
              'recipientName': widget.recipientName,
              'method': widget.method,
            },
          );
        } else if (state is TransferFailure) {
          setState(() => _isSuccess = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scale = size.width / 390;
    final double textScale = math.min(scale, 1.1);
    final isShortScreen = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A))),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _buildAppBar(context, scale, textScale),
                          SizedBox(height: (isShortScreen ? 10 : 20) * scale),
                          _buildSendingHeader(scale, textScale),
                          SizedBox(height: (isShortScreen ? 16 : 24) * scale),
                          _buildTransferDetails(scale, textScale),
                          SizedBox(height: 16 * scale),
                          _buildSummaryCard(scale, textScale),
                          const Spacer(),
                          SizedBox(height: 24 * scale),
                          SizedBox(
                            width: double.infinity,
                            height: 54 * scale,
                            child: ElevatedButton(
                              onPressed: _isSuccess ? null : _authenticate,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12 * scale,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16 * textScale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: Colors.orangeAccent,
                                size: 16 * scale,
                              ),
                              SizedBox(width: 8 * scale),
                              Text(
                                'Secured with 256-bit encryption',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12 * textScale,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: (isShortScreen ? 16 : 24) * scale),
                          _buildBiometricButton(scale, textScale),
                          SizedBox(height: 20 * scale),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double scale, double textScale) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24 * scale),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Confirmation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20 * textScale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 48 * scale),
      ],
    );
  }

  Widget _buildSendingHeader(double scale, double textScale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            'You\'re sending',
            style: TextStyle(color: Colors.white70, fontSize: 14 * textScale),
          ),
          SizedBox(height: 8 * scale),
          Text(
            '\$${widget.amount}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36 * textScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14 * textScale,
                ),
              ),
              SizedBox(width: 4 * scale),
              Icon(
                Icons.edit_outlined,
                color: Colors.greenAccent,
                size: 16 * scale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransferDetails(double scale, double textScale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _buildDetailRow('From', 'Main Account', 'M', scale, textScale),
          Divider(color: Colors.white12, height: 24 * scale),
          _buildDetailRow(
            'To',
            widget.recipientName,
            widget.recipientName.isNotEmpty ? widget.recipientName[0] : '?',
            scale,
            textScale,
            subtitle: '+1 234 567 8900',
          ),
          Divider(color: Colors.white12, height: 24 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14 * textScale,
                ),
              ),
              Text(
                'Instant',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * textScale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    String initial,
    double scale,
    double textScale, {
    String? subtitle,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 50 * scale,
          child: Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 14 * textScale),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14 * textScale,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11 * textScale,
                ),
              ),
          ],
        ),
        SizedBox(width: 12 * scale),
        Container(
          width: 32 * scale,
          height: 32 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white24),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12 * textScale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(double scale, double textScale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14 * textScale,
                ),
              ),
              Text(
                'USD ${widget.amount}',
                style: TextStyle(color: Colors.white, fontSize: 14 * textScale),
              ),
            ],
          ),
          Divider(color: Colors.white12, height: 24 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fee',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14 * textScale,
                ),
              ),
              Text(
                'Free',
                style: TextStyle(color: Colors.white, fontSize: 14 * textScale),
              ),
            ],
          ),
          Divider(color: Colors.white12, height: 24 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * textScale,
                ),
              ),
              Text(
                'USD ${widget.amount}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * textScale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricButton(double scale, double textScale) {
    return GestureDetector(
      onLongPressStart: _onConfirmLongPressStart,
      onLongPressEnd: _onConfirmLongPressEnd,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 54 * scale,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: Colors.white24),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: _progressController.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CColor.primaryButton.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.fingerprint,
                        color: _isSuccess ? Colors.greenAccent : Colors.white,
                        size: 24 * scale,
                      ),
                      SizedBox(width: 12 * scale),
                      Text(
                        _isSuccess ? 'Verified' : 'Hold To Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * textScale,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
