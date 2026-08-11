import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auto_invest.dart';
import '../../domain/entities/auto_invest_enums.dart';
import '../../domain/usecases/get_allocation_preview.dart';
import '../../domain/usecases/manage_auto_invest_plan.dart';
import 'auto_invest_state.dart';

/// Drives the whole "Auto-Invest with Chris" flow — the 4-step wizard
/// (goals → amount → preview → review/confirm) and the post-confirmation
/// dashboard. Registered as a lazy singleton (see `panther_ai_di.dart`) and
/// provided via `BlocProvider.value` at every auto-invest route, so wizard
/// selections survive `context.push` navigation between steps instead of
/// resetting on every screen (the app's other multi-step cubits, e.g.
/// `TickpayAccountCubit`, don't need this since each of their screens is
/// independently reloadable).
class AutoInvestCubit extends Cubit<AutoInvestState> {
  final GetAllocationPreview _getAllocationPreview;
  final CreateAutoInvestPlan _createPlan;
  final ConfirmAutoInvestPlan _confirmPlan;
  final GetActiveAutoInvestPlan _getActivePlan;
  final GetAutoInvestPlan _getPlan;
  final PauseAutoInvestPlan _pausePlan;
  final ResumeAutoInvestPlan _resumePlan;
  final CancelAutoInvestPlan _cancelPlan;
  final TriggerNextInvestRound _triggerNextRound;

  AutoInvestCubit({
    required GetAllocationPreview getAllocationPreview,
    required CreateAutoInvestPlan createPlan,
    required ConfirmAutoInvestPlan confirmPlan,
    required GetActiveAutoInvestPlan getActivePlan,
    required GetAutoInvestPlan getPlan,
    required PauseAutoInvestPlan pausePlan,
    required ResumeAutoInvestPlan resumePlan,
    required CancelAutoInvestPlan cancelPlan,
    required TriggerNextInvestRound triggerNextRound,
  })  : _getAllocationPreview = getAllocationPreview,
        _createPlan = createPlan,
        _confirmPlan = confirmPlan,
        _getActivePlan = getActivePlan,
        _getPlan = getPlan,
        _pausePlan = pausePlan,
        _resumePlan = resumePlan,
        _cancelPlan = cancelPlan,
        _triggerNextRound = triggerNextRound,
        super(const AutoInvestInitial());

  // ── Intro / entry ──────────────────────────────────────────────────────

  /// Called on intro-page load: routes straight to the dashboard state if
  /// the user already has an active/pending plan, otherwise shows the pitch.
  Future<void> checkActivePlan() async {
    emit(const AutoInvestLoading());
    try {
      final plan = await _getActivePlan();
      emit(plan != null ? AutoInvestDashboardLoaded(plan) : const AutoInvestNoPlan());
    } catch (_) {
      // A failed existence-check shouldn't block a new user from starting
      // the pitch flow — fall back to "no plan" rather than an error state.
      emit(const AutoInvestNoPlan());
    }
  }

  /// Starts (or resumes) the wizard with a clean slate.
  void startWizard() => emit(const AutoInvestWizardInProgress());

  // ── Wizard steps ───────────────────────────────────────────────────────

  void selectRiskProfile(AutoInvestRiskProfile riskProfile) {
    emit(_wizardOrNew().copyWith(riskProfile: riskProfile));
  }

  void selectGoal(AutoInvestGoal goal) {
    emit(_wizardOrNew().copyWith(goal: goal));
  }

  void selectCadence(AutoInvestCadence cadence) {
    emit(_wizardOrNew().copyWith(cadence: cadence));
  }

  Future<void> loadAllocationPreview(double amountUsd) async {
    final wizard = _wizardOrNew().copyWith(amountUsd: amountUsd, previewLoading: true);
    emit(wizard);
    if (!wizard.hasRiskAndGoal) {
      emit(AutoInvestError(
        'Pick a risk profile and a goal first.',
        wizard: wizard.copyWith(previewLoading: false),
      ));
      return;
    }
    try {
      final preview = await _getAllocationPreview(
        riskProfile: wizard.riskProfile!,
        goal: wizard.goal!,
        amountUsd: amountUsd,
      );
      emit(wizard.copyWith(allocationPreview: preview, previewLoading: false));
    } catch (e) {
      emit(AutoInvestError(
        _friendlyError(e),
        wizard: wizard.copyWith(previewLoading: false),
      ));
    }
  }

  /// Creates the plan then immediately confirms round 1. Runs as one step
  /// from the review/confirm page's point of view; on failure the wizard
  /// selections are preserved on [AutoInvestError] so "Try again" doesn't
  /// send the user back to step one.
  Future<void> confirmPlan() async {
    final wizard = _currentWizard();
    if (wizard == null ||
        !wizard.hasRiskAndGoal ||
        wizard.amountUsd == null ||
        wizard.allocationPreview == null) {
      emit(AutoInvestError('Missing plan details — please start over.', wizard: wizard));
      return;
    }
    emit(wizard.copyWith(previewLoading: true));
    try {
      final created = await _createPlan(
        riskProfile: wizard.riskProfile!,
        goal: wizard.goal!,
        amountUsd: wizard.amountUsd!,
        cadence: wizard.cadence,
        allocations: wizard.allocationPreview!.allocations,
      );
      final confirmed = await _confirmPlan(created.id);
      emit(AutoInvestPlanConfirmed(confirmed));
    } catch (e) {
      emit(AutoInvestError(
        _friendlyError(e),
        wizard: wizard.copyWith(previewLoading: false),
      ));
    }
  }

  // ── Dashboard ──────────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    emit(const AutoInvestLoading());
    try {
      final plan = await _getActivePlan();
      if (plan == null) {
        emit(const AutoInvestNoPlan());
        return;
      }
      emit(AutoInvestDashboardLoaded(plan));
    } catch (e) {
      emit(AutoInvestError(_friendlyError(e)));
    }
  }

  Future<void> refreshPlan(String planId) => _runDashboardAction(() => _getPlan(planId));

  Future<void> investNextRound(String planId) =>
      _runDashboardAction(() => _triggerNextRound(planId));

  Future<void> togglePause(String planId, {required bool isPaused}) => _runDashboardAction(
        () => isPaused ? _resumePlan(planId) : _pausePlan(planId),
      );

  Future<void> cancelPlan(String planId) => _runDashboardAction(() => _cancelPlan(planId));

  Future<void> _runDashboardAction(Future<AutoInvestPlanEntity> Function() action) async {
    final current = state;
    if (current is! AutoInvestDashboardLoaded) return;
    emit(current.copyWith(actionLoading: true, clearError: true));
    try {
      final plan = await action();
      emit(AutoInvestDashboardLoaded(plan));
    } catch (e) {
      emit(current.copyWith(actionLoading: false, actionError: _friendlyError(e)));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  AutoInvestWizardInProgress _wizardOrNew() => _currentWizard() ?? const AutoInvestWizardInProgress();

  AutoInvestWizardInProgress? _currentWizard() {
    final current = state;
    if (current is AutoInvestWizardInProgress) return current;
    if (current is AutoInvestError) return current.wizard;
    return null;
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception: ') ? msg.substring('Exception: '.length) : msg;
  }
}
