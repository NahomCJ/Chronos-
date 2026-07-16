import '../../domain/entities/exchange_entity.dart';

class FxQuoteModel {
  final String quoteId;
  final String sourceCurrency;
  final String destCurrency;
  final double amount;
  final double convertedAmount;
  final double rate;
  final double fee;
  final String expiresAt;

  FxQuoteModel({
    required this.quoteId,
    required this.sourceCurrency,
    required this.destCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.rate,
    required this.fee,
    required this.expiresAt,
  });

  factory FxQuoteModel.fromJson(Map<String, dynamic> json) => FxQuoteModel(
        quoteId: json['quoteId']?.toString() ?? '',
        sourceCurrency: json['sourceCurrency']?.toString() ?? '',
        destCurrency: json['destCurrency']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        convertedAmount: (json['convertedAmount'] as num?)?.toDouble() ?? 0.0,
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
        fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
        expiresAt: json['expiresAt']?.toString() ?? '',
      );

  FxQuote toEntity() => FxQuote(
        quoteId: quoteId,
        sourceCurrency: sourceCurrency,
        destCurrency: destCurrency,
        amount: amount,
        convertedAmount: convertedAmount,
        rate: rate,
        fee: fee,
        expiresAt: expiresAt,
      );
}

class FxExecutionModel {
  final String orderId;
  final String status;
  final String sourceCurrency;
  final String destCurrency;
  final double amount;

  FxExecutionModel({
    required this.orderId,
    required this.status,
    required this.sourceCurrency,
    required this.destCurrency,
    required this.amount,
  });

  factory FxExecutionModel.fromJson(Map<String, dynamic> json) =>
      FxExecutionModel(
        orderId: json['orderId']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        sourceCurrency: json['sourceCurrency']?.toString() ?? '',
        destCurrency: json['destCurrency']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      );

  FxExecution toEntity() => FxExecution(
        orderId: orderId,
        status: status,
        sourceCurrency: sourceCurrency,
        destCurrency: destCurrency,
        amount: amount,
      );
}

class ExchangeRateModel {
  final String from;
  final String to;
  final double rate;

  ExchangeRateModel(
      {required this.from, required this.to, required this.rate});

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) =>
      ExchangeRateModel(
        from: json['from']?.toString() ?? '',
        to: json['to']?.toString() ?? '',
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      );

  ExchangeRate toEntity() =>
      ExchangeRate(from: from, to: to, rate: rate);
}
