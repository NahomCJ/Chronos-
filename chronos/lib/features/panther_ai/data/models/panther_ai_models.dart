import '../../domain/entities/ai_alert.dart';
import '../../domain/entities/chat_response.dart';
import '../../domain/entities/affordability_result.dart';
import '../../domain/entities/net_worth.dart';
import '../../domain/entities/spending_summary.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/marketplace_product.dart';
import '../../domain/entities/payment_authorization.dart';

class AiAlertModel {
  final String id;
  final String type;
  final String domain;
  final String title;
  final String message;
  final bool dismissed;
  final DateTime createdAt;

  AiAlertModel({
    required this.id,
    required this.type,
    required this.domain,
    required this.title,
    required this.message,
    required this.dismissed,
    required this.createdAt,
  });

  factory AiAlertModel.fromJson(Map<String, dynamic> json) => AiAlertModel(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'INFO',
        domain: json['domain'] as String? ?? 'BANKING',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        dismissed: json['dismissed'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  AiAlert toEntity() => AiAlert(
        id: id,
        type: type,
        domain: domain,
        title: title,
        message: message,
        dismissed: dismissed,
        createdAt: createdAt,
      );
}

class ChatResponseModel {
  final String reply;
  final String domain;
  final String userLevel;
  final DateTime timestamp;

  ChatResponseModel({
    required this.reply,
    required this.domain,
    required this.userLevel,
    required this.timestamp,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) =>
      ChatResponseModel(
        reply: json['reply'] as String? ?? '',
        domain: json['domain'] as String? ?? 'GENERAL',
        userLevel: json['userLevel'] as String? ?? 'BEGINNER',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );

  ChatResponse toEntity() => ChatResponse(
        reply: reply,
        domain: domain,
        userLevel: userLevel,
        timestamp: timestamp,
      );
}

class AffordabilityResultModel {
  final String verdict;
  final String summary;
  final double? safeAmount;

  AffordabilityResultModel({
    required this.verdict,
    required this.summary,
    this.safeAmount,
  });

  factory AffordabilityResultModel.fromJson(Map<String, dynamic> json) {
    final raw = json['safeAmount'] ?? json['safe_amount'];
    return AffordabilityResultModel(
      verdict: json['verdict'] as String? ??
          json['recommendation'] as String? ??
          'UNKNOWN',
      summary: json['summary'] as String? ?? json['reply'] as String? ?? '',
      safeAmount: raw != null ? (raw as num).toDouble() : null,
    );
  }

  AffordabilityResult toEntity() => AffordabilityResult(
        verdict: verdict,
        summary: summary,
        safeAmount: safeAmount,
      );
}

// ── AiAlert from warnings-history ────────────────────────────────────────────

class WarningItemModel {
  final String id;
  final String level;
  final String message;
  final String source;
  final String timestamp;

  WarningItemModel({
    required this.id,
    required this.level,
    required this.message,
    required this.source,
    required this.timestamp,
  });

  factory WarningItemModel.fromJson(Map<String, dynamic> json) =>
      WarningItemModel(
        id: json['id'] as String? ?? '',
        level: json['level'] as String? ?? 'LOW',
        message: json['message'] as String? ?? '',
        source: json['source'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
      );

  AiAlert toEntity() => AiAlert(
        id: id,
        type: level,
        domain: source,
        title: level,
        message: message,
        dismissed: false,
        createdAt: DateTime.tryParse(timestamp) ?? DateTime.now(),
      );
}

// ── Spending Summary ──────────────────────────────────────────────────────────

class SpendingCategoryModel {
  final String name;
  final double total;
  final double percentage;
  final String color;
  final List<String> topMerchants;

  SpendingCategoryModel({
    required this.name,
    required this.total,
    required this.percentage,
    required this.color,
    required this.topMerchants,
  });

  factory SpendingCategoryModel.fromJson(Map<String, dynamic> json) =>
      SpendingCategoryModel(
        name: json['name'] as String? ?? '',
        total: (json['total'] as num? ?? 0).toDouble(),
        percentage: (json['percentage'] as num? ?? 0).toDouble(),
        color: json['color'] as String? ?? '#888888',
        topMerchants: (json['top_merchants'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  SpendingCategory toEntity() => SpendingCategory(
        name: name,
        total: total,
        percentage: percentage,
        color: color,
        topMerchants: topMerchants,
      );
}

class SpendingSummaryModel {
  final double totalSpent;
  final int transactionCount;
  final double dailyAverage;
  final List<SpendingCategoryModel> byCategory;

  SpendingSummaryModel({
    required this.totalSpent,
    required this.transactionCount,
    required this.dailyAverage,
    required this.byCategory,
  });

  factory SpendingSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? json;
    final cats = (json['by_category'] as List<dynamic>? ?? [])
        .map((e) =>
            SpendingCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return SpendingSummaryModel(
      totalSpent: (summary['total_spent'] as num? ?? 0).toDouble(),
      transactionCount: summary['transaction_count'] as int? ?? 0,
      dailyAverage: (summary['daily_average'] as num? ?? 0).toDouble(),
      byCategory: cats,
    );
  }

  SpendingSummary toEntity() => SpendingSummary(
        totalSpent: totalSpent,
        transactionCount: transactionCount,
        dailyAverage: dailyAverage,
        byCategory: byCategory.map((c) => c.toEntity()).toList(),
      );
}

// ── Transaction ───────────────────────────────────────────────────────────────

class TransactionModel {
  final String id;
  final String merchantName;
  final double amount;
  final String date;
  final String subcategory;

  TransactionModel({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.subcategory,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String? ?? '',
        merchantName: json['merchant_name'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toDouble(),
        date: json['date'] as String? ?? '',
        subcategory: json['subcategory'] as String? ?? '',
      );

  PantherTransaction toEntity() => PantherTransaction(
        id: id,
        merchantName: merchantName,
        amount: amount,
        date: date,
        subcategory: subcategory,
      );
}

// ── Marketplace Product ───────────────────────────────────────────────────────

class MarketplaceProductModel {
  final String productId;
  final String name;
  final double price;
  final String vendor;
  final bool bnplEligible;
  final int bnplScore;
  final double? rating;
  final bool inStock;

  MarketplaceProductModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.vendor,
    required this.bnplEligible,
    required this.bnplScore,
    this.rating,
    required this.inStock,
  });

  factory MarketplaceProductModel.fromJson(Map<String, dynamic> json) =>
      MarketplaceProductModel(
        productId: json['product_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        price: (json['price'] as num? ?? 0).toDouble(),
        vendor: json['vendor'] as String? ?? '',
        bnplEligible: json['bnpl_eligible'] as bool? ?? false,
        bnplScore: json['bnpl_score'] as int? ?? 0,
        rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
        inStock: json['in_stock'] as bool? ?? true,
      );

  MarketplaceProduct toEntity() => MarketplaceProduct(
        productId: productId,
        name: name,
        price: price,
        vendor: vendor,
        bnplEligible: bnplEligible,
        bnplScore: bnplScore,
        rating: rating,
        inStock: inStock,
      );
}

// ── Payment Authorization ─────────────────────────────────────────────────────

class CashFlowWarningModel {
  final bool isRisky;
  final String riskLevel;
  final String warningMessage;
  final double projectedBalance;

  CashFlowWarningModel({
    required this.isRisky,
    required this.riskLevel,
    required this.warningMessage,
    required this.projectedBalance,
  });

  factory CashFlowWarningModel.fromJson(Map<String, dynamic> json) =>
      CashFlowWarningModel(
        isRisky: json['is_risky'] as bool? ?? false,
        riskLevel: json['risk_level'] as String? ?? 'LOW',
        warningMessage: json['warning_message'] as String? ?? '',
        projectedBalance:
            (json['projected_balance'] as num? ?? 0).toDouble(),
      );

  CashFlowWarning toEntity() => CashFlowWarning(
        isRisky: isRisky,
        riskLevel: riskLevel,
        warningMessage: warningMessage,
        projectedBalance: projectedBalance,
      );
}

class PaymentAuthorizationModel {
  final String authorizationId;
  final String status;
  final CashFlowWarningModel? cashFlow;
  final String combinedMessage;

  PaymentAuthorizationModel({
    required this.authorizationId,
    required this.status,
    this.cashFlow,
    required this.combinedMessage,
  });

  factory PaymentAuthorizationModel.fromJson(Map<String, dynamic> json) {
    final warning = json['warning'] as Map<String, dynamic>?;
    final cfRaw = warning?['cash_flow'] as Map<String, dynamic>?;
    return PaymentAuthorizationModel(
      authorizationId: json['authorization_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      cashFlow: cfRaw != null ? CashFlowWarningModel.fromJson(cfRaw) : null,
      combinedMessage: warning?['combined_message'] as String? ?? '',
    );
  }

  PaymentAuthorization toEntity() => PaymentAuthorization(
        authorizationId: authorizationId,
        status: status,
        cashFlow: cashFlow?.toEntity(),
        combinedMessage: combinedMessage,
      );
}

// ── Net Worth ────────────────────────────────────────────────────────────

class InvestmentHoldingModel {
  final String name;
  final String? tickerSymbol;
  final String assetClass;
  final double value;

  const InvestmentHoldingModel({
    required this.name,
    this.tickerSymbol,
    required this.assetClass,
    required this.value,
  });

  factory InvestmentHoldingModel.fromJson(Map<String, dynamic> json) {
    return InvestmentHoldingModel(
      name: json['name'] as String? ?? 'Holding',
      tickerSymbol: json['ticker_symbol'] as String?,
      assetClass: json['asset_class'] as String? ?? 'other',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  InvestmentHolding toEntity() => InvestmentHolding(
        name: name,
        tickerSymbol: tickerSymbol,
        assetClass: assetClass,
        value: value,
      );
}

class LiabilityItemModel {
  final String name;
  final String category;
  final double value;

  const LiabilityItemModel({
    required this.name,
    required this.category,
    required this.value,
  });

  factory LiabilityItemModel.fromJson(Map<String, dynamic> json) {
    return LiabilityItemModel(
      name: json['name'] as String? ?? 'Liability',
      category: json['category'] as String? ?? 'other',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  LiabilityItem toEntity() =>
      LiabilityItem(name: name, category: category, value: value);
}

class NetWorthTrendPointModel {
  final String date;
  final double netWorth;

  const NetWorthTrendPointModel({required this.date, required this.netWorth});

  factory NetWorthTrendPointModel.fromJson(Map<String, dynamic> json) {
    return NetWorthTrendPointModel(
      date: json['date'] as String? ?? '',
      netWorth: (json['net_worth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  NetWorthTrendPoint toEntity() =>
      NetWorthTrendPoint(date: date, netWorth: netWorth);
}

class NetWorthSummaryModel {
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
  final List<InvestmentHoldingModel> investmentHoldings;
  final List<LiabilityItemModel> liabilityItems;
  final List<NetWorthTrendPointModel> trend;
  final double changeAmount;
  final double changePct;
  final String insight;

  const NetWorthSummaryModel({
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

  factory NetWorthSummaryModel.fromDashboardJson(Map<String, dynamic> json) {
    final netWorthJson = json['net_worth'] as Map<String, dynamic>? ?? {};
    final assets =
        netWorthJson['assets_breakdown'] as Map<String, dynamic>? ?? {};
    final liabilities =
        netWorthJson['liabilities_breakdown'] as Map<String, dynamic>? ?? {};
    final holdings = netWorthJson['investment_holdings'] as List<dynamic>? ?? [];
    final liabilityItems =
        netWorthJson['liability_items'] as List<dynamic>? ?? [];
    final trendJson = json['trend'] as Map<String, dynamic>? ?? {};
    final dataPoints = trendJson['data_points'] as List<dynamic>? ?? [];

    return NetWorthSummaryModel(
      netWorth: (netWorthJson['net_worth'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (netWorthJson['total_assets'] as num?)?.toDouble() ?? 0.0,
      totalLiabilities:
          (netWorthJson['total_liabilities'] as num?)?.toDouble() ?? 0.0,
      bankBalances: (assets['bank_balances'] as num?)?.toDouble() ?? 0.0,
      investments: (assets['investments'] as num?)?.toDouble() ?? 0.0,
      crypto: (assets['crypto'] as num?)?.toDouble() ?? 0.0,
      otherSavings: (assets['other_savings'] as num?)?.toDouble() ?? 0.0,
      creditCardDebt:
          (liabilities['credit_card_debt'] as num?)?.toDouble() ?? 0.0,
      loans: (liabilities['loans'] as num?)?.toDouble() ?? 0.0,
      mortgage: (liabilities['mortgage'] as num?)?.toDouble() ?? 0.0,
      investmentHoldings: holdings
          .map((e) =>
              InvestmentHoldingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      liabilityItems: liabilityItems
          .map((e) => LiabilityItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      trend: dataPoints
          .map((e) =>
              NetWorthTrendPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      changeAmount: (trendJson['change_amount'] as num?)?.toDouble() ?? 0.0,
      changePct: (trendJson['change_pct'] as num?)?.toDouble() ?? 0.0,
      insight: netWorthJson['insight'] as String? ?? '',
    );
  }

  NetWorthSummary toEntity() => NetWorthSummary(
        netWorth: netWorth,
        totalAssets: totalAssets,
        totalLiabilities: totalLiabilities,
        bankBalances: bankBalances,
        investments: investments,
        crypto: crypto,
        otherSavings: otherSavings,
        creditCardDebt: creditCardDebt,
        loans: loans,
        mortgage: mortgage,
        investmentHoldings:
            investmentHoldings.map((e) => e.toEntity()).toList(),
        liabilityItems: liabilityItems.map((e) => e.toEntity()).toList(),
        trend: trend.map((e) => e.toEntity()).toList(),
        changeAmount: changeAmount,
        changePct: changePct,
        insight: insight,
      );
}

class NetWorthProjectionPointModel {
  final int month;
  final String date;
  final double netWorth;

  const NetWorthProjectionPointModel({
    required this.month,
    required this.date,
    required this.netWorth,
  });

  factory NetWorthProjectionPointModel.fromJson(Map<String, dynamic> json) {
    return NetWorthProjectionPointModel(
      month: (json['month'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
      netWorth: (json['net_worth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  NetWorthProjectionPoint toEntity() =>
      NetWorthProjectionPoint(month: month, date: date, netWorth: netWorth);
}

class NetWorthProjectionModel {
  final int months;
  final double startingNetWorth;
  final double monthlyContributionDelta;
  final List<NetWorthProjectionPointModel> baseline;
  final List<NetWorthProjectionPointModel> scenario;
  final double baselineEnd;
  final double scenarioEnd;
  final double difference;
  final String insight;

  const NetWorthProjectionModel({
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

  factory NetWorthProjectionModel.fromJson(Map<String, dynamic> json) {
    final assumptions = json['assumptions'] as Map<String, dynamic>? ?? {};
    final atEnd =
        json['projected_net_worth_at_end'] as Map<String, dynamic>? ?? {};
    final baseline = json['baseline_projection'] as List<dynamic>? ?? [];
    final scenario = json['scenario_projection'] as List<dynamic>? ?? [];

    return NetWorthProjectionModel(
      months: (json['months'] as num?)?.toInt() ?? 0,
      startingNetWorth:
          (json['starting_net_worth'] as num?)?.toDouble() ?? 0.0,
      monthlyContributionDelta:
          (assumptions['monthly_contribution_delta'] as num?)?.toDouble() ??
              0.0,
      baseline: baseline
          .map((e) => NetWorthProjectionPointModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      scenario: scenario
          .map((e) => NetWorthProjectionPointModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      baselineEnd: (atEnd['baseline'] as num?)?.toDouble() ?? 0.0,
      scenarioEnd: (atEnd['scenario'] as num?)?.toDouble() ?? 0.0,
      difference: (atEnd['difference'] as num?)?.toDouble() ?? 0.0,
      insight: json['insight'] as String? ?? '',
    );
  }

  NetWorthProjection toEntity() => NetWorthProjection(
        months: months,
        startingNetWorth: startingNetWorth,
        monthlyContributionDelta: monthlyContributionDelta,
        baseline: baseline.map((e) => e.toEntity()).toList(),
        scenario: scenario.map((e) => e.toEntity()).toList(),
        baselineEnd: baselineEnd,
        scenarioEnd: scenarioEnd,
        difference: difference,
        insight: insight,
      );
}
