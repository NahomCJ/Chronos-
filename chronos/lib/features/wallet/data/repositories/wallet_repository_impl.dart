import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../data_source/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource dataSource;
  WalletRepositoryImpl(this.dataSource);

  @override
  Future<WalletSummary> getWalletSummary() => dataSource.getWalletSummary();
}
