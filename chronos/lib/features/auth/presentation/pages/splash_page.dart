import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../data/services/token_storage_service.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import '../bloc/onboarding/onboarding_event.dart';
import '../bloc/onboarding/onboarding_state.dart';

const _splashSystemUiStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.black,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.black,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarDividerColor: Colors.black,
);

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _navigated = false;
  bool _delayDone = false;
  String? _targetLocation;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(_splashSystemUiStyle);

    context.read<OnboardingBloc>().add(const OnboardingStarted());
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _delayDone = true;
      if (_targetLocation != null) _go(_targetLocation!);
    });
  }

  void _go(String location) {
    if (_navigated) return;
    _navigated = true;
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingRequired) {
          _targetLocation = RouteConstants.onboarding.toPath;
          if (_delayDone) _go(_targetLocation!);
        } else if (state is OnboardingNotRequired) {
          final hasToken = sl<TokenStorageService>().hasToken;
          _targetLocation = hasToken
              ? RouteConstants.home.toPath
              : RouteConstants.signIn.toPath;
          if (_delayDone) _go(_targetLocation!);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _splashSystemUiStyle,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox.expand(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: Image.asset(
                  'assets/chronos_splash.jpg',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplashRoute extends StatelessWidget {
  const SplashRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => sl<OnboardingBloc>(),
      child: const SplashPage(),
    );
  }
}
