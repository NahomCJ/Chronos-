abstract class NftEvent {}

class NftCollectionsLoadRequested extends NftEvent {
  final int page;
  NftCollectionsLoadRequested({this.page = 1});
}

class NftBrowseRequested extends NftEvent {}
