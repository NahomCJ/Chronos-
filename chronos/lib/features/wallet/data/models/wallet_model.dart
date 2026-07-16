import '../../domain/entities/wallet_entity.dart';

class WalletModel {
  final String id;
  final String type;
  final String currency;
  final double balance;
  final String status;

  WalletModel({
    required this.id,
    required this.type,
    required this.currency,
    required this.balance,
    required this.status,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        currency: json['currency']?.toString() ?? 'USD',
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        status: json['status']?.toString() ?? '',
      );

  WalletEntity toEntity() => WalletEntity(
        id: id, type: type, currency: currency, balance: balance, status: status);
}

class CardModel {
  final String id;
  final String brand;
  final String last4;
  final String type;
  final String status;
  final String? expiresAt;

  CardModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.type,
    required this.status,
    this.expiresAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        id: json['id']?.toString() ?? '',
        brand: json['brand']?.toString() ?? '',
        last4: json['last4']?.toString() ?? '****',
        type: json['type']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        expiresAt: json['expiresAt']?.toString(),
      );

  CardEntity toEntity() => CardEntity(
        id: id, brand: brand, last4: last4,
        type: type, status: status, expiresAt: expiresAt);
}

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency']?.toString() ?? 'USD',
        status: json['status']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
      );

  TransactionEntity toEntity() => TransactionEntity(
        id: id, type: type, amount: amount,
        currency: currency, status: status, createdAt: createdAt);
}
