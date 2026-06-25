import '../entities/login_result.dart';

// OTP login flow removed  backend uses single-step authentication.
// This stub is kept to avoid breaking any remaining references during cleanup.
class VerifyOtpUseCase {
  Future<AuthSession> call(String userId, String otp) async {
    throw UnimplementedError('OTP login is no longer supported');
  }
}
