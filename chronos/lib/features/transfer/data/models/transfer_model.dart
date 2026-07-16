import '../../domain/entities/transfer_entity.dart';

class TransferModel {
  final String id;
  final String status;
  final double amount;
  final String? fee;
  final String? estimatedTime;
  final String? sourceWalletId;
  final String? destWalletId;
  final String createdAt;

  TransferModel({
    required this.id,
    required this.status,
    required this.amount,
    this.fee,
    this.estimatedTime,
    this.sourceWalletId,
    this.destWalletId,
    required this.createdAt,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) => TransferModel(
        id: json['id']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        fee: json['fee']?.toString(),
        estimatedTime: json['estimatedTime']?.toString(),
        sourceWalletId: json['sourceWallet']?['id']?.toString() ??
            json['sourceWalletId']?.toString(),
        destWalletId: json['destWallet']?['id']?.toString() ??
            json['destWalletId']?.toString(),
        createdAt: json['createdAt']?.toString() ?? '',
      );

  TransferEntity toEntity() => TransferEntity(
        id: id,
        status: status,
        amount: amount,
        fee: fee,
        estimatedTime: estimatedTime,
        sourceWalletId: sourceWalletId,
        destWalletId: destWalletId,
        createdAt: createdAt,
      );
}
