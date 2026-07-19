import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/complete_onboarding.dart';
import '../../../domain/usecases/get_onboarding_status.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingStatus getOnboardingStatus;
  final CompleteOnboarding completeOnboarding;

  OnboardingBloc({
    required this.getOnboardingStatus,
    required this.completeOnboarding,
  }) : super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingCompleted>(_onCompleted);
  }

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      final completed = await getOnboardingStatus();
      if (completed) {
        emit(const OnboardingNotRequired());
      } else {
        emit(const OnboardingRequired());
      }
    } catch (e) {
      emit(OnboardingFailure(e.toString()));
    }
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      await completeOnboarding();
      emit(const OnboardingNotRequired());
    } catch (e) {
      emit(OnboardingFailure(e.toString()));
    }
  }
}
