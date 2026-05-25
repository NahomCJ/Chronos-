import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class PhoneVerificationRequested extends AuthEvent {
  final String phoneNumber;
  const PhoneVerificationRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneCodeVerificationRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;
  const PhoneCodeVerificationRequested(this.verificationId, this.smsCode);

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;
  const ForgotPasswordSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordOtpSubmitted extends AuthEvent {
  final String email;
  final String otp;
  const ForgotPasswordOtpSubmitted({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;
  const ResetPasswordSubmitted({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, otp, newPassword, confirmPassword];
}
