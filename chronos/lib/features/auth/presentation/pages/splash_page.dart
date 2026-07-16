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

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  bool _navigated = false;
  bool _delayDone = false;
  String? _targetLocation;

  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.6)),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(-0.6, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );

    // Sequence: logo pops in, then text slides out from it
    _logoCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _textCtrl.forward();
      });
    });

    context.read<OnboardingBloc>().add(const OnboardingStarted());
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      _delayDone = true;
      if (_targetLocation != null) _go(_targetLocation!);
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
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
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_logoCtrl, _textCtrl]),
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // C logo  scales + fades in
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: Image.asset(
                        'assets/Chronoslogo-icon-black.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // "hronos" slides out from the C
                  ClipRect(
                    child: SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            'hronos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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
