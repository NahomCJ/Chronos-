import '../../domain/entities/ai_product_pick.dart';
import '../../domain/entities/credit_account.dart';
import '../../domain/entities/installment_plan.dart';
import '../../domain/entities/onboarding_entities.dart';
import '../../domain/entities/rewards_entities.dart';
import '../../domain/entities/shortcut_action.dart';
import '../../domain/entities/tickpay_notification.dart';
import '../../presentation/constants/tickpay_assets.dart';

/// In-memory demo data that reproduces the TickPay Figma designs 1:1.
///
/// Isolating the sample content here keeps the UI declarative and makes it
/// trivial to replace with a real remote source behind [TickpayRepository].
class TickpayLocalDataSource {
  const TickpayLocalDataSource();

  List<WalletOption> walletOptions() => const [
        WalletOption(
          id: 'tickpay',
          title: 'TickPay Wallet',
          iconAsset: TickpayAssets.dollarIcon,
          isRecommended: true,
        ),
        WalletOption(
          id: 'crypto',
          title: 'Crypto Wallet',
          iconAsset: TickpayAssets.scanQrIcon,
        ),
        WalletOption(
          id: 'bank',
          title: 'Bank Cards',
          iconAsset: TickpayAssets.creditIcon,
        ),
      ];

  List<VerificationStep> verificationSteps() => const [
        VerificationStep(
          title: 'Under Review',
          subtitle: 'Our team is verifying your information',
          isCompleted: true,
        ),
        VerificationStep(
          title: 'Verification Complete',
          subtitle: 'Your account has been verified',
          isCompleted: true,
        ),
      ];

  List<OnboardingHighlight> onboardingHighlights() => const [
        OnboardingHighlight(
          iconAsset: TickpayAssets.plansIcon,
          title: 'Smart Dashboard',
          subtitle: 'Track spending and manage payments',
        ),
        OnboardingHighlight(
          iconAsset: TickpayAssets.shopIcon,
          title: 'Easy Shopping',
          subtitle: 'Buy now, pay later in installments',
        ),
        OnboardingHighlight(
          iconAsset: TickpayAssets.rewardsIcon,
          title: 'AI Recommendations',
          subtitle: 'Personalized deals and insights',
        ),
      ];

  CreditAccount creditAccount() => const CreditAccount(
        availableCredit: 3150,
        creditLimit: 5000,
        creditUsed: 1850,
        activePlansAmount: 1629,
        pendingChargesAmount: 221,
      );

  List<InstallmentPlan> activePlans() => const [
        InstallmentPlan(
          id: 'amazon-9012',
          merchant: 'Amazon',
          reference: '#9012',
          logoAsset: TickpayAssets.amazon,
          category: 'Electronics',
          totalAmount: 599,
          paymentsMade: 3,
          paymentsTotal: 4,
          paidAmount: 449.25,
          remainingAmount: 149.75,
          nextPaymentDate: 'Dec 28, 2026',
          nextPaymentAmount: 149.75,
          isDueSoon: true,
        ),
        InstallmentPlan(
          id: 'nike-9012',
          merchant: 'Nike',
          reference: '#9012',
          logoAsset: TickpayAssets.nike,
          category: 'Fashion',
          totalAmount: 450,
          paymentsMade: 2,
          paymentsTotal: 3,
          paidAmount: 300,
          remainingAmount: 150,
          nextPaymentDate: 'Jan 5, 2027',
          nextPaymentAmount: 150,
        ),
        InstallmentPlan(
          id: 'apple-store',
          merchant: 'Apple Store',
          logoAsset: TickpayAssets.airpods,
          category: 'Electronics',
          totalAmount: 1299,
          paymentsMade: 2,
          paymentsTotal: 4,
          paidAmount: 649.50,
          remainingAmount: 649.50,
          nextPaymentDate: 'Jan 15, 2027',
          nextPaymentAmount: 324.75,
        ),
        InstallmentPlan(
          id: 'ikea',
          merchant: 'IKEA',
          logoAsset: TickpayAssets.shopIcon,
          category: 'Home',
          totalAmount: 850,
          paymentsMade: 1,
          paymentsTotal: 5,
          paidAmount: 170,
          remainingAmount: 680,
          nextPaymentDate: 'Jan 20, 2027',
          nextPaymentAmount: 170,
        ),
      ];

  List<AiProductPick> aiPicks() => const [
        AiProductPick(
          title: 'Apple AirPods Pro',
          imageAsset: TickpayAssets.airpods,
          price: 249,
          trendBadge: '+27.3%',
          isBnplEligible: true,
        ),
        AiProductPick(
          title: 'Nike Air Max',
          imageAsset: TickpayAssets.nikeAirMax,
          price: 189,
          trendBadge: '+25.0%',
        ),
      ];

