class MarketplaceProduct {
  final String productId;
  final String name;
  final double price;
  final String vendor;
  final bool bnplEligible;
  final int bnplScore;
  final double? rating;
  final bool inStock;

  const MarketplaceProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.vendor,
    required this.bnplEligible,
    required this.bnplScore,
    this.rating,
    required this.inStock,
  });
}
