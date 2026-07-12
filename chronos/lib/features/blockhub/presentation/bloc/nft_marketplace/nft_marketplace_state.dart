import '../../../domain/entities/blockhub_entities.dart';

abstract class NftMarketplaceState {}

class NftMarketplaceInitial extends NftMarketplaceState {}

class NftMarketplaceLoading extends NftMarketplaceState {}

class NftMarketplaceLoaded extends NftMarketplaceState {
  final NftCollection? featured;
  final List<NftCollection> trending;
  final List<NftCollection> topVolume;
  final List<NftItem> newDrops;

  NftMarketplaceLoaded({
    required this.featured,
    required this.trending,
    required this.topVolume,
    required this.newDrops,
  });

  bool get isEmpty =>
      featured == null &&
      trending.isEmpty &&
      topVolume.isEmpty &&
      newDrops.isEmpty;
}

class NftMarketplaceError extends NftMarketplaceState {
  final String message;
  NftMarketplaceError(this.message);
}
