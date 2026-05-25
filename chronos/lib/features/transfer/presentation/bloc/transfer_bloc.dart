import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_transfer.dart';
import '../../data/data_source/transfer_remote_data_source.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final CreateTransfer createTransfer;
  final TransferRemoteDataSource dataSource;

  TransferBloc({required this.createTransfer, required this.dataSource})
      : super(const TransferInitial()) {
    on<TransferSubmitted>(_onTransferSubmitted);
  }

  Future<void> _onTransferSubmitted(
    TransferSubmitted event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());
    try {
      String sourceWalletId = event.sourceWalletId ?? '';
      String destWalletId = event.destWalletId ?? '';

      if (sourceWalletId.isEmpty) {
        sourceWalletId = await dataSource.getDefaultWalletId() ?? '';
      }

      if (sourceWalletId.isEmpty) {
        emit(const TransferFailure('No wallet found. Please set up a wallet first.'));
        return;
      }

      // Use source wallet as dest placeholder when no dest wallet provided
      if (destWalletId.isEmpty) {
        destWalletId = sourceWalletId;
      }

      final transfer = await createTransfer(
        sourceWalletId: sourceWalletId,
        destWalletId: destWalletId,
        amount: event.amount,
        currency: 'USD',
        reference: event.recipientName,
      );
      emit(TransferSuccess(transfer));
    } catch (e) {
      emit(TransferFailure(e.toString()));
    }
  }
}
