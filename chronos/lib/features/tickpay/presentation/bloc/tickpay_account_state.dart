import 'package:equatable/equatable.dart';

abstract class TickpayAccountState extends Equatable {
  const TickpayAccountState();
  @override
  List<Object?> get props => [];
}

class TickpayAccountInitial extends TickpayAccountState {
  const TickpayAccountInitial();
}

class TickpayAccountLoading extends TickpayAccountState {
  const TickpayAccountLoading();
}

class TickpayAccountLoaded extends TickpayAccountState {
  final double creditLimit;
  final double balance;
  final double available;
  final String status;
  final List<TickpayTxModel> transactions;

  const TickpayAccountLoaded({
    required this.creditLimit,
    required this.balance,
    required this.available,
    required this.status,
    required this.transactions,
  });

  double get creditUsed => creditLimit - available;

  List<TickpayTxModel> get purchases =>
      transactions.where((t) => t.isPurchase).toList();

  @override
  List<Object?> get props =>
      [creditLimit, balance, available, status, transactions];
}

class TickpayAccountError extends TickpayAccountState {
  final String message;
  const TickpayAccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class TickpayActionLoading extends TickpayAccountState {
  const TickpayActionLoading();
}

class TickpayPurchaseSuccess extends TickpayAccountState {
  final Map<String, dynamic> result;
  const TickpayPurchaseSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class TickpayRepaymentSuccess extends TickpayAccountState {
  const TickpayRepaymentSuccess();
}

class TickpayActionError extends TickpayAccountState {
  final String message;
  const TickpayActionError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Model ─────────────────────────────────────────────────────────────────────

class TickpayTxModel extends Equatable {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String? merchant;
  final DateTime createdAt;
  final String status;

  const TickpayTxModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    this.merchant,
    required this.createdAt,
    required this.status,
  });

  factory TickpayTxModel.fromJson(Map<String, dynamic> j) => TickpayTxModel(
        id: j['id']?.toString() ?? '',
        type: j['type']?.toString() ?? '',
        amount: _toDouble(j['amount']),
        currency: j['currency']?.toString() ?? 'USD',
        merchant: j['merchant']?.toString(),
        createdAt:
            DateTime.tryParse(j['createdAt']?.toString() ?? '') ?? DateTime.now(),
        status: j['status']?.toString() ?? '',
      );

  bool get isPurchase => type == 'PURCHASE';
  bool get isRepayment => type == 'REPAYMENT';

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  @override
  List<Object?> get props =>
      [id, type, amount, currency, merchant, createdAt, status];
}
