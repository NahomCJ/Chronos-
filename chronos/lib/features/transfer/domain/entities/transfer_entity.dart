class TransferEntity {
  final String id;
  final String status;
  final double amount;
  final String? fee;
  final String? estimatedTime;
  final String? sourceWalletId;
  final String? destWalletId;
  final String createdAt;

  TransferEntity({
    required this.id,
    required this.status,
    required this.amount,
    this.fee,
    this.estimatedTime,
    this.sourceWalletId,
    this.destWalletId,
    required this.createdAt,
  });
}
