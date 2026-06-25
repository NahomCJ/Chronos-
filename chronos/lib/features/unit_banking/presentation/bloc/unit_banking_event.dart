import 'package:equatable/equatable.dart';

abstract class UnitBankingEvent extends Equatable {
  const UnitBankingEvent();
  @override
  List<Object?> get props => [];
}

class UnitBankingLoadRequested extends UnitBankingEvent {
  const UnitBankingLoadRequested();
}

class UnitBankingFreezeCard extends UnitBankingEvent {
  final String unitCardId;
  const UnitBankingFreezeCard(this.unitCardId);
  @override
  List<Object?> get props => [unitCardId];
}

class UnitBankingUnfreezeCard extends UnitBankingEvent {
  final String unitCardId;
  const UnitBankingUnfreezeCard(this.unitCardId);
  @override
  List<Object?> get props => [unitCardId];
}

class UnitBankingCreateAccount extends UnitBankingEvent {
  const UnitBankingCreateAccount();
}
