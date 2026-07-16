class FxQuote {
  final String quoteId;
  final String sourceCurrency;
  final String destCurrency;
  final double amount;
  final double convertedAmount;
  final double rate;
  final double fee;
  final String expiresAt;

  FxQuote({
    required this.quoteId,
    required this.sourceCurrency,
    required this.destCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.rate,
    required this.fee,
    required this.expiresAt,
  });
}

class FxExecution {
  final String orderId;
  final String status;
  final String sourceCurrency;
  final String destCurrency;
  final double amount;

  FxExecution({
    required this.orderId,
    required this.status,
    required this.sourceCurrency,
    required this.destCurrency,
    required this.amount,
  });
}

class ExchangeRate {
  final String from;
  final String to;
  final double rate;

  ExchangeRate({required this.from, required this.to, required this.rate});
}
