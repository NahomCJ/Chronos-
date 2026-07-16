import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthRemoteDataSourceImpl {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  FirebaseAuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider()..addScope('email');
      return await firebaseAuth.signInWithPopup(provider);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
    } catch (_) {
      await firebaseAuth.signOut();
    }
  }

  // Phone number authentication methods
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String) onVerificationCompleted,
    required Function() onCodeAutoRetrievalTimeout,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        onVerificationCompleted(credential.verificationId ?? '');
      },
      verificationFailed: (FirebaseAuthException exception) {
        onVerificationFailed(exception);
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        onCodeAutoRetrievalTimeout();
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential?> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final authResult = await firebaseAuth.signInWithCredential(credential);
      return authResult;
    } on FirebaseAuthException catch (e) {
      // Handle common errors
      if (e.code == 'invalid-verification-code') {
        // Invalid SMS code
      } else if (e.code == 'invalid-verification-id') {
        // Invalid verification ID
      } else if (e.code == 'session-expired') {
        // Verification session expired
      }
      return null;
    } catch (_) {
      // Any other errors
      return null;
    }
  }
}
