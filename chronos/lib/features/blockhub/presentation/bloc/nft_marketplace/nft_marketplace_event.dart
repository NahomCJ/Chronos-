abstract class NftMarketplaceEvent {}

class NftMarketplaceLoadRequested extends NftMarketplaceEvent {
  final String? category;
  NftMarketplaceLoadRequested({this.category});
}
