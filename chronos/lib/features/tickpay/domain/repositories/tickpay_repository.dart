import '../entities/ai_product_pick.dart';
import '../entities/credit_account.dart';
import '../entities/installment_plan.dart';
import '../entities/onboarding_entities.dart';
import '../entities/rewards_entities.dart';
import '../entities/shortcut_action.dart';
import '../entities/tickpay_notification.dart';

/// Contract the presentation layer depends on for all TickPay data.
///
/// The current implementation is backed by curated demo data that mirrors the
/// Figma designs. Swapping in a network/database source later only requires a
/// new implementation of this interface  no UI changes.
abstract class TickpayRepository {
  // Onboarding.
  List<WalletOption> getWalletOptions();
  List<VerificationStep> getVerificationSteps();
  List<OnboardingHighlight> getOnboardingHighlights();

  // Dashboard / credit.
  CreditAccount getCreditAccount();
  List<InstallmentPlan> getActivePlans();
  List<AiProductPick> getAiPicks();
  List<CreditActivity> getRecentActivity();

  // Notifications.
  List<TickpayNotification> getNotifications();

  // Rewards.
  RewardSummary getRewardSummary();
  List<RewardCampaign> getRewardCampaigns();
  List<RewardActivity> getRewardActivity();

  // Shortcuts.
  List<ShortcutAction> getShortcuts();
}
