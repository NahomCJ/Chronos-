import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletSummary {
  final WalletRepository repository;
  GetWalletSummary(this.repository);

  Future<WalletSummary> call() => repository.getWalletSummary();
}
