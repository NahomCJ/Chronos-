import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../data/services/token_storage_service.dart';
import '../bloc/onboarding/onboarding_bloc.dart';
import '../bloc/onboarding/onboarding_event.dart';
import '../bloc/onboarding/onboarding_state.dart';

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
    context.read<OnboardingBloc>().add(const OnboardingStarted());
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _delayDone = true;
      if (_targetLocation != null) {
        _go(_targetLocation!);
      }
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
          if (_delayDone) {
            _go(_targetLocation!);
          }
        } else if (state is OnboardingNotRequired) {
          final hasToken = sl<TokenStorageService>().hasToken;
          _targetLocation = hasToken
              ? RouteConstants.home.toPath
              : RouteConstants.signIn.toPath;
          if (_delayDone) {
            _go(_targetLocation!);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image.asset(
            'assets/splash_img.png',
            fit: BoxFit.contain,
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
