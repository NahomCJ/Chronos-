import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthSession> call(String email, String password) =>
      repository.login(email, password);
}
