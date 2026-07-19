import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_products.dart';
import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final SearchProducts _searchProducts;

  MarketplaceBloc({required SearchProducts searchProducts})
      : _searchProducts = searchProducts,
        super(MarketplaceInitial()) {
    on<ProductSearchRequested>(_onSearch);
  }

  Future<void> _onSearch(
      ProductSearchRequested event, Emitter<MarketplaceState> emit) async {
    emit(MarketplaceLoading());
    try {
      final products =
          await _searchProducts(event.query, budget: event.budget);
      emit(MarketplaceLoaded(products, query: event.query));
    } catch (e) {
      emit(MarketplaceError(e.toString()));
    }
  }
}
