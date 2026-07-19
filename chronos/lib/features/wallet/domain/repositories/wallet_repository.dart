import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<WalletSummary> getWalletSummary();
}
