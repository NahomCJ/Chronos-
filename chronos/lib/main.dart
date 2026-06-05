import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';

import 'core/di/app_di.dart';
import 'core/router/app_route.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init is platform-dependent. On native, we have generated
  // FirebaseOptions; on web they need a separate setup. We never let a Firebase
  // failure crash the whole app — we surface a debug log and continue so the UI
  // still renders (and platform-specific features simply degrade gracefully).
  try {
    if (kIsWeb) {
      // Firebase web config not set — skipped gracefully, app still loads.
      // Add your web Firebase config here when ready.
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, st) {
    debugPrint('Firebase initialization skipped or failed: $e');
    debugPrintStack(stackTrace: st);
  }

  await initAppDi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => sl<ThemeCubit>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
