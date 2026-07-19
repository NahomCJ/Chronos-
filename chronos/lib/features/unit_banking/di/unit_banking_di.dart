import 'package:get_it/get_it.dart';
import '../data/datasources/unit_banking_remote_datasource.dart';
import '../data/repositories/unit_banking_repository_impl.dart';
import '../domain/repositories/unit_banking_repository.dart';
import '../domain/usecases/get_unit_banking_summary.dart';
import '../presentation/bloc/unit_banking_bloc.dart';

void initUnitBankingDi(GetIt sl) {
  sl.registerLazySingleton(() => UnitBankingRemoteDataSource(sl()));
  sl.registerLazySingleton<UnitBankingRepository>(
      () => UnitBankingRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetUnitBankingSummary(sl()));
  sl.registerFactory(() => UnitBankingBloc(sl(), sl()));
}
