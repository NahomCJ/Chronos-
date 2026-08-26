import 'package:get_it/get_it.dart';
import '../data/data_source/blockhub_remote_data_source.dart';
import '../data/data_source/stocks_remote_data_source.dart';
import '../data/repositories/blockhub_repository_impl.dart';
import '../domain/repositories/blockhub_repository.dart';
import '../domain/usecases/blockhub_usecases.dart';
import '../presentation/bloc/portfolio/portfolio_bloc.dart';
import '../presentation/bloc/market/market_bloc.dart';
import '../presentation/bloc/trade/trade_bloc.dart';
import '../presentation/bloc/nft/nft_bloc.dart';
import '../presentation/bloc/nft_marketplace/nft_marketplace_bloc.dart';

void initBlockhubDi(GetIt sl) {
  sl.registerLazySingleton(() => BlockhubRemoteDataSource(sl()));
  sl.registerLazySingleton(() => StocksRemoteDataSource(sl()));
  sl.registerLazySingleton<BlockhubRepository>(
      () => BlockhubRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetCryptoPortfolio(sl()));
  sl.registerLazySingleton(() => GetMarketPrices(sl()));
  sl.registerLazySingleton(() => GetAssetPrice(sl()));
  sl.registerLazySingleton(() => BuyCrypto(sl()));
  sl.registerLazySingleton(() => SellCrypto(sl()));
  sl.registerLazySingleton(() => GetNftCollections(sl()));
  sl.registerLazySingleton(() => BrowseNfts(sl()));
  sl.registerLazySingleton(() => GetFeaturedCollection(sl()));
  sl.registerLazySingleton(() => GetTrendingCollections(sl()));
  sl.registerLazySingleton(() => GetTopVolumeCollections(sl()));
  sl.registerLazySingleton(() => GetNewDrops(sl()));

  sl.registerFactory(
      () => PortfolioBloc(getPortfolio: sl()));
  sl.registerFactory(
      () => MarketBloc(getMarketPrices: sl()));
  sl.registerFactory(
      () => TradeBloc(buyCrypto: sl(), sellCrypto: sl()));
  sl.registerFactory(
      () => NftBloc(getNftCollections: sl(), browseNfts: sl()));
  sl.registerFactory(() => NftMarketplaceBloc(
        getFeatured: sl(),
        getTrending: sl(),
        getTopVolume: sl(),
        getNewDrops: sl(),
      ));
}