  List<CreditActivity> recentActivity() => const [
        CreditActivity(
          merchant: 'Amazon',
          date: 'Dec 20',
          category: 'Shopping',
          amount: 149.75,
          isCredit: false,
        ),
        CreditActivity(
          merchant: 'Payment Received',
          date: 'Dec 18',
          category: 'Payment',
          amount: 300,
          isCredit: true,
        ),
        CreditActivity(
          merchant: 'Nike',
          date: 'Dec 15',
          category: 'Shopping',
          amount: 150,
          isCredit: false,
        ),
        CreditActivity(
          merchant: 'Apple Store',
          date: 'Dec 10',
          category: 'Electronics',
          amount: 324.75,
          isCredit: false,
        ),
      ];

  List<TickpayNotification> notifications() => const [
        TickpayNotification(
          type: TickpayNotificationType.payment,
          title: 'Payment',
          message: 'Amazon payment of \$149.75 is due on Dec 28',
          time: '2 hours ago',
          isUnread: true,
          isImportant: true,
        ),
        TickpayNotification(
          type: TickpayNotificationType.offer,
          title: 'Holiday Sale Alert',
          message: 'Save 30% on electronics at Best Buy - matches your interests',
          time: '1 day ago',
          isUnread: true,
        ),
        TickpayNotification(
          type: TickpayNotificationType.approval,
          title: 'Purchase Approved',
          message: 'Your \$450 purchase at Nike has been approved',
          time: '3 days ago',
        ),
        TickpayNotification(
          type: TickpayNotificationType.info,
          title: 'Credit Limit Increased',
          message: 'Visa card ending 1234 charged \$220.50 at Grocery Express',
          time: '30 days ago',
        ),
        TickpayNotification(
          type: TickpayNotificationType.payment,
          title: 'Payment Successful',
          message: 'Electricity bill of \$89.20 paid successfully on Dec 25',
          time: '1 day ago',
        ),
        TickpayNotification(
          type: TickpayNotificationType.offer,
          title: 'Smart Spending Tip',
          message: 'Refund of \$45.00 issued for returned item from BestBuy',
          time: '4 hours ago',
        ),
      ];

  RewardSummary rewardSummary() => const RewardSummary(
        points: 2450,
        pointsValue: 24.50,
        cashback: 156.75,
        tier: 'Gold Member',
      );

  List<RewardCampaign> rewardCampaigns() => const [
        RewardCampaign(
          title: 'Holiday Shopping Bonus',
          description: 'Earn 3x points on all purchases until Dec 31',
          progressCurrent: 450,
          progressTotal: 1000,
          pointsToGo: '55000 points to go',
        ),
        RewardCampaign(
          title: 'Cashback Streak',
          description: 'Make 5 on-time payments for bonus cashback',
          progressCurrent: 4,
          progressTotal: 5,
          pointsToGo: '100 points to go',
        ),
        RewardCampaign(
          title: 'Referral Rewards',
          description: 'Invite friends and earn \$25 per referral',
          progressCurrent: 1,
          progressTotal: 3,
          pointsToGo: '200 points to go',
        ),
      ];

  List<RewardActivity> rewardActivity() => const [
        RewardActivity(title: 'Purchase at Amazon', date: 'Dec 20', points: 125),
        RewardActivity(title: 'Cashback Applied', date: 'Dec 18', points: -500),
        RewardActivity(title: 'On-time Payment Bonus', date: 'Dec 15', points: 50),
      ];

  List<ShortcutAction> shortcuts() => const [
        ShortcutAction(label: 'Shop', iconAsset: TickpayAssets.shopIcon),
        ShortcutAction(label: 'Pay Bills', iconAsset: TickpayAssets.payBillsIcon),
        ShortcutAction(label: 'Transfer', iconAsset: TickpayAssets.transferIcon),
        ShortcutAction(label: 'Scan QR', iconAsset: TickpayAssets.scanQrIcon),
        ShortcutAction(label: 'Rewards', iconAsset: TickpayAssets.rewardsIcon),
        ShortcutAction(label: 'Alerts', iconAsset: TickpayAssets.alertsIcon),
        ShortcutAction(label: 'Credit', iconAsset: TickpayAssets.creditIcon),
        ShortcutAction(label: 'Plans', iconAsset: TickpayAssets.plansIcon),
        ShortcutAction(label: 'Settings', iconAsset: TickpayAssets.settingIcon),
      ];
}
