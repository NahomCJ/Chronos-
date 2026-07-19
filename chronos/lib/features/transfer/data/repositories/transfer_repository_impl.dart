import '../../domain/entities/transfer_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../data_source/transfer_remote_data_source.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource dataSource;
  TransferRepositoryImpl(this.dataSource);

  @override
  Future<TransferEntity> createTransfer({
    required String sourceWalletId,
    required String destWalletId,
    required double amount,
    required String currency,
    String? reference,
  }) async {
    final model = await dataSource.createTransfer(
      sourceWalletId: sourceWalletId,
      destWalletId: destWalletId,
      amount: amount,
      currency: currency,
      reference: reference,
    );
    return model.toEntity();
  }

  @override
  Future<List<TransferEntity>> getTransfers() async {
    final models = await dataSource.getTransfers();
    return models.map((m) => m.toEntity()).toList();
  }
}
