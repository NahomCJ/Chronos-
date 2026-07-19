import '../entities/marketplace_product.dart';
import '../repositories/panther_ai_repository.dart';

class SearchProducts {
  final PantherAiRepository repository;
  SearchProducts(this.repository);

  Future<List<MarketplaceProduct>> call(String query, {double? budget}) =>
      repository.searchProducts(query, budget: budget);
}
