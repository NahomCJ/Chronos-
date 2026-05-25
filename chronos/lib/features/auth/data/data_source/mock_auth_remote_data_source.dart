import 'auth_remote_data_source.dart';
import '../models/auth_response_model.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<LoginResponseModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'john.doe@gmail.com' && password == 'password') {
      return LoginResponseModel(
        user: UserDataModel(
          id: 'mock-user-1',
          email: email,
          firstName: 'John',
          lastName: 'Doe',
          role: 'USER',
        ),
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
      );
    }
    throw Exception('Invalid credentials. Please try again.');
  }

  @override
  Future<LoginResponseModel> register(
    String email,
    String password,
    String name,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    final parts = name.split(' ');
    return LoginResponseModel(
      user: UserDataModel(
        id: 'mock-user-new',
        email: email,
        firstName: parts.isNotEmpty ? parts.first : name,
        lastName: parts.length > 1 ? parts.last : '',
        role: 'USER',
      ),
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp != '123456') throw Exception('Invalid OTP code. Please try again.');
  }
}
