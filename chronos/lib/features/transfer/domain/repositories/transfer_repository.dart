import '../entities/transfer_entity.dart';

abstract class TransferRepository {
  Future<TransferEntity> createTransfer({
    required String sourceWalletId,
    required String destWalletId,
    required double amount,
    required String currency,
    String? reference,
  });

  Future<List<TransferEntity>> getTransfers();
}
