import 'package:equatable/equatable.dart';
import '../../domain/entities/transfer_entity.dart';

abstract class TransferState extends Equatable {
  const TransferState();
  @override
  List<Object?> get props => [];
}

class TransferInitial extends TransferState {
  const TransferInitial();
}

class TransferLoading extends TransferState {
  const TransferLoading();
}

class TransferSuccess extends TransferState {
  final TransferEntity transfer;
  const TransferSuccess(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

class TransferFailure extends TransferState {
  final String message;
  const TransferFailure(this.message);

  @override
  List<Object?> get props => [message];
}
