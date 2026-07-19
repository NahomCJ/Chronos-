import '../../domain/entities/marketplace_product.dart';

abstract class MarketplaceState {}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class MarketplaceLoaded extends MarketplaceState {
  final List<MarketplaceProduct> products;
  final String query;
  MarketplaceLoaded(this.products, {required this.query});
}

class MarketplaceError extends MarketplaceState {
  final String message;
  MarketplaceError(this.message);
}
