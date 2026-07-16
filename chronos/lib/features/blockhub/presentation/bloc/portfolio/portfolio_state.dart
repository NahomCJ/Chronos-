import '../../../domain/entities/blockhub_entities.dart';

abstract class PortfolioState {}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final List<CryptoHolding> holdings;
  PortfolioLoaded(this.holdings);

  double get totalValue => holdings.fold<double>(
        0.0,
        (double sum, CryptoHolding h) => sum + h.totalValue,
      );
}

class PortfolioError extends PortfolioState {
  final String message;
  PortfolioError(this.message);
}
