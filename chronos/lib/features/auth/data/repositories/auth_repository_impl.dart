import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_source/auth_remote_data_source.dart';
import '../data_source/firebase_auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthRemoteDataSourceImpl? firebaseDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    this.firebaseDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<AuthUser> signInWithGoogle() async {
    if (firebaseDataSource == null) {
      throw Exception('Google sign-in is not available on this platform.');
    }
    final credential = await firebaseDataSource!.signInWithGoogle();
    final user = credential?.user;
    if (user == null) {
      throw Exception('Firebase user is null after Google sign-in.');
    }
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> signOut() async {
    await firebaseDataSource?.signOut();
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
    required Function(String) onVerificationCompleted,
    required Function() onCodeAutoRetrievalTimeout,
  }) {
    if (firebaseDataSource == null) {
      return Future.error('Phone auth is not available on this platform.');
    }
    return firebaseDataSource!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: (e) =>
          onVerificationFailed(e.message ?? 'Verification failed'),
      onVerificationCompleted: onVerificationCompleted,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  @override
  Future<AuthUser> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    if (firebaseDataSource == null) {
      throw Exception('Phone sign-in is not available on this platform.');
    }
    final credential = await firebaseDataSource!.signInWithPhoneCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final user = credential?.user;
    if (user == null) {
      throw Exception('Firebase user is null after phone sign-in.');
    }
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<AuthSession> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    return response.toEntity();
  }

  @override
  Future<AuthSession> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await remoteDataSource.register(email, password, name);
    return response.toEntity();
  }

  @override
  Future<void> forgotPassword(String email) =>
      remoteDataSource.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) =>
      remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
}
