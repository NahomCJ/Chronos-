class WalletEntity {
  final String id;
  final String type;
  final String currency;
  final double balance;
  final String status;

  WalletEntity({
    required this.id,
    required this.type,
    required this.currency,
    required this.balance,
    required this.status,
  });
}

class CardEntity {
  final String id;
  final String brand;
  final String last4;
  final String type;
  final String status;
  final String? expiresAt;

  CardEntity({
    required this.id,
    required this.brand,
    required this.last4,
    required this.type,
    required this.status,
    this.expiresAt,
  });
}

class TransactionEntity {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String createdAt;

  TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  bool get isCredit => type == 'DEPOSIT' || type == 'CREDIT';
}

class WalletSummary {
  final List<WalletEntity> wallets;
  final List<CardEntity> cards;
  final List<TransactionEntity> recentTransactions;

  WalletSummary({
    required this.wallets,
    required this.cards,
    required this.recentTransactions,
  });

  double get totalBalance =>
      wallets.fold(0.0, (sum, w) => sum + w.balance);
}
