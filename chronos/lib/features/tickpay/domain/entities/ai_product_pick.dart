import 'package:equatable/equatable.dart';

/// An AI-recommended product surfaced in the dashboard "AI Picks for You"
/// carousel.
class AiProductPick extends Equatable {
  final String title;
  final String imageAsset;
  final double price;
  final String trendBadge;
  final bool isBnplEligible;

  const AiProductPick({
    required this.title,
    required this.imageAsset,
    required this.price,
    required this.trendBadge,
    this.isBnplEligible = false,
  });

  @override
  List<Object?> get props =>
      [title, imageAsset, price, trendBadge, isBnplEligible];
}
