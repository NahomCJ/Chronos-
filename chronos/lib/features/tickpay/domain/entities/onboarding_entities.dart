import 'package:equatable/equatable.dart';

/// A payment method the user can link during onboarding
/// (Link Your Wallets screen).
class WalletOption extends Equatable {
  final String id;
  final String title;
  final String iconAsset;
  final bool isRecommended;

  const WalletOption({
    required this.id,
    required this.title,
    required this.iconAsset,
    this.isRecommended = false,
  });

  @override
  List<Object?> get props => [id, title, iconAsset, isRecommended];
}

/// A single step in the KYC / verification timeline
/// (Verification Status screen).
class VerificationStep extends Equatable {
  final String title;
  final String subtitle;
  final bool isCompleted;

  const VerificationStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [title, subtitle, isCompleted];
}

/// A "What's next" highlight shown on the completion screen.
class OnboardingHighlight extends Equatable {
  final String iconAsset;
  final String title;
  final String subtitle;

  const OnboardingHighlight({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  List<Object?> get props => [iconAsset, title, subtitle];
}
