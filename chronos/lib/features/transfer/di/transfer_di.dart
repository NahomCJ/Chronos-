import 'package:get_it/get_it.dart';
import '../data/data_source/transfer_remote_data_source.dart';
import '../data/repositories/transfer_repository_impl.dart';
import '../domain/repositories/transfer_repository.dart';
import '../domain/usecases/create_transfer.dart';
import '../presentation/bloc/transfer_bloc.dart';

void initTransferDi(GetIt sl) {
  sl.registerLazySingleton(() => TransferRemoteDataSource(sl()));
  sl.registerLazySingleton<TransferRepository>(
      () => TransferRepositoryImpl(sl()));
  sl.registerLazySingleton(() => CreateTransfer(sl()));
  sl.registerFactory(
      () => TransferBloc(createTransfer: sl(), dataSource: sl()));
}
