import 'package:get_it/get_it.dart';
import '../data/data_source/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_summary.dart';
import '../presentation/bloc/home_bloc.dart';

void initHomeDi(GetIt sl) {
  sl.registerLazySingleton(() => HomeRemoteDataSource(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetHomeSummary(sl()));
  sl.registerFactory(() => HomeBloc(sl()));
}
