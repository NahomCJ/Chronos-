import '../../domain/entities/auto_invest.dart';
import '../../domain/entities/auto_invest_enums.dart';

abstract class AutoInvestState {
  const AutoInvestState();
}

class AutoInvestInitial extends AutoInvestState {
  const AutoInvestInitial();
}

/// Shown while checking for an existing plan (intro page) or loading the
/// dashboard.
class AutoInvestLoading extends AutoInvestState {
  const AutoInvestLoading();
}

/// The user has no active/pending plan — the intro page shows the pitch.
class AutoInvestNoPlan extends AutoInvestState {
  const AutoInvestNoPlan();
}

/// Holds the user's in-flight selections as they move through the
/// goals → amount → preview → review screens. Nothing is persisted to the
/// backend until [AutoInvestPlanConfirmed] is reached.
class AutoInvestWizardInProgress extends AutoInvestState {
  final AutoInvestRiskProfile? riskProfile;
  final AutoInvestGoal? goal;
  final double? amountUsd;
  final AutoInvestCadence cadence;
  final AutoInvestPreviewEntity? allocationPreview;
  final bool previewLoading;

  const AutoInvestWizardInProgress({
    this.riskProfile,
    this.goal,
    this.amountUsd,
    this.cadence = AutoInvestCadence.oneTime,
    this.allocationPreview,
    this.previewLoading = false,
  });

  bool get hasRiskAndGoal => riskProfile != null && goal != null;

  AutoInvestWizardInProgress copyWith({
    AutoInvestRiskProfile? riskProfile,
    AutoInvestGoal? goal,
    double? amountUsd,
    AutoInvestCadence? cadence,
    AutoInvestPreviewEntity? allocationPreview,
    bool? previewLoading,
  }) =>
      AutoInvestWizardInProgress(
        riskProfile: riskProfile ?? this.riskProfile,
        goal: goal ?? this.goal,
        amountUsd: amountUsd ?? this.amountUsd,
        cadence: cadence ?? this.cadence,
        allocationPreview: allocationPreview ?? this.allocationPreview,
        previewLoading: previewLoading ?? this.previewLoading,
      );
}

/// Round 1 just executed — `plan.latestRoundExecutions` has the per-leg
/// executed/planned/failed results for the success page.
class AutoInvestPlanConfirmed extends AutoInvestState {
  final AutoInvestPlanEntity plan;
  const AutoInvestPlanConfirmed(this.plan);
}

/// An existing plan, shown on the dashboard page.
class AutoInvestDashboardLoaded extends AutoInvestState {
  final AutoInvestPlanEntity plan;
  final bool actionLoading;
  final String? actionError;

  const AutoInvestDashboardLoaded(
    this.plan, {
    this.actionLoading = false,
    this.actionError,
  });

  AutoInvestDashboardLoaded copyWith({
    AutoInvestPlanEntity? plan,
    bool? actionLoading,
    String? actionError,
    bool clearError = false,
  }) =>
      AutoInvestDashboardLoaded(
        plan ?? this.plan,
        actionLoading: actionLoading ?? this.actionLoading,
        actionError: clearError ? null : (actionError ?? this.actionError),
      );
}

/// Wizard submission (or dashboard load) failed. Carries the wizard's
/// in-flight selections forward so a failed submit never wipes the user's
/// inputs — the review page can retry without sending the user back to
/// step one.
class AutoInvestError extends AutoInvestState {
  final String message;
  final AutoInvestWizardInProgress? wizard;
  const AutoInvestError(this.message, {this.wizard});
}
