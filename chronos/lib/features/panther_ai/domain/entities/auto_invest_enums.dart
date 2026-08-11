/// Enums for the "Auto-Invest with Chris" feature, mapped 1:1 to the
/// UPPER_SNAKE_CASE string values the backend contract uses
/// (`/api/v1/auto-invest/*`). Each enum carries a `toApiValue()` instance
/// method plus a `fromApiValue()` static method on its extension, matching
/// the app-wide string-mapping convention used by `RouteConstantsX`.
library;

enum AutoInvestRiskProfile { conservative, balanced, aggressive }

extension AutoInvestRiskProfileX on AutoInvestRiskProfile {
  String toApiValue() {
    switch (this) {
      case AutoInvestRiskProfile.conservative:
        return 'CONSERVATIVE';
      case AutoInvestRiskProfile.balanced:
        return 'BALANCED';
      case AutoInvestRiskProfile.aggressive:
        return 'AGGRESSIVE';
    }
  }

  static AutoInvestRiskProfile fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'CONSERVATIVE':
        return AutoInvestRiskProfile.conservative;
      case 'AGGRESSIVE':
        return AutoInvestRiskProfile.aggressive;
      case 'BALANCED':
      default:
        return AutoInvestRiskProfile.balanced;
    }
  }
}

enum AutoInvestGoal { growth, income, retirement, shortTerm }

extension AutoInvestGoalX on AutoInvestGoal {
  String toApiValue() {
    switch (this) {
      case AutoInvestGoal.growth:
        return 'GROWTH';
      case AutoInvestGoal.income:
        return 'INCOME';
      case AutoInvestGoal.retirement:
        return 'RETIREMENT';
      case AutoInvestGoal.shortTerm:
        return 'SHORT_TERM';
    }
  }

  static AutoInvestGoal fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'INCOME':
        return AutoInvestGoal.income;
      case 'RETIREMENT':
        return AutoInvestGoal.retirement;
      case 'SHORT_TERM':
        return AutoInvestGoal.shortTerm;
      case 'GROWTH':
      default:
        return AutoInvestGoal.growth;
    }
  }
}

enum AutoInvestCadence { oneTime, weekly, biweekly, monthly }

extension AutoInvestCadenceX on AutoInvestCadence {
  String toApiValue() {
    switch (this) {
      case AutoInvestCadence.oneTime:
        return 'ONE_TIME';
      case AutoInvestCadence.weekly:
        return 'WEEKLY';
      case AutoInvestCadence.biweekly:
        return 'BIWEEKLY';
      case AutoInvestCadence.monthly:
        return 'MONTHLY';
    }
  }

  static AutoInvestCadence fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'WEEKLY':
        return AutoInvestCadence.weekly;
      case 'BIWEEKLY':
        return AutoInvestCadence.biweekly;
      case 'MONTHLY':
        return AutoInvestCadence.monthly;
      case 'ONE_TIME':
      default:
        return AutoInvestCadence.oneTime;
    }
  }

  String get label {
    switch (this) {
      case AutoInvestCadence.oneTime:
        return 'One-time';
      case AutoInvestCadence.weekly:
        return 'Weekly';
      case AutoInvestCadence.biweekly:
        return 'Biweekly';
      case AutoInvestCadence.monthly:
        return 'Monthly';
    }
  }
}

enum AutoInvestPlanStatus {
  pendingConfirmation,
  active,
  paused,
  completed,
  cancelled,
}

extension AutoInvestPlanStatusX on AutoInvestPlanStatus {
  String toApiValue() {
    switch (this) {
      case AutoInvestPlanStatus.pendingConfirmation:
        return 'PENDING_CONFIRMATION';
      case AutoInvestPlanStatus.active:
        return 'ACTIVE';
      case AutoInvestPlanStatus.paused:
        return 'PAUSED';
      case AutoInvestPlanStatus.completed:
        return 'COMPLETED';
      case AutoInvestPlanStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static AutoInvestPlanStatus fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACTIVE':
        return AutoInvestPlanStatus.active;
      case 'PAUSED':
        return AutoInvestPlanStatus.paused;
      case 'COMPLETED':
        return AutoInvestPlanStatus.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return AutoInvestPlanStatus.cancelled;
      case 'PENDING_CONFIRMATION':
      default:
        return AutoInvestPlanStatus.pendingConfirmation;
    }
  }

  String get label {
    switch (this) {
      case AutoInvestPlanStatus.pendingConfirmation:
        return 'Pending';
      case AutoInvestPlanStatus.active:
        return 'Active';
      case AutoInvestPlanStatus.paused:
        return 'Paused';
      case AutoInvestPlanStatus.completed:
        return 'Completed';
      case AutoInvestPlanStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum AutoInvestAssetClass { crypto, stock, etf }

extension AutoInvestAssetClassX on AutoInvestAssetClass {
  String toApiValue() {
    switch (this) {
      case AutoInvestAssetClass.crypto:
        return 'CRYPTO';
      case AutoInvestAssetClass.stock:
        return 'STOCK';
      case AutoInvestAssetClass.etf:
        return 'ETF';
    }
  }

  static AutoInvestAssetClass fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'STOCK':
        return AutoInvestAssetClass.stock;
      case 'ETF':
        return AutoInvestAssetClass.etf;
      case 'CRYPTO':
      default:
        return AutoInvestAssetClass.crypto;
    }
  }

  /// Crypto is the only asset class this app actually executes today — see
  /// chronos/CLAUDE.md and the auto-invest feature notes in FEATURES.md.
  bool get executesLive => this == AutoInvestAssetClass.crypto;
}

enum AutoInvestExecutionStatus { executed, planned, failed }

extension AutoInvestExecutionStatusX on AutoInvestExecutionStatus {
  String toApiValue() {
    switch (this) {
      case AutoInvestExecutionStatus.executed:
        return 'EXECUTED';
      case AutoInvestExecutionStatus.planned:
        return 'PLANNED';
      case AutoInvestExecutionStatus.failed:
        return 'FAILED';
    }
  }

  static AutoInvestExecutionStatus fromApiValue(String? value) {
    switch (value?.toUpperCase()) {
      case 'PLANNED':
        return AutoInvestExecutionStatus.planned;
      case 'FAILED':
        return AutoInvestExecutionStatus.failed;
      case 'EXECUTED':
      default:
        return AutoInvestExecutionStatus.executed;
    }
  }
}
