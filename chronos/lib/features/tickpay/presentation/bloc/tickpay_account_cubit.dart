import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/tickpay_remote_datasource.dart';
import 'tickpay_account_state.dart';

class TickpayAccountCubit extends Cubit<TickpayAccountState> {
  final TickpayRemoteDataSource _remote;

  TickpayAccountCubit(this._remote) : super(const TickpayAccountInitial());

  Future<void> loadAccount() async {
    emit(const TickpayAccountLoading());
    try {
      final data = await _remote.getAccount();
      if (data == null) {
        emit(const TickpayAccountError(
            'No TickPay account found.\nComplete the TickPay onboarding to get started.'));
        return;
      }
      final txList = (data['transactions'] as List<dynamic>? ?? [])
          .map((e) => TickpayTxModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(TickpayAccountLoaded(
        creditLimit: _d(data['creditLimit']),
        balance: _d(data['balance']),
        available: _d(data['available'] ?? data['creditLimit']),
        status: data['status']?.toString() ?? 'ACTIVE',
        transactions: txList,
      ));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('unauthorized') || msg.contains('401')) {
        emit(const TickpayAccountError(
            'Please log in to access your TickPay account.'));
      } else {
        emit(TickpayAccountError(e.toString()));
      }
    }
  }

  Future<void> createPurchase({
    required double amount,
    required String merchant,
    String currency = 'USD',
  }) async {
    emit(const TickpayActionLoading());
    try {
      final result = await _remote.createPurchase(
        amount: amount,
        merchant: merchant,
        currency: currency,
      );
      emit(TickpayPurchaseSuccess(result));
    } catch (e) {
      emit(TickpayActionError(e.toString()));
    }
  }

  Future<void> createRepayment({
    required double amount,
    String currency = 'USD',
  }) async {
    emit(const TickpayActionLoading());
    try {
      await _remote.createRepayment(amount: amount, currency: currency);
      emit(const TickpayRepaymentSuccess());
    } catch (e) {
      emit(TickpayActionError(e.toString()));
    }
  }

  double _d(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
