class SpendingCategory {
  final String name;
  final double total;
  final double percentage;
  final String color;
  final List<String> topMerchants;

  const SpendingCategory({
    required this.name,
    required this.total,
    required this.percentage,
    required this.color,
    this.topMerchants = const [],
  });
}

class SpendingSummary {
  final double totalSpent;
  final int transactionCount;
  final double dailyAverage;
  final List<SpendingCategory> byCategory;

  const SpendingSummary({
    required this.totalSpent,
    required this.transactionCount,
    required this.dailyAverage,
    required this.byCategory,
  });
}
