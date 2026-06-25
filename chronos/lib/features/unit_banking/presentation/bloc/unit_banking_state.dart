import 'package:equatable/equatable.dart';
import '../../domain/entities/unit_banking_entities.dart';

abstract class UnitBankingState extends Equatable {
  const UnitBankingState();
  @override
  List<Object?> get props => [];
}

class UnitBankingInitial extends UnitBankingState {
  const UnitBankingInitial();
}

class UnitBankingLoading extends UnitBankingState {
  const UnitBankingLoading();
}

class UnitBankingLoaded extends UnitBankingState {
  final UnitBankingSummary summary;
  const UnitBankingLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class UnitBankingError extends UnitBankingState {
  final String message;
  const UnitBankingError(this.message);
  @override
  List<Object?> get props => [message];
}

class UnitBankingActionSuccess extends UnitBankingState {
  final String message;
  final UnitBankingSummary summary;
  const UnitBankingActionSuccess({required this.message, required this.summary});
  @override
  List<Object?> get props => [message, summary];
}
