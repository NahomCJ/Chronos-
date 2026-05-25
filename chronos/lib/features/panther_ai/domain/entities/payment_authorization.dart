class CashFlowWarning {
  final bool isRisky;
  final String riskLevel;
  final String warningMessage;
  final double projectedBalance;

  const CashFlowWarning({
    required this.isRisky,
    required this.riskLevel,
    required this.warningMessage,
    required this.projectedBalance,
  });
}

class PaymentAuthorization {
  final String authorizationId;
  final String status;
  final CashFlowWarning? cashFlow;
  final String combinedMessage;

  const PaymentAuthorization({
    required this.authorizationId,
    required this.status,
    this.cashFlow,
    required this.combinedMessage,
  });

  bool get isSafe => cashFlow == null || !cashFlow!.isRisky;
}
