class RecentTransaction {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String createdAt;
  final String? description;

  RecentTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.description,
  });

  bool get isCredit => type == 'DEPOSIT' || type == 'CREDIT' || amount > 0;
}

class SpendingByCategory {
  final String category;
  final double amount;

  SpendingByCategory({required this.category, required this.amount});
}

class HomeSummary {
  final double accountBalance;
  final double totalSpent;
  final List<RecentTransaction> recentTransactions;
  final List<SpendingByCategory> spendingByCategory;

  HomeSummary({
    required this.accountBalance,
    required this.totalSpent,
    required this.recentTransactions,
    required this.spendingByCategory,
  });
}
