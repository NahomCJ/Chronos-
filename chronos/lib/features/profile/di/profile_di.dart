import 'package:get_it/get_it.dart';
import '../data/datasources/profile_remote_datasource.dart';
import '../presentation/bloc/profile_cubit.dart';

void initProfileDi(GetIt sl) {
  sl.registerLazySingleton(() => ProfileRemoteDataSource(sl()));
  sl.registerFactory(() => ProfileCubit(sl()));
}
