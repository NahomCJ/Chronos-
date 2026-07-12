import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/blockhub_usecases.dart';
import 'nft_marketplace_event.dart';
import 'nft_marketplace_state.dart';

class NftMarketplaceBloc
    extends Bloc<NftMarketplaceEvent, NftMarketplaceState> {
  final GetFeaturedCollection _getFeatured;
  final GetTrendingCollections _getTrending;
  final GetTopVolumeCollections _getTopVolume;
  final GetNewDrops _getNewDrops;

  NftMarketplaceBloc({
    required GetFeaturedCollection getFeatured,
    required GetTrendingCollections getTrending,
    required GetTopVolumeCollections getTopVolume,
    required GetNewDrops getNewDrops,
  })  : _getFeatured = getFeatured,
        _getTrending = getTrending,
        _getTopVolume = getTopVolume,
        _getNewDrops = getNewDrops,
        super(NftMarketplaceInitial()) {
    on<NftMarketplaceLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(NftMarketplaceLoadRequested event,
      Emitter<NftMarketplaceState> emit) async {
    emit(NftMarketplaceLoading());
    try {
      // Kick off all four requests concurrently, then await in order.
      final featuredFuture = _getFeatured();
      final trendingFuture = _getTrending(category: event.category);
      final topVolumeFuture = _getTopVolume(category: event.category);
      final newDropsFuture = _getNewDrops(category: event.category);

      final featured = await featuredFuture;
      final trending = await trendingFuture;
      final topVolume = await topVolumeFuture;
      final newDrops = await newDropsFuture;

      emit(NftMarketplaceLoaded(
        featured: featured,
        trending: trending,
        topVolume: topVolume,
        newDrops: newDrops,
      ));
    } catch (e) {
      emit(NftMarketplaceError(e.toString()));
    }
  }
}
