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

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      context.go(RouteConstants.home.toPath);
    }
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
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
              Positioned.fill(
                child: Image.asset(
                  'assets/auth_bg_img.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: Constants.paddingHorizontalMedium,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new),
                          color: Colors.white,
                        ),
                      ),
                      Space.verticalMedium,
                      Text(
                        'Create Your Chronos\nAccount',
                        textAlign: TextAlign.center,
                        style: TextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Space.verticalSmall,
                      Text(
                        'Start with phone signup',
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
                                color: Colors.white.withOpacity(0.9),
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
                        label: 'Sign up with Apple',
                        leading: const Icon(Icons.apple, color: Colors.white),
                        onPressed: null,
                      ),
                      Space.verticalSmall,
                      GlassAuthButton(
                        label: 'Sign up with Google',
                        leading: const GoogleMark(),
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const GoogleSignInRequested());
                        },
                      ),
                      Space.verticalSmall,
                      GlassAuthButton(
                        label: 'Sign up with facebook',
                        leading: const FacebookMark(),
                        onPressed: null,
                      ),
                      Space.verticalSmall,
                      Padding(
                        padding: Constants.paddingVerticalMedium,
                        child: GestureDetector(
                          onTap: () => context.go(RouteConstants.home.toPath),
                          child: Text(
                            'Already have an account? Login here',
                            style: TextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class SignUpRoute extends StatelessWidget {
  const SignUpRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: const SignUpPage(),
    );
  }
}
