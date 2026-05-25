import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/utils/error_toast.dart';
import '../../../../core/theme/preset_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/otp_input.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpStep = false;

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is ForgotPasswordOtpSent) {
      setState(() => _isOtpStep = true);
      _startTimer();
      ErrorToast.show(
        context,
        "Verification code has been sent to your email.",
        backgroundColor: Colors.green,
      );
    } else if (state is ForgotPasswordOtpVerified) {
      ErrorToast.show(
        context,
        "OTP verified successfully!",
        backgroundColor: Colors.green,
      );
      context.push(
        RouteConstants.resetPassword.toPath,
        extra: {'email': state.email, 'otp': state.otp},
      );
    } else if (state is AuthFailure) {
      ErrorToast.show(context, state.message);
    }
  }

  void _onSubmitEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        ForgotPasswordSubmitted(_emailController.text.trim()),
      );
    }
  }

  void _onVerifyOtp() {
    if (_otpController.text.length == 6) {
      context.read<AuthBloc>().add(
        ForgotPasswordOtpSubmitted(
          email: _emailController.text.trim(),
          otp: _otpController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleState,
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/background.png', fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: Constants.paddingHorizontalMedium,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () {
                                    if (_isOtpStep) {
                                      setState(() {
                                        _isOtpStep = false;
                                        _otpController.clear();
                                      });
                                      _timer?.cancel();
                                    } else {
                                      context.pop();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _isOtpStep ? 'Verification' : 'Forgot Password',
                                style: TextStyles.headlineLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Space.verticalSmall,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  _isOtpStep
                                      ? 'Please enter the 6-digit code sent to \n${_emailController.text}'
                                      : 'Don\'t worry! It happens. Please enter the email address associated with your account.',
                                  textAlign: TextAlign.center,
                                  style: TextStyles.bodyLarge.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              Space.verticalLarge,
                              if (!_isOtpStep) ...[
                                _buildTextField(
                                  controller: _emailController,
                                  hint: 'Enter your email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                Space.verticalLarge,
                                ElevatedButton(
                                  onPressed: isLoading ? null : _onSubmitEmail,
                                  child: const Text('Send Reset Code'),
                                ),
                                Space.verticalMedium,
                                Text(
                                  'Remember your password? Login instead',
                                  style: TextStyles.bodySmall.copyWith(
                                    color: Colors.white60,
                                  ),
                                ),
                              ] else ...[
                                OtpInput(
                                  length: 6,
                                  onCompleted:
                                      (otp) => setState(
                                        () => _otpController.text = otp,
                                      ),
                                ),
                                Space.verticalLarge,
                                ElevatedButton(
                                  onPressed: isLoading ? null : _onVerifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _otpController.text.length == 6
                                            ? CColor.primaryButton
                                            : Colors.white.withOpacity(0.1),
                                    foregroundColor:
                                        _otpController.text.length == 6
                                            ? Colors.white
                                            : Colors.white38,
                                  ),
                                  child: const Text('Verify Code'),
                                ),
                                Space.verticalLarge,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Didn't receive code? ",
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          _canResend ? _onSubmitEmail : null,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Text(
                                        _canResend
                                            ? 'Resend now'
                                            : 'Resend in ${_formatTime(_secondsRemaining)}',
                                        style: TextStyle(
                                          color:
                                              _canResend
                                                  ? Colors.white
                                                  : Colors.white60,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const Spacer(flex: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
