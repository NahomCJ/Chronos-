import 'package:equatable/equatable.dart';

class UnitAccountEntity extends Equatable {
  final String unitAccountId;
  final String? routingNumber;
  final String? accountNumber;
  final double balance;
  final String status;

  const UnitAccountEntity({
    required this.unitAccountId,
    this.routingNumber,
    this.accountNumber,
    required this.balance,
    required this.status,
  });

  bool get isActive => status.toLowerCase() == 'active' || status.toLowerCase() == 'open';

  @override
  List<Object?> get props => [unitAccountId, routingNumber, accountNumber, balance, status];
}

class UnitCardEntity extends Equatable {
  final String unitCardId;
  final String last4;
  final String status;
  final String type;

  const UnitCardEntity({
    required this.unitCardId,
    required this.last4,
    required this.status,
    required this.type,
  });

  bool get isFrozen => status.toLowerCase() == 'frozen';
  bool get isVirtual => type.toUpperCase() == 'VIRTUAL';

  @override
  List<Object?> get props => [unitCardId, last4, status, type];
}

class UnitTransferEntity extends Equatable {
  final String unitTransferId;
  final String status;
  final double amount;
  final DateTime? createdAt;

  const UnitTransferEntity({
    required this.unitTransferId,
    required this.status,
    required this.amount,
    this.createdAt,
  });

  @override
  List<Object?> get props => [unitTransferId, status, amount, createdAt];
}

class UnitBankingSummary extends Equatable {
  final List<UnitAccountEntity> accounts;
  final List<UnitCardEntity> cards;
  final List<UnitTransferEntity> transfers;

  const UnitBankingSummary({
    required this.accounts,
    required this.cards,
    required this.transfers,
  });

  double get totalBalance =>
      accounts.fold(0.0, (sum, a) => sum + a.balance);

  bool get hasAccounts => accounts.isNotEmpty;

  @override
  List<Object?> get props => [accounts, cards, transfers];
}
