import 'package:equatable/equatable.dart';

/// A Buy-Now-Pay-Later installment plan. Drives both the compact dashboard
/// "Active Plans" tiles and the detailed Active Plans screen cards.
class InstallmentPlan extends Equatable {
  final String id;
  final String merchant;

  /// Short order reference shown on the dashboard (e.g. `#9012`).
  final String reference;
  final String logoAsset;
  final String category;
  final double totalAmount;
  final int paymentsMade;
  final int paymentsTotal;
  final double paidAmount;
  final double remainingAmount;
  final String nextPaymentDate;
  final double nextPaymentAmount;
  final bool isDueSoon;

  const InstallmentPlan({
    required this.id,
    required this.merchant,
    this.reference = '',
    required this.logoAsset,
    required this.category,
    required this.totalAmount,
    required this.paymentsMade,
    required this.paymentsTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.nextPaymentDate,
    required this.nextPaymentAmount,
    this.isDueSoon = false,
  });

  /// Completion progress as a fraction (0..1).
  double get progress =>
      paymentsTotal == 0 ? 0 : paymentsMade / paymentsTotal;

  /// Whole-number completion percentage.
  int get progressPercent => (progress * 100).round();

  int get paymentsLeft => paymentsTotal - paymentsMade;

  @override
  List<Object?> get props => [
        id,
        merchant,
        reference,
        logoAsset,
        category,
        totalAmount,
        paymentsMade,
        paymentsTotal,
        paidAmount,
        remainingAmount,
        nextPaymentDate,
        nextPaymentAmount,
        isDueSoon,
      ];
}
