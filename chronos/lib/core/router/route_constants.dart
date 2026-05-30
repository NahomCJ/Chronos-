enum RouteConstants {
  splash,
  onboarding,
  signUp,
  signIn,
  home,
  transfer,
  selectMethod,
  addRecipient,
  enterAmount,
  transferConfirmation,
  transferSuccess,
  pinEntry,
  phoneAuth,
  forgotPassword,
  resetPassword,
  addMoney,
  bankTransfer,
  wallet,
  findAtm,
  exchange,
  selectCurrency,
  enterExchangeAmount,
  reviewExchange,
  exchangeProcessing,
  exchangeSuccess,
  blockHub,
  pantherAi,
  insightDetails,
  rebalanceConfirmation,
  rebalanceSuccess,
  simulateRebalance,
  ethereumDetail,
  tradingAssistant,
  portfolioIntelligence,
  // Ethereum flow routes
  ethFlowDetail,
  ethFlowTradingAssistant,
  ethFlowPortfolioIntelligence,
  ethFlowSimulateRebalance,
  ethFlowRebalanceConfirmation,
  ethFlowRebalanceSuccess,
  tickpayWelcome,
  tickpayVerification,
  tickpayLinkWallets,
  tickpayCompletion,
  tickpayDashboard,
  tickpayCreditOverview,
  tickpayActivePlans,
  tickpayNotifications,
  tickpayRewards,
  tickpayShortcuts,
  tickPayAi,
  fullPortfolioAnalysis,
  paymentPlan,
  productDiscovery,
  affordabilityCheck,
  marketIntelligence,
  pantherAiSettings,
  pantherAiChat,
}

extension RouteConstantsX on RouteConstants {
  String get toPath {
    switch (this) {
      case RouteConstants.splash:
        return '/';
      case RouteConstants.onboarding:
        return '/onboarding';
      case RouteConstants.signUp:
        return '/signup';
      case RouteConstants.signIn:
        return '/signin';
      case RouteConstants.home:
        return '/home';
      case RouteConstants.transfer:
        return '/transfer';
      case RouteConstants.selectMethod:
        return '/select-method';
      case RouteConstants.addRecipient:
        return '/add-recipient';
      case RouteConstants.enterAmount:
        return '/enter-amount';
      case RouteConstants.transferConfirmation:
        return '/transfer-confirmation';
      case RouteConstants.transferSuccess:
        return '/transfer-success';
      case RouteConstants.pinEntry:
        return '/pin-entry';
      case RouteConstants.phoneAuth:
        return '/phone-auth';
      case RouteConstants.forgotPassword:
        return '/forgot-password';
      case RouteConstants.resetPassword:
        return '/reset-password';
      case RouteConstants.addMoney:
        return '/add-money';
      case RouteConstants.bankTransfer:
        return '/bank-transfer';
      case RouteConstants.wallet:
        return '/wallet';
      case RouteConstants.findAtm:
        return '/find-atm';
      case RouteConstants.exchange:
        return '/exchange';
      case RouteConstants.selectCurrency:
        return '/select-currency';
      case RouteConstants.enterExchangeAmount:
        return '/enter-exchange-amount';
      case RouteConstants.reviewExchange:
        return '/review-exchange';
      case RouteConstants.exchangeProcessing:
        return '/exchange-processing';
      case RouteConstants.exchangeSuccess:
        return '/exchange-success';
      case RouteConstants.blockHub:
        return '/blockhub';
      case RouteConstants.pantherAi:
        return '/panther-ai';
      case RouteConstants.insightDetails:
        return '/insight-details';
      case RouteConstants.rebalanceConfirmation:
        return '/rebalance-confirmation';
      case RouteConstants.rebalanceSuccess:
        return '/rebalance-success';
      case RouteConstants.simulateRebalance:
        return '/simulate-rebalance';
      case RouteConstants.ethereumDetail:
        return '/ethereum-detail';
      case RouteConstants.tradingAssistant:
        return '/trading-assistant';
      case RouteConstants.portfolioIntelligence:
        return '/portfolio-intelligence';
      // Ethereum flow routes
      case RouteConstants.ethFlowDetail:
        return '/eth-flow/detail';
      case RouteConstants.ethFlowTradingAssistant:
        return '/eth-flow/trading-assistant';
      case RouteConstants.ethFlowPortfolioIntelligence:
        return '/eth-flow/portfolio-intelligence';
      case RouteConstants.ethFlowSimulateRebalance:
        return '/eth-flow/simulate-rebalance';
      case RouteConstants.ethFlowRebalanceConfirmation:
        return '/eth-flow/rebalance-confirmation';
      case RouteConstants.ethFlowRebalanceSuccess:
        return '/eth-flow/rebalance-success';
      case RouteConstants.tickpayWelcome:
        return '/tickpay-welcome';
      case RouteConstants.tickpayVerification:
        return '/tickpay-verification';
      case RouteConstants.tickpayLinkWallets:
        return '/tickpay-link-wallets';
      case RouteConstants.tickpayCompletion:
        return '/tickpay-completion';
      case RouteConstants.tickpayDashboard:
        return '/tickpay-dashboard';
      case RouteConstants.tickpayCreditOverview:
        return '/tickpay-credit-overview';
      case RouteConstants.tickpayActivePlans:
        return '/tickpay-active-plans';
      case RouteConstants.tickpayNotifications:
        return '/tickpay-notifications';
      case RouteConstants.tickpayRewards:
        return '/tickpay-rewards';
      case RouteConstants.tickpayShortcuts:
        return '/tickpay-shortcuts';
      case RouteConstants.tickPayAi:
        return '/tickpay-ai';
      case RouteConstants.fullPortfolioAnalysis:
        return '/full-portfolio-analysis';
      case RouteConstants.paymentPlan:
        return '/payment-plan';
      case RouteConstants.productDiscovery:
        return '/product-discovery';
      case RouteConstants.affordabilityCheck:
        return '/affordability-check';
      case RouteConstants.marketIntelligence:
        return '/market-intelligence';
      case RouteConstants.pantherAiSettings:
        return '/panther-ai-settings';
      case RouteConstants.pantherAiChat:
        return '/panther-ai-chat';
    }
  }

