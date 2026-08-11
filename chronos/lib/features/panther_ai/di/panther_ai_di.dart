import 'package:get_it/get_it.dart';
import '../data/data_source/panther_ai_remote_data_source.dart';
import '../data/data_source/auto_invest_remote_data_source.dart';
import '../data/repositories/panther_ai_repository_impl.dart';
import '../data/repositories/auto_invest_repository_impl.dart';
import '../data/repositories/auto_invest_mock_repository.dart';
import '../domain/repositories/panther_ai_repository.dart';
import '../domain/repositories/auto_invest_repository.dart';
import '../domain/usecases/send_message.dart';
import '../domain/usecases/get_alerts.dart';
import '../domain/usecases/check_affordability.dart';
import '../domain/usecases/get_net_worth.dart';
import '../domain/usecases/get_spending_summary.dart';
import '../domain/usecases/get_transactions.dart';
import '../domain/usecases/search_products.dart';
import '../domain/usecases/authorize_payment.dart';
import '../domain/usecases/get_allocation_preview.dart';
import '../domain/usecases/manage_auto_invest_plan.dart';
import '../presentation/bloc/alerts_bloc.dart';
import '../presentation/bloc/chat_bloc.dart';
import '../presentation/bloc/affordability_bloc.dart';
import '../presentation/bloc/net_worth_bloc.dart';
import '../presentation/bloc/spending_bloc.dart';
import '../presentation/bloc/marketplace_bloc.dart';
import '../presentation/cubit/auto_invest_cubit.dart';

/// Set to `false` once a real backend is reachable from this app again and
/// Auto-Invest should hit it. AWS Elastic Beanstalk is being retired (see
/// root CLAUDE.md) and nothing has replaced it yet, so `POST /api/v1/auto-invest/*`
/// has nowhere to land right now — this keeps the whole feature usable for
/// front-end/design work in the meantime with zero backend dependency. See
/// `AutoInvestMockRepository` for what it does instead.
const bool kAutoInvestUseMockBackend = true;

void initPantherAiDi(GetIt sl) {
  sl.registerLazySingleton(
      () => PantherAiRemoteDataSource(sl(), sl()));
  sl.registerLazySingleton<PantherAiRepository>(
      () => PantherAiRepositoryImpl(sl()));

  sl.registerLazySingleton(() => AutoInvestRemoteDataSource(sl()));
  sl.registerLazySingleton<AutoInvestRepository>(
      () => kAutoInvestUseMockBackend
          ? AutoInvestMockRepository()
          : AutoInvestRepositoryImpl(sl()));

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

  sl.registerLazySingleton(() => GetAllocationPreview(sl()));
  sl.registerLazySingleton(() => CreateAutoInvestPlan(sl()));
  sl.registerLazySingleton(() => ConfirmAutoInvestPlan(sl()));
  sl.registerLazySingleton(() => GetActiveAutoInvestPlan(sl()));
  sl.registerLazySingleton(() => GetAutoInvestPlan(sl()));
  sl.registerLazySingleton(() => PauseAutoInvestPlan(sl()));
  sl.registerLazySingleton(() => ResumeAutoInvestPlan(sl()));
  sl.registerLazySingleton(() => CancelAutoInvestPlan(sl()));
  sl.registerLazySingleton(() => TriggerNextInvestRound(sl()));

  sl.registerFactory(() => AlertsBloc(
        getAlerts: sl(),
        generateAlerts: sl(),
        dismissAlert: sl(),
      ));
  sl.registerFactory(() => ChatBloc(
        sendMessage: sl(),
        getNetWorthDashboard: sl(),
        getSpendingSummary: sl(),
        searchProducts: sl(),
      ));
  sl.registerFactory(() => AffordabilityBloc(checkAffordability: sl()));
  sl.registerFactory(() => SpendingBloc(getSpendingSummary: sl()));
  sl.registerFactory(() => MarketplaceBloc(searchProducts: sl()));
  sl.registerFactory(() => NetWorthBloc(
        getNetWorthDashboard: sl(),
        getNetWorthProjection: sl(),
      ));

  // Lazy singleton (not a factory, unlike the blocs above) — the auto-invest
  // wizard spans several GoRouter routes (intro -> goals -> amount ->
  // preview -> review -> success/dashboard) and needs the same cubit
  // instance across all of them so selections survive `context.push`
  // navigation. Provided via `BlocProvider.value` at each route in
  // app_route.dart, same pattern as `ThemeCubit` (see core/di/app_di.dart).
  sl.registerLazySingleton(() => AutoInvestCubit(
        getAllocationPreview: sl(),
        createPlan: sl(),
        confirmPlan: sl(),
        getActivePlan: sl(),
        getPlan: sl(),
        pausePlan: sl(),
        resumePlan: sl(),
        cancelPlan: sl(),
        triggerNextRound: sl(),
      ));
}
