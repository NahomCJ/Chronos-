import '../../../domain/entities/blockhub_entities.dart';

abstract class NftState {}

class NftInitial extends NftState {}

class NftLoading extends NftState {}

class NftCollectionsLoaded extends NftState {
  final List<NftCollection> collections;
  NftCollectionsLoaded(this.collections);
}

class NftItemsLoaded extends NftState {
  final List<NftItem> items;
  NftItemsLoaded(this.items);
}

class NftError extends NftState {
  final String message;
  NftError(this.message);
}
