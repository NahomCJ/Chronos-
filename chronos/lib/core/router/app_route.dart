import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/phone_auth_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/transfer/presentation/pages/transfer_page.dart';
import '../../features/transfer/presentation/pages/select_method_page.dart';
import '../../features/transfer/presentation/pages/add_recipient_page.dart';
import '../../features/transfer/presentation/pages/enter_amount_page.dart';
import '../../features/transfer/presentation/pages/transfer_confirmation_page.dart';
import '../../features/transfer/presentation/pages/transfer_success_page.dart';
import '../../features/transfer/presentation/pages/pin_entry_page.dart';
import '../../features/transfer/presentation/pages/add_money_page.dart';
import '../../features/transfer/presentation/pages/bank_transfer_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/wallet/presentation/pages/find_atm_page.dart';
import '../../features/exchange/presentation/pages/exchange_page.dart';
import '../../features/exchange/presentation/pages/select_currency_page.dart';
import '../../features/exchange/presentation/pages/enter_amount_page.dart'
    as exchange;
import '../../features/exchange/presentation/pages/review_exchange_page.dart';
import '../../features/exchange/presentation/pages/exchange_processing_page.dart';
import '../../features/exchange/presentation/pages/exchange_success_page.dart';
import '../../features/blockhub/presentation/pages/blockhub_page.dart';
import '../../features/panther_ai/presentation/pages/panther_ai_page.dart';
import '../../features/panther_ai/presentation/pages/rebalance/insight_details_page.dart';
import '../../features/panther_ai/presentation/pages/rebalance/rebalance_confirmation_page.dart';
import '../../features/panther_ai/presentation/pages/rebalance/rebalance_success_page.dart';
import '../../features/panther_ai/presentation/pages/simulate/simulate_rebalance_page.dart';
// Ethereum flow imports
import '../../features/panther_ai/presentation/pages/ethereum/ethereum_detail_page.dart'
    as eth_flow;
import '../../features/panther_ai/presentation/pages/ethereum/trading_assistant_page.dart'
    as eth_flow;
import '../../features/panther_ai/presentation/pages/ethereum/portfolio_intelligence_page.dart'
    as eth_flow;
import '../../features/panther_ai/presentation/pages/ethereum/simulate_rebalance_page.dart'
    as eth_flow;
import '../../features/panther_ai/presentation/pages/ethereum/rebalance_confirmation_page.dart'
    as eth_flow;
import '../../features/panther_ai/presentation/pages/ethereum/rebalance_success_page.dart'
    as eth_flow;
