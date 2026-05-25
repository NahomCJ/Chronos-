import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../data/data_source/onboarding_local_data_source.dart';
import '../data/data_source/firebase_auth_remote_data_source.dart';
import '../data/data_source/auth_remote_data_source.dart';
import '../data/data_source/http_auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/onboarding_repository_impl.dart';
import '../data/services/token_storage_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/onboarding_repository.dart';
import '../domain/usecases/sign_in_with_google.dart';
import '../domain/usecases/sign_in_with_phone_credential.dart';
import '../domain/usecases/sign_out.dart';
import '../domain/usecases/complete_onboarding.dart';
import '../domain/usecases/get_onboarding_status.dart';
import '../domain/usecases/verify_phone_number.dart';
import '../domain/usecases/login.dart';
import '../domain/usecases/forgot_password.dart';
import '../domain/usecases/reset_password.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/onboarding/onboarding_bloc.dart';
import '../../../core/network/api_client.dart';

Future<void> initAuthDi(GetIt sl) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton<http.Client>(() => http.Client());
  }

  if (!kIsWeb) {
    if (!sl.isRegistered<FirebaseAuth>()) {
      sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    }

    final googleSignIn = GoogleSignIn.instance;
    if (!sl.isRegistered<GoogleSignIn>()) {
      sl.registerLazySingleton<GoogleSignIn>(() => googleSignIn);
    }
  }

  if (!sl.isRegistered<TokenStorageService>()) {
    sl.registerLazySingleton<TokenStorageService>(
      () => TokenStorageService(sl()),
    );
  }

  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(client: sl(), tokenStorage: sl()),
    );
  }

  if (!kIsWeb && !sl.isRegistered<FirebaseAuthRemoteDataSourceImpl>()) {
    sl.registerLazySingleton<FirebaseAuthRemoteDataSourceImpl>(
      () => FirebaseAuthRemoteDataSourceImpl(
        firebaseAuth: sl(),
        googleSignIn: sl(),
      ),
    );
  }

  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => HttpAuthRemoteDataSource(client: sl()),
    );
  }

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        firebaseDataSource: kIsWeb ? null : sl(),
        remoteDataSource: sl(),
      ),
    );
  }

  if (!sl.isRegistered<LoginUseCase>()) {
    sl.registerLazySingleton(() => LoginUseCase(sl()));
  }
  if (!sl.isRegistered<SignInWithGoogle>()) {
    sl.registerLazySingleton(() => SignInWithGoogle(repository: sl()));
  }
  if (!sl.isRegistered<SignOut>()) {
    sl.registerLazySingleton(() => SignOut(repository: sl()));
  }
  if (!sl.isRegistered<VerifyPhoneNumber>()) {
    sl.registerLazySingleton(() => VerifyPhoneNumber(repository: sl()));
  }
  if (!sl.isRegistered<SignInWithPhoneCredential>()) {
    sl.registerLazySingleton(
        () => SignInWithPhoneCredential(repository: sl()));
  }
  if (!sl.isRegistered<ForgotPasswordUseCase>()) {
    sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  }
  if (!sl.isRegistered<ResetPasswordUseCase>()) {
    sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  }

  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(
        signInWithGoogle: sl(),
        signOut: sl(),
        verifyPhoneNumber: sl(),
        signInWithPhoneCredential: sl(),
        loginUseCase: sl(),
        forgotPasswordUseCase: sl(),
        resetPasswordUseCase: sl(),
        tokenStorage: sl(),
      ),
    );
  }

  if (!sl.isRegistered<OnboardingLocalDataSourceImpl>()) {
    sl.registerLazySingleton<OnboardingLocalDataSourceImpl>(
      () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
    );
  }

  if (!sl.isRegistered<OnboardingRepository>()) {
    sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(localDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GetOnboardingStatus>()) {
    sl.registerLazySingleton<GetOnboardingStatus>(
      () => GetOnboardingStatus(repository: sl()),
    );
  }

  if (!sl.isRegistered<CompleteOnboarding>()) {
    sl.registerLazySingleton<CompleteOnboarding>(
      () => CompleteOnboarding(repository: sl()),
    );
  }

  if (!sl.isRegistered<OnboardingBloc>()) {
    sl.registerFactory<OnboardingBloc>(
      () => OnboardingBloc(
          getOnboardingStatus: sl(), completeOnboarding: sl()),
    );
  }
}
