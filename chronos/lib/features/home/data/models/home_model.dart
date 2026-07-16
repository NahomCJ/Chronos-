import '../../domain/entities/home_summary.dart';

class RecentTransactionModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String createdAt;
  final String? description;

  RecentTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.description,
  });

  factory RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  RecentTransaction toEntity() => RecentTransaction(
        id: id,
        type: type,
        amount: amount,
        currency: currency,
        status: status,
        createdAt: createdAt,
        description: description,
      );
}

class HomeSummaryModel {
  final double accountBalance;
  final double totalSpent;
  final List<RecentTransactionModel> recentTransactions;
  final Map<String, dynamic> byCategory;

  HomeSummaryModel({
    required this.accountBalance,
    required this.totalSpent,
    required this.recentTransactions,
    required this.byCategory,
  });

  factory HomeSummaryModel.fromJson(Map<String, dynamic> json) {
    final txList = (json['recentTransactions'] as List<dynamic>? ?? [])
        .map((e) => RecentTransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final cat = json['byCategory'] as Map<String, dynamic>? ?? {};

    return HomeSummaryModel(
      accountBalance: (json['accountBalance'] as num?)?.toDouble() ??
          (json['totalBalance'] as num?)?.toDouble() ??
          0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      recentTransactions: txList,
      byCategory: cat,
    );
  }

  HomeSummary toEntity() {
    final categories = byCategory.entries
        .map((e) => SpendingByCategory(
              category: e.key,
              amount: (e.value as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    return HomeSummary(
      accountBalance: accountBalance,
      totalSpent: totalSpent,
      recentTransactions: recentTransactions.map((t) => t.toEntity()).toList(),
      spendingByCategory: categories,
    );
  }
}
