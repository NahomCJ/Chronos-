import '../../domain/entities/unit_banking_entities.dart';

class UnitAccountModel {
  final String unitAccountId;
  final String? routingNumber;
  final String? accountNumber;
  final double balance;
  final String status;

  const UnitAccountModel({
    required this.unitAccountId,
    this.routingNumber,
    this.accountNumber,
    required this.balance,
    required this.status,
  });

  factory UnitAccountModel.fromJson(Map<String, dynamic> json) {
    return UnitAccountModel(
      unitAccountId: json['unitAccountId'] as String? ?? '',
      routingNumber: json['routingNumber'] as String?,
      accountNumber: json['accountNumber'] as String?,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      status: json['status'] as String? ?? 'active',
    );
  }

  UnitAccountEntity toEntity() => UnitAccountEntity(
        unitAccountId: unitAccountId,
        routingNumber: routingNumber,
        accountNumber: accountNumber,
        balance: balance,
        status: status,
      );
}

class UnitCardModel {
  final String unitCardId;
  final String last4;
  final String status;
  final String type;

  const UnitCardModel({
    required this.unitCardId,
    required this.last4,
    required this.status,
    required this.type,
  });

  factory UnitCardModel.fromJson(Map<String, dynamic> json) {
    return UnitCardModel(
      unitCardId: json['unitCardId'] as String? ?? '',
      last4: json['last4'] as String? ?? '****',
      status: json['status'] as String? ?? 'active',
      type: json['type'] as String? ?? 'VIRTUAL',
    );
  }

  UnitCardEntity toEntity() => UnitCardEntity(
        unitCardId: unitCardId,
        last4: last4,
        status: status,
        type: type,
      );
}

class UnitTransferModel {
  final String unitTransferId;
  final String status;
  final double amount;
  final String? createdAt;

  const UnitTransferModel({
    required this.unitTransferId,
    required this.status,
    required this.amount,
    this.createdAt,
  });

  factory UnitTransferModel.fromJson(Map<String, dynamic> json) {
    return UnitTransferModel(
      unitTransferId: json['unitTransferId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      createdAt: json['createdAt'] as String?,
    );
  }

  UnitTransferEntity toEntity() => UnitTransferEntity(
        unitTransferId: unitTransferId,
        status: status,
        amount: amount,
        createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      );
}
