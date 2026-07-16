import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle({required this.repository});

  Future<AuthUser> call() {
    return repository.signInWithGoogle();
  }
}
