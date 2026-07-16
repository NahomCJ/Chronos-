import 'package:get_it/get_it.dart';
import '../data/data_source/exchange_remote_data_source.dart';
import '../data/repositories/exchange_repository_impl.dart';
import '../domain/repositories/exchange_repository.dart';
import '../domain/usecases/get_fx_quote.dart';
import '../presentation/bloc/exchange_bloc.dart';

void initExchangeDi(GetIt sl) {
  sl.registerLazySingleton(() => ExchangeRemoteDataSource(sl()));
  sl.registerLazySingleton<ExchangeRepository>(
      () => ExchangeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetFxQuote(sl()));
  sl.registerLazySingleton(() => ExecuteFx(sl()));
  sl.registerLazySingleton(() => GetExchangeRate(sl()));
  sl.registerFactory(
      () => ExchangeBloc(getFxQuote: sl(), executeFx: sl(), dataSource: sl()));
}
