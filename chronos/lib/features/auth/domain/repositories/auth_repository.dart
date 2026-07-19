import '../entities/auth_user.dart';
import '../entities/login_result.dart';

abstract class AuthRepository {
  Future<AuthUser> signInWithGoogle();
  Future<void> signOut();

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
    required Function(String) onVerificationCompleted,
    required Function() onCodeAutoRetrievalTimeout,
  });

  Future<AuthUser> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  });

  Future<AuthSession> login(String email, String password);
  Future<AuthSession> register(String email, String password, String name);

  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}
