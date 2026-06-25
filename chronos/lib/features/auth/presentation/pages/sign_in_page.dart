import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_di.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/theme/text_theme.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/auth_provider_marks.dart';
import '../widgets/glass_auth_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      context.go(RouteConstants.home.toPath);
    } else if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleState,
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Stack(
            children: [
              // Background
              Positioned.fill(
                child: Image.network(
                  'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : Container(color: const Color(0xFF0D1117)),
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0D1117)),
                ),
              ),
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
              SafeArea(
                child: Padding(
                  padding: Constants.paddingHorizontalMedium,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.canPop() 
                              ? context.pop() 
                              : context.go(RouteConstants.onboarding.toPath),
                          icon: const Icon(Icons.arrow_back_ios_new),
                          color: Colors.white,
                        ),
                      ),
                      Space.verticalMedium,
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Space.verticalSmall,
                      Text(
                        'Sign in to continue to Chronos Bank',
                        textAlign: TextAlign.center,
                        style: TextStyles.titleMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Space.verticalExtraLarge,
                      
                      GlassAuthButton(
                        label: 'Continue with phone number',
                        icon: Icons.phone_iphone,
                        onPressed: () => context.go(RouteConstants.phoneAuth.toPath),
                      ),
                      Space.verticalMedium,
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Colors.white24, thickness: 1),
                          ),
                          Padding(
                            padding: Constants.paddingHorizontalSmall,
                            child: Text(
                              'or',
                              style: TextStyles.labelLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Colors.white24, thickness: 1),
                          ),
                        ],
                      ),
                      Space.verticalMedium,
                      GlassAuthButton(
                        label: 'Continue with Google',
                        leading: const GoogleMark(),
                        onPressed: isLoading ? null : () {
                          context.read<AuthBloc>().add(GoogleSignInRequested());
                        },
                      ),
                      Space.verticalMedium,
                      GlassAuthButton(
                        label: 'Continue with Apple',
                        leading: const Icon(Icons.apple, color: Colors.white),
                        onPressed: null,
                      ),
                      Space.verticalMedium,
                      GlassAuthButton(
                        label: 'Continue with facebook',
                        leading: const FacebookMark(),
                        onPressed: null,
                      ),
                      Space.verticalLarge,
                     
                      Text(
                        "Don't have an account?",
                        textAlign: TextAlign.center,
                        style: TextStyles.titleMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Space.verticalSmall,
                      GestureDetector(
                        onTap: () => context.go(RouteConstants.signUp.toPath),
                        child: Text(
                          'Sign up',
                          textAlign: TextAlign.center,
                          style: TextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Space.verticalLarge,
                    ],
                  ),
                ),
              ),
              // Loading overlay
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class SignInRoute extends StatelessWidget {
  const SignInRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: const SignInPage(),
    );
  }
}
