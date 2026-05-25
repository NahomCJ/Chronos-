import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/blockhub_usecases.dart';
import 'nft_event.dart';
import 'nft_state.dart';

class NftBloc extends Bloc<NftEvent, NftState> {
  final GetNftCollections _getNftCollections;
  final BrowseNfts _browseNfts;

  NftBloc({
    required GetNftCollections getNftCollections,
    required BrowseNfts browseNfts,
  })  : _getNftCollections = getNftCollections,
        _browseNfts = browseNfts,
        super(NftInitial()) {
    on<NftCollectionsLoadRequested>(_onLoadCollections);
    on<NftBrowseRequested>(_onBrowse);
  }

  Future<void> _onLoadCollections(
      NftCollectionsLoadRequested event, Emitter<NftState> emit) async {
    emit(NftLoading());
    try {
      final collections = await _getNftCollections(page: event.page);
      emit(NftCollectionsLoaded(collections));
    } catch (e) {
      emit(NftError(e.toString()));
    }
  }

  Future<void> _onBrowse(
      NftBrowseRequested event, Emitter<NftState> emit) async {
    emit(NftLoading());
    try {
      final items = await _browseNfts();
      emit(NftItemsLoaded(items));
    } catch (e) {
      emit(NftError(e.toString()));
    }
  }
}