  String get toName {
    switch (this) {
      case RouteConstants.splash:
        return 'splash';
      case RouteConstants.onboarding:
        return 'onboarding';
      case RouteConstants.signUp:
        return 'signup';
      case RouteConstants.signIn:
        return 'signin';
      case RouteConstants.home:
        return 'home';
      case RouteConstants.transfer:
        return 'transfer';
      case RouteConstants.selectMethod:
        return 'select-method';
      case RouteConstants.addRecipient:
        return 'add-recipient';
      case RouteConstants.enterAmount:
        return 'enter-amount';
      case RouteConstants.transferConfirmation:
        return 'transfer-confirmation';
      case RouteConstants.transferSuccess:
        return 'transfer-success';
      case RouteConstants.pinEntry:
        return 'pin-entry';
      case RouteConstants.phoneAuth:
        return 'phone-auth';
      case RouteConstants.forgotPassword:
        return 'forgot-password';
      case RouteConstants.resetPassword:
        return 'reset-password';
      case RouteConstants.addMoney:
        return 'add-money';
      case RouteConstants.bankTransfer:
        return 'bank-transfer';
      case RouteConstants.wallet:
        return 'wallet';
      case RouteConstants.findAtm:
        return 'find-atm';
      case RouteConstants.exchange:
        return 'exchange';
      case RouteConstants.selectCurrency:
        return 'select-currency';
      case RouteConstants.enterExchangeAmount:
        return 'enter-exchange-amount';
      case RouteConstants.reviewExchange:
        return 'review-exchange';
      case RouteConstants.exchangeProcessing:
        return 'exchange-processing';
      case RouteConstants.exchangeSuccess:
        return 'exchange-success';
      case RouteConstants.blockHub:
        return 'blockhub';
      case RouteConstants.pantherAi:
        return 'panther-ai';
      case RouteConstants.insightDetails:
        return 'insight-details';
      case RouteConstants.rebalanceConfirmation:
        return 'rebalance-confirmation';
      case RouteConstants.rebalanceSuccess:
        return 'rebalance-success';
      case RouteConstants.simulateRebalance:
        return 'simulate-rebalance';
      case RouteConstants.ethereumDetail:
        return 'ethereum-detail';
      case RouteConstants.tradingAssistant:
        return 'trading-assistant';
      case RouteConstants.portfolioIntelligence:
        return 'portfolio-intelligence';
      // Ethereum flow routes
      case RouteConstants.ethFlowDetail:
        return 'eth-flow-detail';
      case RouteConstants.ethFlowTradingAssistant:
        return 'eth-flow-trading-assistant';
      case RouteConstants.ethFlowPortfolioIntelligence:
        return 'eth-flow-portfolio-intelligence';
      case RouteConstants.ethFlowSimulateRebalance:
        return 'eth-flow-simulate-rebalance';
      case RouteConstants.ethFlowRebalanceConfirmation:
        return 'eth-flow-rebalance-confirmation';
      case RouteConstants.ethFlowRebalanceSuccess:
        return 'eth-flow-rebalance-success';
      case RouteConstants.tickpayWelcome:
        return 'tickpay-welcome';
      case RouteConstants.tickpayVerification:
        return 'tickpay-verification';
      case RouteConstants.tickpayLinkWallets:
        return 'tickpay-link-wallets';
      case RouteConstants.tickpayCompletion:
        return 'tickpay-completion';
      case RouteConstants.tickpayDashboard:
        return 'tickpay-dashboard';
      case RouteConstants.tickpayCreditOverview:
        return 'tickpay-credit-overview';
      case RouteConstants.tickpayActivePlans:
        return 'tickpay-active-plans';
      case RouteConstants.tickpayNotifications:
        return 'tickpay-notifications';
      case RouteConstants.tickpayRewards:
        return 'tickpay-rewards';
      case RouteConstants.tickpayShortcuts:
        return 'tickpay-shortcuts';
      case RouteConstants.tickPayAi:
        return 'tickpay-ai';
      case RouteConstants.fullPortfolioAnalysis:
        return 'full-portfolio-analysis';
      case RouteConstants.paymentPlan:
        return 'payment-plan';
      case RouteConstants.productDiscovery:
        return 'product-discovery';
      case RouteConstants.affordabilityCheck:
        return 'affordability-check';
      case RouteConstants.marketIntelligence:
        return 'market-intelligence';
      case RouteConstants.pantherAiSettings:
        return 'panther-ai-settings';
      case RouteConstants.pantherAiChat:
        return 'panther-ai-chat';
    }
  }
}
