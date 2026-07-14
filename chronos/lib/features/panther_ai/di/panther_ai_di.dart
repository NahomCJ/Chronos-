import 'package:get_it/get_it.dart';
import '../data/data_source/panther_ai_remote_data_source.dart';
import '../data/repositories/panther_ai_repository_impl.dart';
import '../domain/repositories/panther_ai_repository.dart';
import '../domain/usecases/send_message.dart';
import '../domain/usecases/get_alerts.dart';
import '../domain/usecases/check_affordability.dart';
import '../domain/usecases/get_net_worth.dart';
import '../domain/usecases/get_spending_summary.dart';
import '../domain/usecases/get_transactions.dart';
import '../domain/usecases/search_products.dart';
import '../domain/usecases/authorize_payment.dart';
import '../presentation/bloc/alerts_bloc.dart';
import '../presentation/bloc/chat_bloc.dart';
import '../presentation/bloc/affordability_bloc.dart';
import '../presentation/bloc/net_worth_bloc.dart';
import '../presentation/bloc/spending_bloc.dart';
import '../presentation/bloc/marketplace_bloc.dart';

void initPantherAiDi(GetIt sl) {
  sl.registerLazySingleton(
      () => PantherAiRemoteDataSource(sl(), sl()));
  sl.registerLazySingleton<PantherAiRepository>(
      () => PantherAiRepositoryImpl(sl()));

  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetAlerts(sl()));
  sl.registerLazySingleton(() => GenerateAlerts(sl()));
  sl.registerLazySingleton(() => DismissAlert(sl()));
  sl.registerLazySingleton(() => CheckAffordability(sl()));
  sl.registerLazySingleton(() => GetSpendingSummary(sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => AuthorizePayment(sl()));
  sl.registerLazySingleton(() => GetNetWorthDashboard(sl()));
  sl.registerLazySingleton(() => GetNetWorthProjection(sl()));

  sl.registerFactory(() => AlertsBloc(
        getAlerts: sl(),
        generateAlerts: sl(),
        dismissAlert: sl(),
      ));
  sl.registerFactory(() => ChatBloc(sendMessage: sl()));
  sl.registerFactory(() => AffordabilityBloc(checkAffordability: sl()));
  sl.registerFactory(() => SpendingBloc(getSpendingSummary: sl()));
  sl.registerFactory(() => MarketplaceBloc(searchProducts: sl()));
  sl.registerFactory(() => NetWorthBloc(
        getNetWorthDashboard: sl(),
        getNetWorthProjection: sl(),
      ));
}
