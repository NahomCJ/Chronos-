import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/glass_auth_button.dart';
import '../widgets/otp_input_widget.dart';
import '../widgets/phone_input_widget.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  bool _isOtpSent = false;
  String _verificationId = '';
  Country _selectedCountry = CountryParser.parseCountryCode('ET');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      context.go(RouteConstants.home.toPath);
    } else if (state is PhoneCodeSent) {
      setState(() {
        _isOtpSent = true;
        _verificationId = state.verificationId;
      });
    } else if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    } else if (state is PhoneVerificationFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

void _onSendOtp() {
  final input = _phoneController.text.trim();

  if (input.isEmpty) return;

  if (!PhoneFormatter.isValid(input)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a valid phone number'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final phoneNumber = PhoneFormatter.toE164(
    input,
    _selectedCountry,
  );

  context.read<AuthBloc>().add(
    PhoneVerificationRequested(phoneNumber),
  );
}


  void _onVerifyOtp(String otp) {
    if (otp.length == 6 && _verificationId.isNotEmpty) {
      context.read<AuthBloc>().add(
        PhoneCodeVerificationRequested(_verificationId, otp),
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
          resizeToAvoidBottomInset: true,
          body: SizedBox.expand(
            child: Stack(
              children: [
              // Background
              Positioned.fill(
                child: Image.network(
                  'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : Container(color: const Color(0xFF0D1117)),
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0D1117)),
                ),
              ),
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
              // Content
              SafeArea(
                child: Padding(
                  padding: Constants.paddingHorizontalMedium,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(RouteConstants.signUp.toPath);
                              }
                            },
                            icon: const Icon(Icons.arrow_back_ios_new),
                            color: Colors.white,
                          ),
                        ),
                        Space.verticalMedium,
                        Text(
                          _isOtpSent ? 'Verify Your Phone' : 'Enter Your Phone',
                          textAlign: TextAlign.center,
                          style: TextStyles.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Space.verticalSmall,
                        Text(
                          _isOtpSent
                              ? 'Enter the 6-digit code sent to your phone'
                              : 'We will send you a verification code',
                          textAlign: TextAlign.center,
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Space.verticalExtraLarge,
                        if (!_isOtpSent) ...[
                          PhoneInputWidget(
                            controller: _phoneController,
                            labelText: 'Phone Number',
                            hintText: 'Enter phone number',
                            selectedCountry: _selectedCountry,
                            onCountryChanged: (Country country) {
                              setState(() {
                                _selectedCountry = country;
                              });
                            },
                            onSubmitted: () => _onSendOtp(),
                          ),
                          Space.verticalLarge,
                          GlassAuthButton(
                            label: 'Send Code',
                            icon: Icons.send,
                            onPressed: isLoading ? null : _onSendOtp,
                          ),
                        ] else ...[
                          OtpInputWidget(
                            onCompleted: _onVerifyOtp,
                            labelText: 'Verification Code',
                          ),
                          Space.verticalLarge,
                          GlassAuthButton(
                            label: 'Verify Code',
                            icon: Icons.check_circle,
                            onPressed: isLoading ? null : () {},
                          ),
                          Space.verticalMedium,
                          TextButton(
                            onPressed: isLoading ? null : _onSendOtp,
                            child: Text(
                              'Resend Code',
                              style: TextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                        Space.verticalExtraLarge,
                        if (_isOtpSent) ...[
                          TextButton(
                            onPressed: isLoading ? null : () {
                              setState(() {
                                _isOtpSent = false;
                                _verificationId = '';
                              });
                            },
                            child: Text(
                              'Change Phone Number',
                              style: TextStyles.titleMedium.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Loading overlay
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
          ),
        );
      },
    );
  }
}

class PhoneAuthRoute extends StatelessWidget {
  const PhoneAuthRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: const PhoneAuthPage(),
    );
  }
}
