import 'package:equatable/equatable.dart';

/// Top-of-screen rewards balance (points + cashback) on the Rewards screen.
class RewardSummary extends Equatable {
  final int points;
  final double pointsValue;
  final double cashback;
  final String tier;

  const RewardSummary({
    required this.points,
    required this.pointsValue,
    required this.cashback,
    required this.tier,
  });

  @override
  List<Object?> get props => [points, pointsValue, cashback, tier];
}

/// An active rewards campaign with a progress goal.
class RewardCampaign extends Equatable {
  final String title;
  final String description;
  final int progressCurrent;
  final int progressTotal;
  final String pointsToGo;

  const RewardCampaign({
    required this.title,
    required this.description,
    required this.progressCurrent,
    required this.progressTotal,
    required this.pointsToGo,
  });

  double get progress =>
      progressTotal == 0 ? 0 : progressCurrent / progressTotal;

  @override
  List<Object?> get props =>
      [title, description, progressCurrent, progressTotal, pointsToGo];
}

/// A row in the Rewards "Recent Activity" list. Positive [points] earned,
/// negative redeemed.
class RewardActivity extends Equatable {
  final String title;
  final String date;
  final int points;

  const RewardActivity({
    required this.title,
    required this.date,
    required this.points,
  });

  @override
  List<Object?> get props => [title, date, points];
}
