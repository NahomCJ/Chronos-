import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/token_storage_service.dart';
import '../../../domain/usecases/login.dart';
import '../../../domain/usecases/sign_in_with_google.dart';
import '../../../domain/usecases/sign_in_with_phone_credential.dart';
import '../../../domain/usecases/sign_out.dart';
import '../../../domain/usecases/verify_phone_number.dart';
import '../../../domain/usecases/forgot_password.dart';
import '../../../domain/usecases/reset_password.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final VerifyPhoneNumber verifyPhoneNumber;
  final SignInWithPhoneCredential signInWithPhoneCredential;
  final LoginUseCase loginUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final TokenStorageService tokenStorage;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signOut,
    required this.verifyPhoneNumber,
    required this.signInWithPhoneCredential,
    required this.loginUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.tokenStorage,
  }) : super(const AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PhoneVerificationRequested>(_onPhoneVerificationRequested);
    on<PhoneCodeVerificationRequested>(_onPhoneCodeVerificationRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<ForgotPasswordOtpSubmitted>(_onForgotPasswordOtpSubmitted);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithGoogle();
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await signOut();
      await tokenStorage.clearTokens();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onPhoneVerificationRequested(
    PhoneVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final completer = Completer<void>();
    String? verificationId;
    String? errorMessage;

    try {
      await verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        onCodeSent: (id) {
          verificationId = id;
          completer.complete();
        },
        onVerificationFailed: (error) {
          errorMessage = error;
          completer.complete();
        },
        onVerificationCompleted: (id) {
          verificationId = id;
          completer.complete();
        },
        onCodeAutoRetrievalTimeout: () {},
      );
      await completer.future;
      if (verificationId != null) {
        emit(PhoneCodeSent(verificationId: verificationId!));
      } else if (errorMessage != null) {
        emit(PhoneVerificationFailed(message: errorMessage!));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onPhoneCodeVerificationRequested(
    PhoneCodeVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithPhoneCredential(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final session = await loginUseCase(event.email, event.password);
      await tokenStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        userId: session.userId,
      );
      emit(AuthAuthenticated(session: session));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await forgotPasswordUseCase(event.email);
      emit(ForgotPasswordOtpSent(event.email));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onForgotPasswordOtpSubmitted(
    ForgotPasswordOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // No network call  OTP is validated by the server on reset
    emit(ForgotPasswordOtpVerified(email: event.email, otp: event.otp));
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await resetPasswordUseCase(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
      );
      emit(const PasswordResetSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
