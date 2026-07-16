import '../entities/transfer_entity.dart';
import '../repositories/transfer_repository.dart';

class CreateTransfer {
  final TransferRepository repository;
  CreateTransfer(this.repository);

  Future<TransferEntity> call({
    required String sourceWalletId,
    required String destWalletId,
    required double amount,
    required String currency,
    String? reference,
  }) =>
      repository.createTransfer(
        sourceWalletId: sourceWalletId,
        destWalletId: destWalletId,
        amount: amount,
        currency: currency,
        reference: reference,
      );
}
