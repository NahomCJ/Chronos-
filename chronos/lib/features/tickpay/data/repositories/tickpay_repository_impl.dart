import '../../domain/entities/ai_product_pick.dart';
import '../../domain/entities/credit_account.dart';
import '../../domain/entities/installment_plan.dart';
import '../../domain/entities/onboarding_entities.dart';
import '../../domain/entities/rewards_entities.dart';
import '../../domain/entities/shortcut_action.dart';
import '../../domain/entities/tickpay_notification.dart';
import '../../domain/repositories/tickpay_repository.dart';
import '../datasources/tickpay_local_data_source.dart';

/// Default [TickpayRepository] backed by [TickpayLocalDataSource].
class TickpayRepositoryImpl implements TickpayRepository {
  final TickpayLocalDataSource localDataSource;

  const TickpayRepositoryImpl(this.localDataSource);

  @override
  List<WalletOption> getWalletOptions() => localDataSource.walletOptions();

  @override
  List<VerificationStep> getVerificationSteps() =>
      localDataSource.verificationSteps();

  @override
  List<OnboardingHighlight> getOnboardingHighlights() =>
      localDataSource.onboardingHighlights();

  @override
  CreditAccount getCreditAccount() => localDataSource.creditAccount();

  @override
  List<InstallmentPlan> getActivePlans() => localDataSource.activePlans();

  @override
  List<AiProductPick> getAiPicks() => localDataSource.aiPicks();

  @override
  List<CreditActivity> getRecentActivity() => localDataSource.recentActivity();

  @override
  List<TickpayNotification> getNotifications() =>
      localDataSource.notifications();

  @override
  RewardSummary getRewardSummary() => localDataSource.rewardSummary();

  @override
  List<RewardCampaign> getRewardCampaigns() =>
      localDataSource.rewardCampaigns();

  @override
  List<RewardActivity> getRewardActivity() => localDataSource.rewardActivity();

  @override
  List<ShortcutAction> getShortcuts() => localDataSource.shortcuts();
}
