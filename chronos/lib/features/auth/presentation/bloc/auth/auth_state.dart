import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth_user.dart';
import '../../../domain/entities/login_result.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser? user;
  final AuthSession? session;
  const AuthAuthenticated({this.user, this.session});

  @override
  List<Object?> get props => [user, session];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class PhoneCodeSent extends AuthState {
  final String verificationId;
  const PhoneCodeSent({required this.verificationId});

  @override
  List<Object?> get props => [verificationId];
}

class PhoneVerificationFailed extends AuthState {
  final String message;
  const PhoneVerificationFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordOtpSent extends AuthState {
  final String email;
  const ForgotPasswordOtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordOtpVerified extends AuthState {
  final String email;
  final String otp;
  const ForgotPasswordOtpVerified({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}
