import 'package:get_it/get_it.dart';
import '../data/data_source/wallet_remote_data_source.dart';
import '../data/repositories/wallet_repository_impl.dart';
import '../domain/repositories/wallet_repository.dart';
import '../domain/usecases/get_wallet_summary.dart';
import '../presentation/bloc/wallet_bloc.dart';

void initWalletDi(GetIt sl) {
  sl.registerLazySingleton(() => WalletRemoteDataSource(sl()));
  sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetWalletSummary(sl()));
  sl.registerFactory(() => WalletBloc(sl()));
}
