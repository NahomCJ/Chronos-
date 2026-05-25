import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithPhoneCredential {
  final AuthRepository repository;

  SignInWithPhoneCredential({required this.repository});

  Future<AuthUser> call({
    required String verificationId,
    required String smsCode,
  }) {
    return repository.signInWithPhoneCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
