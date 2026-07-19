import '../repositories/auth_repository.dart';

class VerifyPhoneNumber {
  final AuthRepository repository;

  VerifyPhoneNumber({required this.repository});

  Future<void> call({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
    required Function(String) onVerificationCompleted,
    required Function() onCodeAutoRetrievalTimeout,
  }) {
    return repository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: onVerificationFailed,
      onVerificationCompleted: onVerificationCompleted,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }
}
