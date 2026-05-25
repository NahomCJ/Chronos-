import 'package:equatable/equatable.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();
  @override
  List<Object?> get props => [];
}

class TransferSubmitted extends TransferEvent {
  final double amount;
  final String recipientName;
  final String method;
  final String? sourceWalletId;
  final String? destWalletId;

  const TransferSubmitted({
    required this.amount,
    required this.recipientName,
    required this.method,
    this.sourceWalletId,
    this.destWalletId,
  });

  @override
  List<Object?> get props =>
      [amount, recipientName, method, sourceWalletId, destWalletId];
}
