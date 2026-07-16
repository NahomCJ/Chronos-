abstract class MarketplaceEvent {}

class ProductSearchRequested extends MarketplaceEvent {
  final String query;
  final double? budget;
  ProductSearchRequested(this.query, {this.budget});
}
