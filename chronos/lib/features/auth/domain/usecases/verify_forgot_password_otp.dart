// OTP verify endpoint removed  OTP is validated server-side via reset-password.
// This stub is kept to avoid breaking any remaining references during cleanup.
class VerifyForgotPasswordOtpUseCase {
  Future<void> call({required String email, required String otp}) async {
    throw UnimplementedError('Server-side OTP verification not needed');
  }
}