import '../../features/panther_ai/presentation/pages/tickpay_ai_page.dart';
import '../../features/panther_ai/presentation/pages/analysis/full_portfolio_analysis_page.dart';
import '../../features/panther_ai/presentation/pages/payment_plan_page.dart';
import '../../features/panther_ai/presentation/pages/product_discovery_page.dart';
import '../../features/panther_ai/presentation/pages/affordability_check_page.dart';
import '../../features/panther_ai/presentation/pages/panther_ai_settings_page.dart';
import '../../features/panther_ai/presentation/pages/panther_ai_chat_page.dart';
import '../../features/panther_ai/presentation/pages/market_intelligence_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_welcome_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_verification_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_link_wallets_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_dashboard_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_credit_overview_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_active_plans_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_notifications_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_rewards_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_shortcuts_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_setup_complete_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_discover_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_search_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_ai_picks_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_product_detail_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_shop_detail_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_bnpl_checkout_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_order_confirmed_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_order_history_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_upcoming_payments_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_repay_now_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_payment_history_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_alerts_page.dart';
import '../../features/tickpay/presentation/pages/tickpay_auto_pay_page.dart';
import '../../features/tickpay/presentation/utils/tickpay_media.dart';
import '../widgets/custom_bottom_nav.dart';
import 'route_constants.dart';
import '../di/app_di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteConstants.splash.toPath,
  debugLogDiagnostics: true,
  routes: [
    // ── Auth / onboarding (no shell) ──────────────────────────────────────
    GoRoute(
      path: RouteConstants.splash.toPath,
      name: RouteConstants.splash.name,
      builder: (context, state) => const SplashRoute(),
    ),
    GoRoute(
      path: RouteConstants.onboarding.toPath,
      name: RouteConstants.onboarding.name,
      builder: (context, state) => const OnboardingRoute(),
    ),
    GoRoute(
      path: RouteConstants.signUp.toPath,
      name: RouteConstants.signUp.name,
      builder: (context, state) => const SignUpRoute(),
    ),
    GoRoute(
      path: RouteConstants.signIn.toPath,
      name: RouteConstants.signIn.name,
      builder:
          (context, state) => BlocProvider<AuthBloc>(
            create: (_) => sl<AuthBloc>(),
            child: const LoginPage(),
          ),
    ),
    GoRoute(
      path: RouteConstants.forgotPassword.toPath,
      name: RouteConstants.forgotPassword.name,
      builder:
          (context, state) => BlocProvider<AuthBloc>(
            create: (_) => sl<AuthBloc>(),
            child: const ForgotPasswordPage(),
          ),
    ),
    GoRoute(
      path: RouteConstants.resetPassword.toPath,
      name: RouteConstants.resetPassword.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>? ?? {};
        return BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
          child: ResetPasswordPage(
            email: extra['email'] ?? '',
            otp: extra['otp'] ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: RouteConstants.phoneAuth.toPath,
      name: RouteConstants.phoneAuth.name,
      builder: (context, state) => const PhoneAuthRoute(),
    ),

    // ── Detail / flow pages (no bottom nav) ──────────────────────────────
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.transfer.toPath,
      name: RouteConstants.transfer.name,
      builder: (context, state) => const TransferPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.selectMethod.toPath,
      name: RouteConstants.selectMethod.name,
      builder: (context, state) => const SelectMethodPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.addRecipient.toPath,
      name: RouteConstants.addRecipient.name,
      builder: (context, state) => const AddRecipientPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.enterAmount.toPath,
      name: RouteConstants.enterAmount.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return EnterAmountPage(
          recipientName: extra?['recipientName'] ?? 'Alex Johnson',
          method: extra?['method'] ?? 'Chronos User',
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.transferConfirmation.toPath,
      name: RouteConstants.transferConfirmation.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return TransferConfirmationPage(
          amount: extra?['amount'] ?? '0',
          recipientName: extra?['recipientName'] ?? 'Alex Johnson',
          method: extra?['method'] ?? 'Chronos User',
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.transferSuccess.toPath,
      name: RouteConstants.transferSuccess.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return TransferSuccessPage(
          amount: extra?['amount'] ?? '0.00',
          recipientName: extra?['recipientName'] ?? 'Unknown',
          method: extra?['method'] ?? 'Transfer',
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.pinEntry.toPath,
      name: RouteConstants.pinEntry.name,
      builder: (context, state) => const PinEntryPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.addMoney.toPath,
      name: RouteConstants.addMoney.name,
      builder: (context, state) => const AddMoneyPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.bankTransfer.toPath,
      name: RouteConstants.bankTransfer.name,
      builder: (context, state) => const BankTransferPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.wallet.toPath,
      name: RouteConstants.wallet.name,
      builder: (context, state) => const WalletPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.findAtm.toPath,
      name: RouteConstants.findAtm.name,
      builder: (context, state) => const FindAtmPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.exchange.toPath,
      name: RouteConstants.exchange.name,
      builder: (context, state) => const ExchangePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.selectCurrency.toPath,
      name: RouteConstants.selectCurrency.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SelectCurrencyPage(
          currentCurrency: extra?['currentCurrency'] ?? 'USD',
          isFromCurrency: extra?['isFromCurrency'] ?? true,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.enterExchangeAmount.toPath,
      name: RouteConstants.enterExchangeAmount.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return exchange.EnterAmountPage(
          fromCurrency: extra?['fromCurrency'] ?? 'USD',
          toCurrency: extra?['toCurrency'] ?? 'EUR',
          fromCurrencyName: extra?['fromCurrencyName'] ?? 'US Dollar',
          toCurrencyName: extra?['toCurrencyName'] ?? 'Euro',
          fromFlag: extra?['fromFlag'] ?? '🇺🇸',
          toFlag: extra?['toFlag'] ?? '🇪🇺',
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.reviewExchange.toPath,
      name: RouteConstants.reviewExchange.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ReviewExchangePage(
          fromCurrency: extra?['fromCurrency'] ?? 'USD',
          toCurrency: extra?['toCurrency'] ?? 'EUR',
          fromCurrencyName: extra?['fromCurrencyName'] ?? 'US Dollar',
          toCurrencyName: extra?['toCurrencyName'] ?? 'Euro',
          fromFlag: extra?['fromFlag'] ?? '🇺🇸',
          toFlag: extra?['toFlag'] ?? '🇪🇺',
          amount: extra?['amount'] ?? '0',
          isRateLocked: extra?['isRateLocked'] ?? false,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.exchangeProcessing.toPath,
      name: RouteConstants.exchangeProcessing.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ExchangeProcessingPage(
          fromCurrency: extra?['fromCurrency'] ?? 'USD',
          toCurrency: extra?['toCurrency'] ?? 'EUR',
          fromAmount: extra?['fromAmount'] ?? '0',
          toAmount: extra?['toAmount'] ?? '0',
          fromFlag: extra?['fromFlag'] ?? '🇺🇸',
          toFlag: extra?['toFlag'] ?? '🇪🇺',
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.exchangeSuccess.toPath,
      name: RouteConstants.exchangeSuccess.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ExchangeSuccessPage(
          fromCurrency: extra?['fromCurrency'] ?? 'USD',
          toCurrency: extra?['toCurrency'] ?? 'EUR',
          fromAmount: extra?['fromAmount'] ?? '0',
          toAmount: extra?['toAmount'] ?? '0',
          fromFlag: extra?['fromFlag'] ?? '🇺🇸',
          toFlag: extra?['toFlag'] ?? '🇪🇺',
        );
      },
    ),
    // Panther AI detail pages
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.insightDetails.toPath,
      name: RouteConstants.insightDetails.name,
      builder: (context, state) => const InsightDetailsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.rebalanceConfirmation.toPath,
      name: RouteConstants.rebalanceConfirmation.name,
      builder: (context, state) => const RebalanceConfirmationPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.rebalanceSuccess.toPath,
      name: RouteConstants.rebalanceSuccess.name,
      builder: (context, state) => const RebalanceSuccessPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.simulateRebalance.toPath,
      name: RouteConstants.simulateRebalance.name,
      builder: (context, state) => const SimulateRebalancePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.ethereumDetail.toPath,
      name: RouteConstants.ethereumDetail.name,
      builder: (context, state) => const eth_flow.EthFlowDetailPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tradingAssistant.toPath,
      name: RouteConstants.tradingAssistant.name,
      builder: (context, state) => const eth_flow.EthFlowTradingAssistantPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.portfolioIntelligence.toPath,
      name: RouteConstants.portfolioIntelligence.name,
      builder:
          (context, state) => const eth_flow.EthFlowPortfolioIntelligencePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.ethFlowDetail.toPath,
      name: RouteConstants.ethFlowDetail.name,
      builder: (context, state) => const eth_flow.EthFlowDetailPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.ethFlowTradingAssistant.toPath,
      name: RouteConstants.ethFlowTradingAssistant.name,
      builder: (context, state) => const eth_flow.EthFlowTradingAssistantPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.ethFlowPortfolioIntelligence.toPath,
      name: RouteConstants.ethFlowPortfolioIntelligence.name,
      builder:
          (context, state) => const eth_flow.EthFlowPortfolioIntelligencePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.ethFlowSimulateRebalance.toPath,
      name: RouteConstants.ethFlowSimulateRebalance.name,
      builder:
          (context, state) => const eth_flow.EthFlowSimulateRebalancePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.ethFlowRebalanceConfirmation.toPath,
      name: RouteConstants.ethFlowRebalanceConfirmation.name,
      builder:
          (context, state) => const eth_flow.EthFlowRebalanceConfirmationPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.ethFlowRebalanceSuccess.toPath,
      name: RouteConstants.ethFlowRebalanceSuccess.name,
      builder: (context, state) => const eth_flow.EthFlowRebalanceSuccessPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickPayAi.toPath,
      name: RouteConstants.tickPayAi.name,
      builder: (context, state) => const TickPayAiPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayWelcome.toPath,
      name: RouteConstants.tickpayWelcome.name,
      builder: (context, state) => const TickPayWelcomePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayVerification.toPath,
      name: RouteConstants.tickpayVerification.name,
      builder: (context, state) => const TickPayVerificationPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayLinkWallets.toPath,
      name: RouteConstants.tickpayLinkWallets.name,
      builder: (context, state) => const TickPayLinkWalletsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayCompletion.toPath,
      name: RouteConstants.tickpayCompletion.name,
      builder: (context, state) => const TickPaySetupCompletePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayDashboard.toPath,
      name: RouteConstants.tickpayDashboard.name,
      builder: (context, state) => const TickPayDashboardPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayCreditOverview.toPath,
      name: RouteConstants.tickpayCreditOverview.name,
      builder: (context, state) => const TickPayCreditOverviewPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayActivePlans.toPath,
      name: RouteConstants.tickpayActivePlans.name,
      builder: (context, state) => const TickPayActivePlansPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayNotifications.toPath,
      name: RouteConstants.tickpayNotifications.name,
      builder: (context, state) => const TickPayNotificationsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayRewards.toPath,
      name: RouteConstants.tickpayRewards.name,
      builder: (context, state) => const TickPayRewardsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayShortcuts.toPath,
      name: RouteConstants.tickpayShortcuts.name,
      builder: (context, state) => const TickpayShortcutsPage(),
    ),
    // ── New TickPay screens ───────────────────────────────────────────────
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpaySetupComplete.toPath,
      name: RouteConstants.tickpaySetupComplete.name,
      builder: (context, state) => const TickPaySetupCompletePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayDiscover.toPath,
      name: RouteConstants.tickpayDiscover.name,
      builder: (context, state) => const TickPayDiscoverPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpaySearch.toPath,
      name: RouteConstants.tickpaySearch.name,
      builder: (context, state) => const TickPaySearchPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayAiPicks.toPath,
      name: RouteConstants.tickpayAiPicks.name,
      builder: (context, state) => const TickPayAiPicksPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayProductDetail.toPath,
      name: RouteConstants.tickpayProductDetail.name,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return TickPayProductDetailPage(
          name: extra?['name'] ?? 'iPhone 15 Pro',
          price: extra?['price'] ?? '\$999',
          asset: extra?['asset'] ?? TickPayMedia.iphone15Pro,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayShopDetail.toPath,
      name: RouteConstants.tickpayShopDetail.name,
      builder: (context, state) => const TickPayShopDetailPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayBnplCheckout.toPath,
      name: RouteConstants.tickpayBnplCheckout.name,
      builder: (context, state) => const TickPayBnplCheckoutPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayOrderConfirmed.toPath,
      name: RouteConstants.tickpayOrderConfirmed.name,
      builder: (context, state) => const TickPayOrderConfirmedPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayOrderHistory.toPath,
      name: RouteConstants.tickpayOrderHistory.name,
      builder: (context, state) => const TickPayOrderHistoryPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayUpcomingPayments.toPath,
      name: RouteConstants.tickpayUpcomingPayments.name,
      builder: (context, state) => const TickPayUpcomingPaymentsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayRepayNow.toPath,
      name: RouteConstants.tickpayRepayNow.name,
      builder: (context, state) => const TickPayRepayNowPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayPaymentHistory.toPath,
      name: RouteConstants.tickpayPaymentHistory.name,
      builder: (context, state) => const TickPayPaymentHistoryPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayAlerts.toPath,
      name: RouteConstants.tickpayAlerts.name,
      builder: (context, state) => const TickPayAlertsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.tickpayAutoPay.toPath,
      name: RouteConstants.tickpayAutoPay.name,
      builder: (context, state) => const TickPayAutoPayPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.fullPortfolioAnalysis.toPath,
      name: RouteConstants.fullPortfolioAnalysis.name,
      builder: (context, state) => const FullPortfolioAnalysisPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.paymentPlan.toPath,
      name: RouteConstants.paymentPlan.name,
      builder: (context, state) => const PaymentPlanPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.productDiscovery.toPath,
      name: RouteConstants.productDiscovery.name,
      builder: (context, state) => const ProductDiscoveryPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.affordabilityCheck.toPath,
      name: RouteConstants.affordabilityCheck.name,
      builder: (context, state) => const AffordabilityCheckPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.marketIntelligence.toPath,
      name: RouteConstants.marketIntelligence.name,
      builder: (context, state) => const MarketIntelligencePage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.pantherAiSettings.toPath,
      name: RouteConstants.pantherAiSettings.name,
      builder: (context, state) => const PantherAiSettingsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.pantherAiChat.toPath,
      name: RouteConstants.pantherAiChat.name,
      builder: (context, state) => const PantherAiChatPage(),
    ),

    // ── Shell: only the 3 main tabs get the bottom nav ────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/background.png', fit: BoxFit.cover),
              ),
              child,
            ],
          ),
          extendBody: true,
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: _calculateSelectedIndex(state.matchedLocation),
            onItemSelected: (index) {
              switch (index) {
                case 0:
                  context.go(RouteConstants.home.toPath);
                  break;
                case 1:
                  context.go(RouteConstants.pantherAi.toPath);
                  break;
                case 2:
                  context.go(RouteConstants.blockHub.toPath);
                  break;
              }
            },
          ),
        );
      },
      routes: [
        GoRoute(
          path: RouteConstants.home.toPath,
          name: RouteConstants.home.name,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: RouteConstants.pantherAi.toPath,
          name: RouteConstants.pantherAi.name,
          builder: (context, state) => const PantherAiPage(),
        ),
        GoRoute(
          path: RouteConstants.blockHub.toPath,
          name: RouteConstants.blockHub.name,
          builder: (context, state) => const BlockHubPage(),
        ),
      ],
    ),
  ],
);

int _calculateSelectedIndex(String location) {
  if (location.startsWith(RouteConstants.pantherAi.toPath)) return 1;
  if (location.startsWith(RouteConstants.blockHub.toPath)) return 2;
  return 0;
}
