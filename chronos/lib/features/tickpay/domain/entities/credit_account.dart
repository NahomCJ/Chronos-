import 'package:equatable/equatable.dart';

/// Snapshot of the user's TickPay credit line, powering the dashboard
/// summary card and the Credit Overview screen.
class CreditAccount extends Equatable {
  final double availableCredit;
  final double creditLimit;
  final double creditUsed;
  final double activePlansAmount;
  final double pendingChargesAmount;

  const CreditAccount({
    required this.availableCredit,
    required this.creditLimit,
    required this.creditUsed,
    required this.activePlansAmount,
    required this.pendingChargesAmount,
  });

  /// Fraction (0..1) of the credit line that is currently used.
  double get utilization => creditLimit == 0 ? 0 : creditUsed / creditLimit;

  /// Active plans as a fraction (0..1) of the total limit.
  double get activePlansFraction =>
      creditLimit == 0 ? 0 : activePlansAmount / creditLimit;

  /// Pending charges as a fraction (0..1) of the total limit.
  double get pendingChargesFraction =>
      creditLimit == 0 ? 0 : pendingChargesAmount / creditLimit;

  @override
  List<Object?> get props => [
        availableCredit,
        creditLimit,
        creditUsed,
        activePlansAmount,
        pendingChargesAmount,
      ];
}

/// A line item in the Credit Overview "Recent Activity" list.
class CreditActivity extends Equatable {
  final String merchant;
  final String date;
  final String category;
  final double amount;

  /// `true` for incoming money (payment received), `false` for a charge.
  final bool isCredit;

  const CreditActivity({
    required this.merchant,
    required this.date,
    required this.category,
    required this.amount,
    required this.isCredit,
  });

  @override
  List<Object?> get props => [merchant, date, category, amount, isCredit];
}
