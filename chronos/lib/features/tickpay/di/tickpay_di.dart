import 'package:get_it/get_it.dart';

import '../data/datasources/tickpay_local_data_source.dart';
import '../data/datasources/tickpay_remote_datasource.dart';
import '../data/repositories/tickpay_repository_impl.dart';
import '../domain/repositories/tickpay_repository.dart';
import '../presentation/bloc/tickpay_account_cubit.dart';

void initTickpayDi(GetIt sl) {
  sl.registerLazySingleton(() => const TickpayLocalDataSource());
  sl.registerLazySingleton(() => TickpayRemoteDataSource(sl()));
  sl.registerLazySingleton<TickpayRepository>(
    () => TickpayRepositoryImpl(sl()),
  );
  sl.registerFactory(() => TickpayAccountCubit(sl()));
}
