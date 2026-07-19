class PantherTransaction {
  final String id;
  final String merchantName;
  final double amount;
  final String date;
  final String subcategory;

  const PantherTransaction({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.subcategory,
  });
}
