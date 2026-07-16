import '../../domain/entities/affordability_result.dart';

abstract class AffordabilityState {
  const AffordabilityState();
}

class AffordabilityInitial extends AffordabilityState {
  const AffordabilityInitial();
}

class AffordabilityLoading extends AffordabilityState {
  const AffordabilityLoading();
}

class AffordabilityLoaded extends AffordabilityState {
  final AffordabilityResult result;
  const AffordabilityLoaded(this.result);
}

class AffordabilityError extends AffordabilityState {
  final String message;
  const AffordabilityError(this.message);
}
