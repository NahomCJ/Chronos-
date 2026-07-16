import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class WalletSummaryRequested extends WalletEvent {
  const WalletSummaryRequested();
}
