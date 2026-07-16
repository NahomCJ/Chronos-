class InvestmentHolding {
  final String name;
  final String? tickerSymbol;
  final String assetClass;
  final double value;

  const InvestmentHolding({
    required this.name,
    this.tickerSymbol,
    required this.assetClass,
    required this.value,
  });
}

class LiabilityItem {
  final String name;
  final String category;
  final double value;

  const LiabilityItem({
    required this.name,
    required this.category,
    required this.value,
  });
}

class NetWorthTrendPoint {
  final String date;
  final double netWorth;

  const NetWorthTrendPoint({required this.date, required this.netWorth});
}

class NetWorthSummary {
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final double bankBalances;
  final double investments;
  final double crypto;
  final double otherSavings;
  final double creditCardDebt;
  final double loans;
  final double mortgage;
  final List<InvestmentHolding> investmentHoldings;
  final List<LiabilityItem> liabilityItems;
  final List<NetWorthTrendPoint> trend;
  final double changeAmount;
  final double changePct;
  final String insight;

  const NetWorthSummary({
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.bankBalances,
    required this.investments,
    required this.crypto,
    required this.otherSavings,
    required this.creditCardDebt,
    required this.loans,
    required this.mortgage,
    required this.investmentHoldings,
    required this.liabilityItems,
    required this.trend,
    required this.changeAmount,
    required this.changePct,
    required this.insight,
  });
}

class NetWorthProjectionPoint {
  final int month;
  final String date;
  final double netWorth;

  const NetWorthProjectionPoint({
    required this.month,
    required this.date,
    required this.netWorth,
  });
}

class NetWorthProjection {
  final int months;
  final double startingNetWorth;
  final double monthlyContributionDelta;
  final List<NetWorthProjectionPoint> baseline;
  final List<NetWorthProjectionPoint> scenario;
  final double baselineEnd;
  final double scenarioEnd;
  final double difference;
  final String insight;

  const NetWorthProjection({
    required this.months,
    required this.startingNetWorth,
    required this.monthlyContributionDelta,
    required this.baseline,
    required this.scenario,
    required this.baselineEnd,
    required this.scenarioEnd,
    required this.difference,
    required this.insight,
  });
}
