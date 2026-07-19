import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

enum ChrisActionType {
  // ── Transactional ──────────────────────────────────────────────────────────
  exchange,
  transfer,
  checkBalance,
  bnplCheck,
  bnplRepay,
  bnplPurchase,
  addMoney,
  cashOut,
  payBill,
  viewBills,
  viewTransactions,
  freezeWallet,
  checkCryptoPrice,
  buyCrypto,
  sellCrypto,
  sendCrypto,
  viewNfts,
  mintNft,
  cancelTransfer,

  // ── Core navigation ───────────────────────────────────────────────────────
  navigateHome,
  navigateWallet,
  navigateHistory,
  navigateExchange,
  navigateTransfer,
  navigateAddMoney,
  navigateBankTransfer,
  navigateFindAtm,
  navigateProfile,
  navigateChangePassword,
  navigateNotifications,

  // ── BlockHub navigation ───────────────────────────────────────────────────
  navigateBlockHub,
  navigateBlockHubMarkets,
  navigateBlockHubNft,
  navigateBlockHubPortfolio,

  // ── TickPay navigation ────────────────────────────────────────────────────
  navigateTickPay,
  navigateTickpayDiscover,
  navigateTickpaySearch,
  navigateTickpayAiPicks,
  navigateTickpayOrderHistory,
  navigateTickpayUpcomingPayments,
  navigateTickpayRepayNow,
  navigateTickpayPaymentHistory,
  navigateTickpayRewards,
  navigateTickpayCreditOverview,
  navigateTickpayAlerts,
  navigateTickpayAutoPay,
  navigateTickpayAiShop,
  navigateTickpayActivePlans,
  navigateTickpayAi,

  // ── Panther AI navigation ─────────────────────────────────────────────────
  navigatePantherAi,
  navigatePantherTax,
  navigatePantherBills,
  navigatePantherLiabilities,
  navigatePantherBudget,
  navigatePantherNetWorth,
  navigatePantherMarket,
  navigatePantherPortfolio,
  navigatePantherAffordability,
  navigatePantherPaymentPlan,
  navigatePantherProductDiscovery,
  navigatePantherTrading,
  navigatePantherSettings,

  // ── LifeX navigation ──────────────────────────────────────────────────────
  navigateLifex,
  navigateLifexHealth,
  navigateLifexFinance,
  navigateLifexActivity,
  navigateLifexEducation,
  navigateLifexSpiritual,
  navigateLifexVision,
  navigateLifexFamily,
  navigateLifexRelationship,
  navigateLifexSocial,
  navigateLifexFeed,
  navigateLifexAiInsights,
  navigateLifexExport,

  unknown,
}

class ChrisIntent {
  final ChrisActionType type;
  final double? amount;
  final String? fromCurrency;
  final String? toCurrency;
  final String? recipientHint;
  final String? merchant;
  final String? assetId;
  final String rawMessage;

  const ChrisIntent({
    required this.type,
    this.amount,
    this.fromCurrency,
    this.toCurrency,
    this.recipientHint,
    this.merchant,
    this.assetId,
    required this.rawMessage,
  });
}

class ChrisActionPlan {
  final ChrisActionType type;
  final String title;
  final String subtitle;
  final List<(String, String)> details;
  final Future<ChrisActionResult> Function() execute;
  final String? warning;
  final String? navigateTo;

  const ChrisActionPlan({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.execute,
    this.warning,
    this.navigateTo,
  });
}

class ChrisActionResult {
  final bool success;
  final String message;
  final Map<String, String>? details;

  const ChrisActionResult({
    required this.success,
    required this.message,
    this.details,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class ChrisActionService {
  static ApiClient get _api => GetIt.instance<ApiClient>();

  // ── Intent parsing ─────────────────────────────────────────────────────────

  static ChrisIntent parseIntent(String raw) {
    final msg = raw.toLowerCase().trim();
    final amount = _parseAmount(msg);

    // Transactional intents — checked first, highest priority
    if (_isExchange(msg)) {
      return ChrisIntent(
        type: ChrisActionType.exchange,
        amount: amount,
        fromCurrency: _parseCurrency(msg, isSource: true),
        toCurrency: _parseCurrency(msg, isSource: false),
        rawMessage: raw,
      );
    }
    if (_isBuyCrypto(msg)) {
      return ChrisIntent(
        type: ChrisActionType.buyCrypto,
        amount: amount,
        toCurrency: _parseCryptoCoin(msg),
        rawMessage: raw,
      );
    }
    if (_isSellCrypto(msg)) {
      return ChrisIntent(
        type: ChrisActionType.sellCrypto,
        amount: amount,
        fromCurrency: _parseCryptoCoin(msg),
        rawMessage: raw,
      );
    }
    if (_isSendCrypto(msg)) {
      return ChrisIntent(
        type: ChrisActionType.sendCrypto,
        amount: amount,
        fromCurrency: _parseCryptoCoin(msg),
        recipientHint: _parseRecipient(msg),
        rawMessage: raw,
      );
    }
    if (_isCheckCryptoPrice(msg)) {
      return ChrisIntent(
        type: ChrisActionType.checkCryptoPrice,
        assetId: _parseCryptoCoin(msg),
        rawMessage: raw,
      );
    }
    if (_isMintNft(msg)) {
      return ChrisIntent(type: ChrisActionType.mintNft, rawMessage: raw);
    }
    if (_isViewNfts(msg)) {
      return ChrisIntent(type: ChrisActionType.viewNfts, rawMessage: raw);
    }
    if (_isBnplRepay(msg)) {
      return ChrisIntent(
        type: ChrisActionType.bnplRepay,
        amount: amount,
        rawMessage: raw,
      );
    }
    if (_isBnplPurchase(msg)) {
      return ChrisIntent(
        type: ChrisActionType.bnplPurchase,
        amount: amount,
        merchant: _parseMerchant(msg),
        rawMessage: raw,
      );
    }
    if (_isBnplCheck(msg)) {
      return ChrisIntent(
        type: ChrisActionType.bnplCheck,
        amount: amount,
        merchant: _parseMerchant(msg),
        rawMessage: raw,
      );
    }
    if (_isPayBill(msg)) {
      return ChrisIntent(
        type: ChrisActionType.payBill,
        amount: amount,
        merchant: _parseMerchant(msg) ?? _parseBillProvider(msg),
        rawMessage: raw,
      );
    }
    if (_isViewBills(msg)) {
      return ChrisIntent(type: ChrisActionType.viewBills, rawMessage: raw);
    }
    if (_isTransfer(msg)) {
      return ChrisIntent(
        type: ChrisActionType.transfer,
        amount: amount,
        fromCurrency: _parseCurrency(msg, isSource: true) ?? 'USD',
        recipientHint: _parseRecipient(msg),
        rawMessage: raw,
      );
    }
    if (_isCashOut(msg)) {
      return ChrisIntent(
        type: ChrisActionType.cashOut,
        amount: amount,
        rawMessage: raw,
      );
    }
    if (_isFreezeWallet(msg)) {
      return ChrisIntent(type: ChrisActionType.freezeWallet, rawMessage: raw);
    }
    if (_isAddMoney(msg)) {
      return ChrisIntent(
        type: ChrisActionType.addMoney,
        amount: amount,
        rawMessage: raw,
      );
    }
    if (_isBalance(msg)) {
      return ChrisIntent(type: ChrisActionType.checkBalance, rawMessage: raw);
    }
    if (_isViewTransactions(msg)) {
      return ChrisIntent(type: ChrisActionType.viewTransactions, rawMessage: raw);
    }
    if (_isCancelTransfer(msg)) {
      return ChrisIntent(type: ChrisActionType.cancelTransfer, rawMessage: raw);
    }

    // Navigation intents
    final navType = _parseNavigationIntent(msg);
    if (navType != null) {
      return ChrisIntent(type: navType, rawMessage: raw);
    }

    return ChrisIntent(type: ChrisActionType.unknown, rawMessage: raw);
  }

  // ── Plan building ──────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> buildPlan(ChrisIntent intent) async {
    switch (intent.type) {
      // Transactional
      case ChrisActionType.exchange:
        return _exchangePlan(intent);
      case ChrisActionType.transfer:
        return _transferPlan(intent);
      case ChrisActionType.checkBalance:
        return _balancePlan();
      case ChrisActionType.bnplCheck:
        return _bnplCheckPlan(intent);
      case ChrisActionType.bnplRepay:
        return _bnplRepayPlan(intent);
      case ChrisActionType.bnplPurchase:
        return _bnplPurchasePlan(intent);
      case ChrisActionType.addMoney:
        return _addMoneyPlan(intent);
      case ChrisActionType.cashOut:
        return _cashOutPlan(intent);
      case ChrisActionType.payBill:
        return _payBillPlan(intent);
      case ChrisActionType.viewBills:
        return _viewBillsPlan();
      case ChrisActionType.viewTransactions:
        return _viewTransactionsPlan();
      case ChrisActionType.freezeWallet:
        return _freezeWalletPlan();
      case ChrisActionType.checkCryptoPrice:
        return _checkCryptoPricePlan(intent);
      case ChrisActionType.buyCrypto:
        return _buyCryptoPlan(intent);
      case ChrisActionType.sellCrypto:
        return _sellCryptoPlan(intent);
      case ChrisActionType.sendCrypto:
        return _sendCryptoPlan(intent);
      case ChrisActionType.viewNfts:
        return _viewNftsPlan();
      case ChrisActionType.mintNft:
        return _mintNftPlan();
      case ChrisActionType.cancelTransfer:
        return _cancelTransferPlan();

      // Core navigation
      case ChrisActionType.navigateHome:
        return _navPlan('Home', 'Going to your dashboard', '/home');
      case ChrisActionType.navigateWallet:
        return _navPlan('Wallet', 'Opening your wallet', '/wallet');
      case ChrisActionType.navigateHistory:
        return _navPlan('Transaction History', 'Showing all your transactions', '/history');
      case ChrisActionType.navigateExchange:
        return _navPlan('Currency Exchange', 'Opening the exchange screen', '/exchange');
      case ChrisActionType.navigateTransfer:
        return _navPlan('Send Money', 'Opening the transfer screen', '/transfer');
      case ChrisActionType.navigateAddMoney:
        return _navPlan('Add Money', 'Opening the deposit screen', '/add-money');
      case ChrisActionType.navigateBankTransfer:
        return _navPlan('Bank Transfer', 'Opening direct bank transfer', '/bank-transfer');
      case ChrisActionType.navigateFindAtm:
        return _navPlan('Find ATM', 'Finding nearby ATMs for you', '/find-atm');
      case ChrisActionType.navigateProfile:
        return _navPlan('Profile & Settings', 'Opening your profile', '/profile');
      case ChrisActionType.navigateChangePassword:
        return _navPlan('Change Password', 'Opening password settings', '/profile/change-password');
      case ChrisActionType.navigateNotifications:
        return _navPlan('Notification Settings', 'Opening notification preferences', '/profile/notifications');

      // BlockHub navigation
      case ChrisActionType.navigateBlockHub:
        return _navPlan('BlockHub', 'Opening crypto & NFT marketplace', '/blockhub');
      case ChrisActionType.navigateBlockHubMarkets:
        return _navPlan('Crypto Markets', 'Opening live crypto market data', '/blockhub');
      case ChrisActionType.navigateBlockHubNft:
        return _navPlan('NFT Marketplace', 'Opening NFT collections & trading', '/blockhub');
      case ChrisActionType.navigateBlockHubPortfolio:
        return _navPlan('Crypto Portfolio', 'Opening your crypto portfolio', '/blockhub');

      // TickPay navigation
      case ChrisActionType.navigateTickPay:
        return _navPlan('TickPay', 'Opening your BNPL shopping hub', '/tickpay-dashboard');
      case ChrisActionType.navigateTickpayDiscover:
        return _navPlan('TickPay Discover', 'Browsing shops & merchants', '/tickpay/discover');
      case ChrisActionType.navigateTickpaySearch:
        return _navPlan('TickPay Search', 'Searching for products', '/tickpay/search');
      case ChrisActionType.navigateTickpayAiPicks:
        return _navPlan('AI Picks', 'Viewing your personalized AI product picks', '/tickpay/ai-picks');
      case ChrisActionType.navigateTickpayOrderHistory:
        return _navPlan('Order History', 'Viewing your past TickPay orders', '/tickpay/order-history');
      case ChrisActionType.navigateTickpayUpcomingPayments:
        return _navPlan('Upcoming Payments', 'Viewing your scheduled BNPL payments', '/tickpay/upcoming-payments');
      case ChrisActionType.navigateTickpayRepayNow:
        return _navPlan('Repay Now', 'Opening the BNPL repayment screen', '/tickpay/repay-now');
      case ChrisActionType.navigateTickpayPaymentHistory:
        return _navPlan('Payment History', 'Viewing your TickPay payment history', '/tickpay/payment-history');
      case ChrisActionType.navigateTickpayRewards:
        return _navPlan('TickPay Rewards', 'Viewing your rewards & cashback', '/tickpay-rewards');
      case ChrisActionType.navigateTickpayCreditOverview:
        return _navPlan('Credit Overview', 'Viewing your credit score & summary', '/tickpay-credit-overview');
      case ChrisActionType.navigateTickpayAlerts:
        return _navPlan('TickPay Alerts', 'Viewing payment alerts & reminders', '/tickpay/alerts');
      case ChrisActionType.navigateTickpayAutoPay:
        return _navPlan('Auto Pay', 'Managing automatic BNPL payments', '/tickpay/auto-pay');
      case ChrisActionType.navigateTickpayAiShop:
        return _navPlan('AI Shop', 'Opening the AI-powered shopping assistant', '/tickpay/ai-shop');
      case ChrisActionType.navigateTickpayActivePlans:
        return _navPlan('Active Plans', 'Viewing your active BNPL plans', '/tickpay-active-plans');
      case ChrisActionType.navigateTickpayAi:
        return _navPlan('TickPay AI', 'Opening TickPay AI financial advisor', '/tickpay-ai');

      // Panther AI navigation
      case ChrisActionType.navigatePantherAi:
        return _navPlan('Panther AI', 'Opening financial intelligence hub', '/panther-ai');
      case ChrisActionType.navigatePantherTax:
        return _navPlan('Tax Intelligence', 'Opening your AI tax analysis', '/panther/tax');
      case ChrisActionType.navigatePantherBills:
        return _navPlan('Bills Management', 'Opening your bills & subscriptions', '/panther/bills');
      case ChrisActionType.navigatePantherLiabilities:
        return _navPlan('Liabilities', 'Opening your debt & liabilities overview', '/panther/liabilities');
      case ChrisActionType.navigatePantherBudget:
        return _navPlan('Budget Intelligence', 'Opening your AI budget analysis', '/panther/budget');
      case ChrisActionType.navigatePantherNetWorth:
        return _navPlan('Net Worth', 'Opening your net worth tracker', '/panther/net-worth');
      case ChrisActionType.navigatePantherMarket:
        return _navPlan('Market Intelligence', 'Opening live market insights', '/market-intelligence');
      case ChrisActionType.navigatePantherPortfolio:
        return _navPlan('Portfolio Analysis', 'Opening your full portfolio analysis', '/full-portfolio-analysis');
      case ChrisActionType.navigatePantherAffordability:
        return _navPlan('Affordability Check', 'Running an AI affordability analysis', '/affordability-check');
      case ChrisActionType.navigatePantherPaymentPlan:
        return _navPlan('Payment Plan', 'Viewing your AI-generated payment plan', '/payment-plan');
      case ChrisActionType.navigatePantherProductDiscovery:
        return _navPlan('Product Discovery', 'Opening AI product recommendations', '/product-discovery');
      case ChrisActionType.navigatePantherTrading:
        return _navPlan('Trading Assistant', 'Opening your AI trading assistant', '/trading-assistant');
      case ChrisActionType.navigatePantherSettings:
        return _navPlan('Panther Settings', 'Opening Panther AI settings', '/panther-ai-settings');

      // LifeX navigation
      case ChrisActionType.navigateLifex:
        return _navPlan('LifeX', 'Opening your life coaching dashboard', '/lifex');
      case ChrisActionType.navigateLifexHealth:
        return _navPlan('LifeX Health', 'Opening your health & wellness tracker', '/lifex/health');
      case ChrisActionType.navigateLifexFinance:
        return _navPlan('LifeX Finance', 'Opening financial wellness module', '/lifex/finance');
      case ChrisActionType.navigateLifexActivity:
        return _navPlan('LifeX Activity', 'Opening activity & fitness tracker', '/lifex/activity');
      case ChrisActionType.navigateLifexEducation:
        return _navPlan('LifeX Education', 'Opening your learning center', '/lifex/education');
      case ChrisActionType.navigateLifexSpiritual:
        return _navPlan('LifeX Spiritual', 'Opening mindfulness & reflection', '/lifex/spiritual');
      case ChrisActionType.navigateLifexVision:
        return _navPlan('LifeX Vision', 'Opening your vision board & goals', '/lifex/vision');
      case ChrisActionType.navigateLifexFamily:
        return _navPlan('LifeX Family', 'Opening family planning module', '/lifex/family');
      case ChrisActionType.navigateLifexRelationship:
        return _navPlan('LifeX Relationships', 'Opening your relationship & dating module', '/lifex/relationship');
      case ChrisActionType.navigateLifexSocial:
        return _navPlan('LifeX Social', 'Opening your social & network hub', '/lifex/social');
      case ChrisActionType.navigateLifexFeed:
        return _navPlan('LifeX Feed', 'Opening your community feed', '/lifex/feed');
      case ChrisActionType.navigateLifexAiInsights:
        return _navPlan('LifeX AI Insights', 'Opening AI-powered life insights', '/lifex/ai-insights');
      case ChrisActionType.navigateLifexExport:
        return _navPlan('Export Data', 'Opening your LifeX data export', '/lifex/export');

      case ChrisActionType.unknown:
        return null;
    }
  }

  static ChrisActionPlan _navPlan(String title, String subtitle, String route) {
    return ChrisActionPlan(
      type: ChrisActionType.navigateHome,
      title: title,
      subtitle: subtitle,
      details: [],
      navigateTo: route,
      execute: () async => ChrisActionResult(success: true, message: 'Opening $title…'),
    );
  }

  // ── Exchange ───────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _exchangePlan(ChrisIntent intent) async {
    if (intent.amount == null || intent.amount! <= 0) return null;

    final from = (intent.fromCurrency ?? 'USD').toUpperCase();
    final to = (intent.toCurrency ?? 'EUR').toUpperCase();
    if (from == to) return null;

    final amount = intent.amount!;

    try {
      final walletId = await _defaultWalletId();
      if (walletId == null) {
        return _errorPlan(ChrisActionType.exchange, 'No wallet found', 'Set up a wallet before exchanging currencies.');
      }

      final quoteData = await _api.post('/api/fx/quote', {
        'sourceWalletId': walletId,
        'destCurrency': to,
        'amount': amount,
      });

      final quoteId = quoteData['quoteId']?.toString() ?? quoteData['id']?.toString() ?? '';
      final rate = (quoteData['rate'] as num?)?.toDouble() ?? 0.0;
      final converted = (quoteData['convertedAmount'] as num?)?.toDouble() ?? (amount * rate);
      final fee = (quoteData['fee'] as num?)?.toDouble() ?? 0.0;

      return ChrisActionPlan(
        type: ChrisActionType.exchange,
        title: 'Exchange $from → $to',
        subtitle: 'Chris will execute this FX order on your behalf.',
        details: [
          ('You send', '${amount.toStringAsFixed(2)} $from'),
          ('You receive', '${converted.toStringAsFixed(2)} $to'),
          ('Rate', '1 $from = ${rate.toStringAsFixed(4)} $to'),
          if (fee > 0) ('Fee', '${fee.toStringAsFixed(2)} $from'),
        ],
        execute: () async {
          try {
            final res = await _api.post('/api/fx/execute', {'quoteId': quoteId});
            return ChrisActionResult(
              success: true,
              message: 'Done! Exchanged ${amount.toStringAsFixed(2)} $from → ${converted.toStringAsFixed(2)} $to.',
              details: {
                'Status': res['status']?.toString() ?? 'Completed',
                if ((res['orderId'] ?? res['id']) != null)
                  'Order ID': (res['orderId'] ?? res['id']).toString(),
              },
            );
          } catch (e) {
            return ChrisActionResult(success: false, message: _clean(e.toString()));
          }
        },
      );
    } catch (e) {
      return ChrisActionPlan(
        type: ChrisActionType.exchange,
        title: 'Exchange $from → $to',
        subtitle: 'Could not fetch a live rate.',
        details: [
          ('Amount', '${amount.toStringAsFixed(2)} $from'),
          ('To', to),
        ],
        execute: () async => ChrisActionResult(success: false, message: 'Rate unavailable: ${_clean(e.toString())}'),
        warning: 'Live rate unavailable. Check connection and retry.',
      );
    }
  }

  // ── Transfer ───────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _transferPlan(ChrisIntent intent) async {
    if (intent.amount == null || intent.amount! <= 0) return null;

    final amount = intent.amount!;
    final currency = (intent.fromCurrency ?? 'USD').toUpperCase();

    try {
      final wallets = await _walletList();
      final source = wallets.isNotEmpty ? wallets.first : <String, dynamic>{};
      final sourceId = source['id']?.toString() ?? '';
      final sourceName = source['name']?.toString() ?? source['type']?.toString() ?? 'Main Wallet';
      final balance = (source['balance'] as num?)?.toDouble() ?? 0.0;
      final hasEnough = balance >= amount;
      final recipient = intent.recipientHint;

      String? destWalletId;
      String? destLabel;
      if (recipient != null) {
        try {
          final found = await _api.getList('/api/core/accounts?search=${Uri.encodeComponent(recipient)}');
          if (found.isNotEmpty) {
            final acc = found.first as Map<String, dynamic>;
            final accId = acc['id']?.toString() ?? '';
            final accWallets = await _api.getList('/api/wallet/list/$accId');
            if (accWallets.isNotEmpty) {
              destWalletId = (accWallets.first as Map<String, dynamic>)['id']?.toString();
              destLabel = acc['firstName']?.toString() ?? acc['name']?.toString() ?? recipient;
            }
          }
        } catch (_) {}
      }

      final canAutoExecute = sourceId.isNotEmpty && destWalletId != null && hasEnough;

      return ChrisActionPlan(
        type: ChrisActionType.transfer,
        title: 'Transfer ${amount.toStringAsFixed(2)} $currency',
        subtitle: destLabel != null
            ? 'From $sourceName → $destLabel'
            : recipient != null
                ? 'From $sourceName (recipient not found in system)'
                : 'From your $sourceName',
        details: [
          ('Amount', '${amount.toStringAsFixed(2)} $currency'),
          ('From', '$sourceName  ·  balance: ${balance.toStringAsFixed(2)} $currency'),
          if (destLabel != null) ('To', destLabel),
          if (recipient != null && destLabel == null) ('Recipient', '$recipient: wallet not found'),
          if (!hasEnough) ('⚠ Warning', 'Insufficient balance'),
        ],
        warning: !hasEnough
            ? 'Your balance (${balance.toStringAsFixed(2)} $currency) is less than the transfer amount.'
            : (recipient != null && destWalletId == null)
                ? 'Recipient\'s wallet not found automatically. Open Transfer to search manually.'
                : null,
        execute: () async {
          if (!canAutoExecute) {
            return ChrisActionResult(
              success: false,
              message: destWalletId == null
                  ? 'I couldn\'t find the recipient\'s wallet automatically. Use the Transfer page to search by name or phone.'
                  : 'Insufficient balance for this transfer.',
            );
          }
          try {
            final res = await _api.post('/api/v1/transfer', {
              'sourceWalletId': sourceId,
              'destWalletId': destWalletId,
              'amount': amount,
              'currency': currency,
              if (recipient != null) 'reference': 'Transfer to $recipient via Chris',
            });
            return ChrisActionResult(
              success: true,
              message: 'Done! Transferred ${amount.toStringAsFixed(2)} $currency to $destLabel.',
              details: {
                'Status': res['status']?.toString() ?? 'Initiated',
                if ((res['id'] ?? res['transferId']) != null)
                  'Reference': (res['id'] ?? res['transferId']).toString(),
              },
            );
          } catch (e) {
            return ChrisActionResult(success: false, message: _clean(e.toString()));
          }
        },
      );
    } catch (e) {
      return null;
    }
  }

  // ── Cancel transfer ────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _cancelTransferPlan() async {
    try {
      final transfers = await _api.getList('/api/v1/transfer');
      final pending = (transfers)
          .map((t) => t as Map<String, dynamic>)
          .where((t) => (t['status']?.toString() ?? '').toUpperCase() == 'PENDING')
          .toList();

      if (pending.isEmpty) {
        return _errorPlan(
          ChrisActionType.cancelTransfer,
          'No Pending Transfers',
          'You have no pending transfers to cancel.',
        );
      }

      final latest = pending.first;
      final id = latest['id']?.toString() ?? '';
      final amount = (latest['amount'] as num?)?.toDouble() ?? 0.0;
      final currency = latest['currency']?.toString() ?? 'USD';
      final to = latest['destWalletId']?.toString() ?? 'recipient';

      return ChrisActionPlan(
        type: ChrisActionType.cancelTransfer,
        title: 'Cancel Transfer',
        subtitle: 'Cancel pending transfer of ${amount.toStringAsFixed(2)} $currency',
        details: [
          ('Amount', '${amount.toStringAsFixed(2)} $currency'),
          ('To', to),
          ('Status', 'Pending'),
        ],
        warning: 'This will cancel your most recent pending transfer.',
        execute: () async {
          try {
            await _api.post('/api/v1/transfer/$id/cancel', {});
            return ChrisActionResult(
              success: true,
              message: 'Transfer of ${amount.toStringAsFixed(2)} $currency has been cancelled.',
            );
          } catch (e) {
            return ChrisActionResult(success: false, message: _clean(e.toString()));
          }
        },
      );
    } catch (e) {
      return null;
    }
  }

  // ── Balance ────────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _balancePlan() async {
    try {
      final wallets = await _walletList();
      if (wallets.isEmpty) return null;

      final details = <(String, String)>[];
      for (final w in wallets.take(5)) {
        final name = w['name']?.toString() ?? w['type']?.toString() ?? 'Wallet';
        final bal = (w['balance'] as num?)?.toDouble() ?? 0.0;
        final cur = w['currency']?.toString() ?? 'USD';
        details.add((name, '${bal.toStringAsFixed(2)} $cur'));
      }

      return ChrisActionPlan(
        type: ChrisActionType.checkBalance,
        title: 'Your Balances',
        subtitle: '${wallets.length} wallet${wallets.length == 1 ? '' : 's'} found.',
        details: details,
        execute: () async => const ChrisActionResult(success: true, message: 'Here are your current balances.'),
      );
    } catch (e) {
      return null;
    }
  }

  // ── View Transactions ──────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _viewTransactionsPlan() async {
    try {
      final txList = await _api.getList('/api/transactions?limit=5');
      if (txList.isEmpty) {
        return _errorPlan(ChrisActionType.viewTransactions, 'No Transactions', 'No recent transactions found.');
      }

      final details = <(String, String)>[];
      for (final tx in txList.take(5)) {
        final t = tx as Map<String, dynamic>;
        final desc = t['description']?.toString() ?? t['type']?.toString() ?? 'Transaction';
        final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
        final cur = t['currency']?.toString() ?? 'USD';
        final sign = (t['type']?.toString() ?? '').toLowerCase().contains('debit') ? '-' : '+';
        details.add((desc, '$sign${amount.toStringAsFixed(2)} $cur'));
      }

      return ChrisActionPlan(
        type: ChrisActionType.viewTransactions,
        title: 'Recent Transactions',
        subtitle: 'Your last ${details.length} transactions',
        details: details,
        execute: () async => const ChrisActionResult(success: true, message: 'Here are your recent transactions.'),
      );
    } catch (e) {
      return null;
    }
  }

  // ── BNPL Check ─────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _bnplCheckPlan(ChrisIntent intent) async {
    final amount = intent.amount ?? 0;
    final merchant = intent.merchant ?? 'Unknown Merchant';

    return ChrisActionPlan(
      type: ChrisActionType.bnplCheck,
      title: 'Affordability Check',
      subtitle: '\$${amount.toStringAsFixed(2)} at $merchant via TickPay',
      details: [
        ('Purchase', '\$${amount.toStringAsFixed(2)}'),
        ('Merchant', merchant),
        ('Type', 'Buy Now, Pay Later'),
      ],
      execute: () async {
        try {
          final res = await _api.post('/api/ai/tickpay/affordability', {
            'amount': amount,
            'merchant': merchant,
          });
          final approved = res['approved'] as bool? ?? false;
          final riskScore = (res['riskScore'] as num?)?.toDouble() ?? 0;
          final maxAmount = (res['maxAmount'] as num?)?.toDouble() ?? 0;
          final msg = res['message']?.toString() ?? '';
          return ChrisActionResult(
            success: approved,
            message: approved ? '✓ Approved: $msg' : '✗ Not approved: $msg',
            details: {
              'Decision': approved ? 'Approved ✓' : 'Declined ✗',
              'Risk Score': '${(riskScore * 100).toStringAsFixed(0)}%',
              if (approved && maxAmount > 0) 'Max Approved': '\$${maxAmount.toStringAsFixed(2)}',
            },
          );
        } catch (e) {
          return ChrisActionResult(success: false, message: 'Could not run check: ${_clean(e.toString())}');
        }
      },
    );
  }

  // ── BNPL Repay ─────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _bnplRepayPlan(ChrisIntent intent) async {
    final amount = intent.amount;

    return ChrisActionPlan(
      type: ChrisActionType.bnplRepay,
      title: 'Repay BNPL Plan',
      subtitle: amount != null
          ? 'Pay \$${amount.toStringAsFixed(2)} toward your active plan'
          : 'Make a payment on your active BNPL plan',
      details: [
        if (amount != null) ('Payment Amount', '\$${amount.toStringAsFixed(2)}'),
        ('Method', 'Wallet balance'),
        ('Plan', 'Active TickPay plan'),
      ],
      execute: () async {
        try {
          final body = <String, dynamic>{};
          if (amount != null) body['amount'] = amount;
          final res = await _api.post('/api/tickpay/accounts/repayments', body);
          final paid = (res['amount'] as num?)?.toDouble() ?? amount ?? 0;
          return ChrisActionResult(
            success: true,
            message: 'Payment of \$${paid.toStringAsFixed(2)} applied to your BNPL plan.',
            details: {
              'Status': res['status']?.toString() ?? 'Completed',
              if (res['remainingBalance'] != null)
                'Remaining': '\$${(res['remainingBalance'] as num).toStringAsFixed(2)}',
            },
          );
        } catch (e) {
          return ChrisActionResult(success: false, message: _clean(e.toString()));
        }
      },
    );
  }

  // ── BNPL Purchase ──────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _bnplPurchasePlan(ChrisIntent intent) async {
    if (intent.amount == null || intent.amount! <= 0) return null;
    final amount = intent.amount!;
    final merchant = intent.merchant ?? 'Merchant';

    return ChrisActionPlan(
      type: ChrisActionType.bnplPurchase,
      title: 'BNPL Purchase at $merchant',
      subtitle: '\$${amount.toStringAsFixed(2)} — split into installments via TickPay',
      details: [
        ('Total', '\$${amount.toStringAsFixed(2)}'),
        ('Merchant', merchant),
        ('Type', 'Buy Now, Pay Later'),
        ('Est. installment', '\$${(amount / 4).toStringAsFixed(2)} × 4 payments'),
      ],
      warning: 'This will create a new BNPL plan. Make sure you can cover the installments.',
      execute: () async {
        try {
          final res = await _api.post('/api/tickpay/accounts/purchases', {
            'amount': amount,
            'merchant': merchant,
          });
          final planId = res['id']?.toString() ?? res['planId']?.toString() ?? '';
          return ChrisActionResult(
            success: true,
            message: 'BNPL plan created for \$${amount.toStringAsFixed(2)} at $merchant.',
            details: {
              'Status': res['status']?.toString() ?? 'Active',
              if (planId.isNotEmpty) 'Plan ID': planId,
            },
          );
        } catch (e) {
          return ChrisActionResult(success: false, message: _clean(e.toString()));
        }
      },
    );
  }

  // ── Add Money ──────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _addMoneyPlan(ChrisIntent intent) async {
    final amount = intent.amount;
    return ChrisActionPlan(
      type: ChrisActionType.addMoney,
      title: 'Add Money',
      subtitle: amount != null ? '\$${amount.toStringAsFixed(2)} via ACH deposit' : 'ACH bank deposit',
      details: [
        if (amount != null) ('Amount', '\$${amount.toStringAsFixed(2)}'),
        ('Method', 'ACH Bank Transfer'),
        ('Processing Time', '1–3 business days'),
      ],
      execute: () async => const ChrisActionResult(
        success: false,
        message: 'Opening the deposit flow. Confirm your linked bank account to proceed.',
      ),
      warning: 'ACH deposits require bank account verification.',
    );
  }

  // ── Cash Out ───────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _cashOutPlan(ChrisIntent intent) async {
    final amount = intent.amount;
    if (amount == null || amount <= 0) return null;

    try {
      final walletId = await _defaultWalletId();
      if (walletId == null) {
        return _errorPlan(ChrisActionType.cashOut, 'No Wallet Found', 'Set up a wallet before cashing out.');
      }

      return ChrisActionPlan(
        type: ChrisActionType.cashOut,
        title: 'Cash Out \$${amount.toStringAsFixed(2)}',
        subtitle: 'Withdraw from your main wallet',
        details: [
          ('Amount', '\$${amount.toStringAsFixed(2)}'),
          ('From', 'Main Wallet'),
          ('Method', 'Cash out'),
        ],
        execute: () async {
          try {
            final res = await _api.post('/api/wallet/cashout', {
              'walletId': walletId,
              'amount': amount,
            });
            return ChrisActionResult(
              success: true,
              message: 'Cash out of \$${amount.toStringAsFixed(2)} initiated.',
              details: {'Status': res['status']?.toString() ?? 'Initiated'},
            );
          } catch (e) {
            return ChrisActionResult(success: false, message: _clean(e.toString()));
          }
        },
      );
    } catch (e) {
      return null;
    }
  }

  // ── Pay Bill ───────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _payBillPlan(ChrisIntent intent) async {
    final amount = intent.amount;
    final provider = intent.merchant ?? 'Unknown Provider';

    return ChrisActionPlan(
      type: ChrisActionType.payBill,
      title: 'Pay Bill — $provider',
      subtitle: amount != null ? '\$${amount.toStringAsFixed(2)} to $provider' : 'Bill payment to $provider',
      details: [
        if (amount != null) ('Amount', '\$${amount.toStringAsFixed(2)}'),
        ('Provider', provider),
        ('Method', 'Wallet balance'),
      ],
      execute: () async {
        try {
          final body = <String, dynamic>{'provider': provider};
          if (amount != null) body['amount'] = amount;
          final res = await _api.post('/api/bills/pay', body);
          return ChrisActionResult(
            success: true,
            message: 'Bill payment to $provider completed.',
            details: {
              'Status': res['status']?.toString() ?? 'Paid',
              if (res['referenceId'] != null) 'Reference': res['referenceId'].toString(),
            },
          );
        } catch (e) {
          return ChrisActionResult(success: false, message: _clean(e.toString()));
        }
      },
    );
  }

  // ── View Bills ─────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _viewBillsPlan() async {
    try {
      final history = await _api.getList('/api/bills/history');

      final details = <(String, String)>[];
      for (final b in history.take(5)) {
        final bill = b as Map<String, dynamic>;
        final name = bill['provider']?.toString() ?? 'Bill';
        final amount = (bill['amount'] as num?)?.toDouble() ?? 0.0;
        final status = bill['status']?.toString() ?? 'Unknown';
        details.add((name, '\$${amount.toStringAsFixed(2)} — $status'));
      }

      if (details.isEmpty) {
        return _errorPlan(ChrisActionType.viewBills, 'No Bills Found', 'No bill payment history found.');
      }

      return ChrisActionPlan(
        type: ChrisActionType.viewBills,
        title: 'Your Bills',
        subtitle: 'Recent bill payments',
        details: details,
        execute: () async => const ChrisActionResult(success: true, message: 'Here are your recent bills.'),
      );
    } catch (e) {
      return null;
    }
  }

  // ── Freeze Wallet ──────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _freezeWalletPlan() async {
    try {
      final wallets = await _walletList();
      if (wallets.isEmpty) {
        return _errorPlan(ChrisActionType.freezeWallet, 'No Wallet Found', 'No wallet to freeze.');
      }

      final wallet = wallets.first;
      final walletId = wallet['id']?.toString() ?? '';
      final walletName = wallet['name']?.toString() ?? 'Main Wallet';
      final isFrozen = wallet['frozen'] as bool? ?? wallet['status']?.toString() == 'FROZEN';

      return ChrisActionPlan(
        type: ChrisActionType.freezeWallet,
        title: isFrozen ? 'Unfreeze $walletName' : 'Freeze $walletName',
        subtitle: isFrozen
            ? 'Re-enable transactions on your wallet'
            : 'Temporarily block all transactions on your wallet',
        details: [
          ('Wallet', walletName),
          ('Current Status', isFrozen ? 'Frozen' : 'Active'),
          ('Action', isFrozen ? 'Unfreeze' : 'Freeze'),
        ],
        warning: isFrozen ? null : 'Freezing will block all incoming and outgoing transactions.',
        execute: () async {
          try {
            await _api.patch('/api/wallet/freeze/$walletId', {'freeze': !isFrozen});
            final action = isFrozen ? 'unfrozen' : 'frozen';
            return ChrisActionResult(
              success: true,
              message: '$walletName has been $action.',
              details: {'Status': isFrozen ? 'Active' : 'Frozen'},
            );
          } catch (e) {
            return ChrisActionResult(success: false, message: _clean(e.toString()));
          }
        },
      );
    } catch (e) {
      return null;
    }
  }

  // ── Crypto Price ───────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _checkCryptoPricePlan(ChrisIntent intent) async {
    final coin = (intent.assetId ?? 'BTC').toUpperCase();

    try {
      final data = await _api.get('/api/v1/crypto/price/$coin');
      final price = (data['price'] as num?)?.toDouble() ??
          (data['data'] as Map<String, dynamic>?)?['price'] as double? ?? 0.0;
      final change = (data['change24h'] as num?)?.toDouble() ?? 0.0;
      final changeStr = change >= 0 ? '+${change.toStringAsFixed(2)}%' : '${change.toStringAsFixed(2)}%';

      return ChrisActionPlan(
        type: ChrisActionType.checkCryptoPrice,
        title: '$coin Price',
        subtitle: 'Live market data',
        details: [
          ('$coin / USD', '\$${price.toStringAsFixed(2)}'),
          if (change != 0) ('24h Change', changeStr),
        ],
        execute: () async => ChrisActionResult(
          success: true,
          message: '$coin is currently \$${price.toStringAsFixed(2)} ($changeStr 24h).',
        ),
      );
    } catch (e) {
      return _errorPlan(
        ChrisActionType.checkCryptoPrice,
        '$coin Price',
        'Could not fetch price. Check connection.',
      );
    }
  }

  // ── Buy Crypto ─────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _buyCryptoPlan(ChrisIntent intent) async {
    final coin = (intent.toCurrency ?? 'BTC').toUpperCase();
    final amount = intent.amount ?? 0;

    return ChrisActionPlan(
      type: ChrisActionType.buyCrypto,
      title: 'Buy $coin',
      subtitle: amount > 0 ? '\$${amount.toStringAsFixed(2)} of $coin' : 'Market order for $coin',
      details: [
        if (amount > 0) ('Amount', '\$${amount.toStringAsFixed(2)}'),
        ('Asset', coin),
        ('Order Type', 'Market order'),
        ('Settlement', 'Instant'),
      ],
      warning: 'Crypto prices fluctuate. Market order executes at current price.',
      execute: () async {
        try {
          final res = await _api.post('/api/v1/crypto/buy', {
            'asset': coin,
            if (amount > 0) 'amount': amount,
            'orderType': 'MARKET',
          });
          return ChrisActionResult(
            success: true,
            message: 'Done! Purchased $coin successfully.',
            details: {'Status': res['status']?.toString() ?? 'Completed'},
          );
        } catch (e) {
          return ChrisActionResult(success: false, message: _clean(e.toString()));
        }
      },
    );
  }

  // ── Sell Crypto ────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _sellCryptoPlan(ChrisIntent intent) async {
    final coin = (intent.fromCurrency ?? 'BTC').toUpperCase();
    final amount = intent.amount ?? 0;

    return ChrisActionPlan(
      type: ChrisActionType.sellCrypto,
      title: 'Sell $coin',
      subtitle: amount > 0 ? 'Sell \$${amount.toStringAsFixed(2)} of $coin' : 'Sell $coin at market price',
      details: [
        if (amount > 0) ('Amount', '\$${amount.toStringAsFixed(2)}'),
        ('Asset', coin),
        ('Order Type', 'Market sell'),
      ],
      execute: () async {
        try {
          final res = await _api.post('/api/v1/crypto/sell', {
            'asset': coin,
            if (amount > 0) 'amount': amount,
            'orderType': 'MARKET',
          });
          return ChrisActionResult(
            success: true,
            message: 'Done! Sold $coin successfully.',
            details: {'Status': res['status']?.toString() ?? 'Completed'},
          );
        } catch (e) {
          return ChrisActionResult(success: false, message: _clean(e.toString()));
        }
      },
    );
  }

  // ── Send Crypto ────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _sendCryptoPlan(ChrisIntent intent) async {
    final coin = (intent.fromCurrency ?? 'BTC').toUpperCase();
    final amount = intent.amount ?? 0;
    final recipient = intent.recipientHint ?? 'Unknown';

    return ChrisActionPlan(
      type: ChrisActionType.sendCrypto,
      title: 'Send $coin',
      subtitle: 'Send to $recipient',
      details: [
        if (amount > 0) ('Amount', '${amount.toStringAsFixed(8)} $coin'),
        ('Asset', coin),
        ('To', recipient),
        ('Network', 'Ethereum / Polygon'),
      ],
      execute: () async => const ChrisActionResult(
        success: false,
        message: 'Use the BlockHub Send screen to enter the wallet address and confirm. Crypto sends are irreversible.',
      ),
      warning: 'Crypto sends are irreversible. Always verify the wallet address.',
    );
  }

  // ── View NFTs ──────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _viewNftsPlan() async {
    try {
      final data = await _api.get('/api/nft/user-nfts');
      final nfts = (data['nfts'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      if (nfts.isEmpty) {
        return _errorPlan(ChrisActionType.viewNfts, 'No NFTs Found', 'You don\'t own any NFTs yet. Visit the BlockHub marketplace to get started.');
      }

      final details = nfts.take(4).map((nft) {
        final name = nft['name']?.toString() ?? 'NFT';
        final value = nft['estimatedValue']?.toString() ?? nft['floorPrice']?.toString() ?? 'Unknown';
        return (name, 'Est. value: $value');
      }).toList();

      return ChrisActionPlan(
        type: ChrisActionType.viewNfts,
        title: 'Your NFTs',
        subtitle: '${nfts.length} NFT${nfts.length == 1 ? '' : 's'} in your collection',
        details: details,
        execute: () async => const ChrisActionResult(success: true, message: 'Here\'s your NFT collection.'),
      );
    } catch (e) {
      return null;
    }
  }

  // ── Mint NFT ───────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _mintNftPlan() async {
    return ChrisActionPlan(
      type: ChrisActionType.mintNft,
      title: 'Mint an NFT',
      subtitle: 'Create a new NFT on BlockHub',
      details: [
        ('Network', 'Ethereum / Polygon'),
        ('Gas', 'Estimated at time of mint'),
        ('Royalties', 'Set during minting'),
      ],
      execute: () async => const ChrisActionResult(
        success: false,
        message: 'Opening BlockHub — use the NFT Mint screen to upload your asset and set properties.',
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  static Future<String?> _defaultWalletId() async {
    final wallets = await _walletList();
    return wallets.isNotEmpty ? wallets.first['id']?.toString() : null;
  }

  static Future<List<Map<String, dynamic>>> _walletList() async {
    try {
      final accounts = await _api.getList('/api/core/accounts');
      if (accounts.isEmpty) return [];
      final accountId = (accounts.first as Map<String, dynamic>)['id']?.toString();
      if (accountId == null) return [];
      final wallets = await _api.getList('/api/wallet/list/$accountId');
      return wallets.map((w) => w as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  static ChrisActionPlan _errorPlan(ChrisActionType type, String title, String msg) {
    return ChrisActionPlan(
      type: type,
      title: title,
      subtitle: msg,
      details: [],
      execute: () async => ChrisActionResult(success: false, message: msg),
    );
  }

  static String _clean(String err) => err.replaceAll('Exception: ', '').trim();

  // ── Pattern matchers ───────────────────────────────────────────────────────

  static bool _isExchange(String m) =>
      RegExp(r'\b(exchange|convert|swap|change.*to|fx)\b').hasMatch(m) ||
      (_hasCurrencyPair(m) && m.contains(' to '));

  static bool _isTransfer(String m) =>
      RegExp(r'\b(transfer|send|pay|wire|move)\b').hasMatch(m) &&
      !_hasCryptoMention(m);

  static bool _isBalance(String m) =>
      RegExp(r'\b(balance|how much|what.*have|my money|my balance|account balance|funds)\b').hasMatch(m);

  static bool _isBnplCheck(String m) =>
      RegExp(r'\b(afford|can i buy|installment check|bnpl check|split.*payment)\b').hasMatch(m);

  static bool _isBnplRepay(String m) =>
      RegExp(r'\b(repay|pay off|pay back|pay my plan|bnpl payment|make.*payment)\b').hasMatch(m) &&
      !_hasCryptoMention(m);

  static bool _isBnplPurchase(String m) =>
      RegExp(r'\b(buy now pay later|bnpl purchase|split.*buy|tickpay.*buy|buy.*installment)\b').hasMatch(m);

  static bool _isAddMoney(String m) =>
      RegExp(r'\b(add money|deposit|top up|fund my|load.*wallet)\b').hasMatch(m);

  static bool _isCashOut(String m) =>
      RegExp(r'\b(cash out|withdraw|take out.*money|pull.*money)\b').hasMatch(m);

  static bool _isPayBill(String m) =>
      RegExp(r'\b(pay.*bill|pay.*utility|pay.*electric|pay.*internet|pay.*phone|pay.*rent|pay.*subscription)\b').hasMatch(m);

  static bool _isViewBills(String m) =>
      RegExp(r'\b(my bills|show bills|view bills|bill history|what.*owe)\b').hasMatch(m);

  static bool _isViewTransactions(String m) =>
      RegExp(r'\b(transaction|recent.*activity|my activity|spending history|what.*spent|show.*transaction)\b').hasMatch(m);

  static bool _isFreezeWallet(String m) =>
      RegExp(r'\b(freeze|lock.*wallet|block.*wallet|unfreeze|unlock.*wallet)\b').hasMatch(m);

  static bool _isCancelTransfer(String m) =>
      RegExp(r'\b(cancel.*transfer|cancel.*payment|undo.*transfer|reverse.*transfer)\b').hasMatch(m);

  static bool _isCheckCryptoPrice(String m) =>
      RegExp(r'\b(price|how much.*worth|value of|cost of|what.*trading at)\b').hasMatch(m) &&
      _hasCryptoMention(m);

  static bool _isBuyCrypto(String m) =>
      RegExp(r'\b(buy|purchase|get)\b').hasMatch(m) && _hasCryptoMention(m);

  static bool _isSellCrypto(String m) =>
      RegExp(r'\b(sell|dump|offload)\b').hasMatch(m) && _hasCryptoMention(m);

  static bool _isSendCrypto(String m) =>
      RegExp(r'\b(send|transfer)\b').hasMatch(m) && _hasCryptoMention(m);

  static bool _isMintNft(String m) =>
      RegExp(r'\b(mint|create.*nft|make.*nft|deploy.*nft)\b').hasMatch(m);

  static bool _isViewNfts(String m) =>
      RegExp(r'\b(my nft|show.*nft|view.*nft|nft collection|nft portfolio)\b').hasMatch(m);

  static bool _hasCryptoMention(String m) =>
      RegExp(r'\b(bitcoin|btc|ethereum|eth|solana|sol|bnb|crypto|nft|usdc|usdt|polygon|matic)\b').hasMatch(m);

  static bool _hasCurrencyPair(String msg) {
    int count = 0;
    for (final c in _currencyKeywords.keys) {
      if (msg.contains(c)) count++;
      if (count >= 2) return true;
    }
    return false;
  }

  static double? _parseAmount(String msg) {
    final m = RegExp(r'\$?\s*(\d{1,6}(?:[.,]\d{1,2})?)').firstMatch(msg);
    if (m == null) return null;
    return double.tryParse(m.group(1)!.replaceAll(',', ''));
  }

  static String? _parseCurrency(String msg, {required bool isSource}) {
    if (isSource) {
      final m = RegExp(r'\bfrom\s+(\w+)', caseSensitive: false).firstMatch(msg);
      if (m != null) return _resolveCurrency(m.group(1)!);
      final m2 = RegExp(r'\d\s+(\w{3})\s+to\b', caseSensitive: false).firstMatch(msg);
      if (m2 != null) return _resolveCurrency(m2.group(1)!);
      return 'USD';
    } else {
      final m = RegExp(r'\b(?:to|into)\s+(\w+)', caseSensitive: false).firstMatch(msg);
      if (m != null) {
        final c = _resolveCurrency(m.group(1)!);
        if (c != null && c != 'USD') return c;
      }
      for (final entry in _currencyKeywords.entries) {
        if (msg.contains(entry.key) && entry.value != 'USD') return entry.value;
      }
      return null;
    }
  }

  static String? _resolveCurrency(String word) => _currencyKeywords[word.toLowerCase()];

  static String? _parseRecipient(String msg) {
    final m = RegExp(
      r'\bto\s+([A-Za-z][A-Za-z\s]{1,25}?)(?:\s+for|\s*$|\s+\d|\s+from)',
      caseSensitive: false,
    ).firstMatch(msg);
    if (m != null) {
      final name = m.group(1)!.trim();
      if (!_currencyKeywords.containsKey(name.toLowerCase())) return name;
    }
    return null;
  }

  static String? _parseMerchant(String msg) {
    final m = RegExp(r'\bat\s+([A-Za-z][A-Za-z\s]{1,25})(?:\s|$)', caseSensitive: false).firstMatch(msg);
    return m?.group(1)?.trim();
  }

  static String? _parseBillProvider(String msg) {
    final providers = ['netflix', 'spotify', 'amazon', 'apple', 'google', 'hulu', 'disney', 'electric', 'internet', 'phone', 'rent'];
    for (final p in providers) {
      if (msg.contains(p)) return p[0].toUpperCase() + p.substring(1);
    }
    return null;
  }

  static String? _parseCryptoCoin(String msg) {
    if (msg.contains('bitcoin') || msg.contains('btc')) return 'BTC';
    if (msg.contains('ethereum') || msg.contains('eth')) return 'ETH';
    if (msg.contains('solana') || msg.contains('sol')) return 'SOL';
    if (msg.contains('bnb')) return 'BNB';
    if (msg.contains('polygon') || msg.contains('matic')) return 'MATIC';
    if (msg.contains('usdc')) return 'USDC';
    if (msg.contains('usdt')) return 'USDT';
    return 'BTC';
  }

  // ── Navigation intent parser ───────────────────────────────────────────────

  static ChrisActionType? _parseNavigationIntent(String msg) {
    final hasNavTrigger = RegExp(
      r'\b(go to|open|show|take me to|navigate|launch|switch to|bring up|view|see|check|find|i want|pull up)\b',
    ).hasMatch(msg);
    if (!hasNavTrigger && !RegExp(r'\b(home|dashboard)\b').hasMatch(msg)) {
      return null;
    }

    // Panther AI sub-pages
    if (RegExp(r'\b(tax|irs|deduction|filing|refund)\b').hasMatch(msg)) return ChrisActionType.navigatePantherTax;
    if (RegExp(r'\b(bill|subscription|recurring charge)\b').hasMatch(msg)) return ChrisActionType.navigatePantherBills;
    if (RegExp(r'\b(liabilit|debt overview|what i owe)\b').hasMatch(msg)) return ChrisActionType.navigatePantherLiabilities;
    if (RegExp(r'\b(budget|spending limit|spending plan)\b').hasMatch(msg)) return ChrisActionType.navigatePantherBudget;
    if (RegExp(r'\b(net worth|total wealth)\b').hasMatch(msg)) return ChrisActionType.navigatePantherNetWorth;
    if (RegExp(r'\b(market intel|market data|stock market)\b').hasMatch(msg)) return ChrisActionType.navigatePantherMarket;
    if (RegExp(r'\b(portfolio analysis|full portfolio|portfolio report)\b').hasMatch(msg)) return ChrisActionType.navigatePantherPortfolio;
    if (RegExp(r'\b(affordability|can i afford|affordability check)\b').hasMatch(msg)) return ChrisActionType.navigatePantherAffordability;
    if (RegExp(r'\b(payment plan|pay off plan|repayment plan)\b').hasMatch(msg)) return ChrisActionType.navigatePantherPaymentPlan;
    if (RegExp(r'\b(product discover|product suggest|what should i buy)\b').hasMatch(msg)) return ChrisActionType.navigatePantherProductDiscovery;
    if (RegExp(r'\b(trading assistant|trade help)\b').hasMatch(msg)) return ChrisActionType.navigatePantherTrading;
    if (RegExp(r'\b(panther setting|ai setting)\b').hasMatch(msg)) return ChrisActionType.navigatePantherSettings;

    // TickPay sub-pages
    if (RegExp(r'\b(ai pick|recommended product)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayAiPicks;
    if (RegExp(r'\b(ai shop|shop with ai|smart shop)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayAiShop;
    if (RegExp(r'\b(order history|past order|my order)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayOrderHistory;
    if (RegExp(r'\b(upcoming payment|scheduled payment|next payment)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayUpcomingPayments;
    if (RegExp(r'\b(repay now|pay off plan|repay screen)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayRepayNow;
    if (RegExp(r'\b(payment history|paid payment|past payment)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayPaymentHistory;
    if (RegExp(r'\b(reward|cashback|point)\b').hasMatch(msg) && _hasTickpayContext(msg)) return ChrisActionType.navigateTickpayRewards;
    if (RegExp(r'\b(credit score|credit overview|credit summary|my credit)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayCreditOverview;
    if (RegExp(r'\b(tickpay alert|payment alert|bnpl alert)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayAlerts;
    if (RegExp(r'\b(auto pay|automatic payment|autopay)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayAutoPay;
    if (RegExp(r'\b(active plan|current plan|my plan|bnpl plan)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayActivePlans;
    if (RegExp(r'\b(tickpay ai|bnpl ai)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayAi;
    if (RegExp(r'\b(discover|browse shop|explore store)\b').hasMatch(msg)) return ChrisActionType.navigateTickpayDiscover;
    if (RegExp(r'\b(search product|find product|search shop)\b').hasMatch(msg)) return ChrisActionType.navigateTickpaySearch;

    // BlockHub sub-pages
    if (RegExp(r'\b(nft|non.fungible|digital art|nft market)\b').hasMatch(msg)) return ChrisActionType.navigateBlockHubNft;
    if (RegExp(r'\b(crypto market|market cap|coin price|top gainer|top loser|trending coin)\b').hasMatch(msg)) return ChrisActionType.navigateBlockHubMarkets;
    if (RegExp(r'\b(crypto portfolio|my crypto|crypto holding)\b').hasMatch(msg)) return ChrisActionType.navigateBlockHubPortfolio;

    // LifeX sub-pages
    if (RegExp(r'\b(health|wellness|fitness)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexHealth;
    if (RegExp(r'\b(finance|money goal|financial wellness)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexFinance;
    if (RegExp(r'\b(activity|steps|workout|exercise)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexActivity;
    if (RegExp(r'\b(education|learn|course|study)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexEducation;
    if (RegExp(r'\b(spiritual|mindful|meditat|reflect)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexSpiritual;
    if (RegExp(r'\b(vision|goal|dream|vision board)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexVision;
    if (RegExp(r'\b(family|parenting|kid)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexFamily;
    if (RegExp(r'\b(relationship|dating|partner|romance)\b').hasMatch(msg)) return ChrisActionType.navigateLifexRelationship;
    if (RegExp(r'\b(social|network|friend|community)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexSocial;
    if (RegExp(r'\b(feed|post|news)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexFeed;
    if (RegExp(r'\b(ai insight|life insight|coaching insight)\b').hasMatch(msg)) return ChrisActionType.navigateLifexAiInsights;
    if (RegExp(r'\b(export|download data|export data|my data)\b').hasMatch(msg) && _hasLifexContext(msg)) return ChrisActionType.navigateLifexExport;

    // Profile sub-pages
    if (RegExp(r'\b(change password|update password|new password)\b').hasMatch(msg)) return ChrisActionType.navigateChangePassword;
    if (RegExp(r'\b(notification|push notification|alert setting)\b').hasMatch(msg)) return ChrisActionType.navigateNotifications;

    // Wallet actions
    if (RegExp(r'\b(atm|find atm|nearest atm|cash machine)\b').hasMatch(msg)) return ChrisActionType.navigateFindAtm;
    if (RegExp(r'\b(bank transfer|ach|direct.*bank)\b').hasMatch(msg)) return ChrisActionType.navigateBankTransfer;

    // Top-level pages
    if (RegExp(r'\b(lifex|life x|life coaching|life hub)\b').hasMatch(msg)) return ChrisActionType.navigateLifex;
    if (RegExp(r'\b(blockhub|block hub|crypto|nft|bitcoin|ethereum)\b').hasMatch(msg)) return ChrisActionType.navigateBlockHub;
    if (RegExp(r'\b(tickpay|tick pay|bnpl|shopping|buy now pay)\b').hasMatch(msg)) return ChrisActionType.navigateTickPay;
    if (RegExp(r'\b(panther|ai chat|ai advisor|financial ai|panther ai)\b').hasMatch(msg)) return ChrisActionType.navigatePantherAi;
    if (RegExp(r'\b(wallet|my wallet|my card)\b').hasMatch(msg)) return ChrisActionType.navigateWallet;
    if (RegExp(r'\b(profile|settings|account settings|my account)\b').hasMatch(msg)) return ChrisActionType.navigateProfile;
    if (RegExp(r'\b(history|transaction history|past transaction)\b').hasMatch(msg)) return ChrisActionType.navigateHistory;
    if (RegExp(r'\b(exchange|fx|foreign exchange|currency)\b').hasMatch(msg)) return ChrisActionType.navigateExchange;
    if (RegExp(r'\b(transfer|send money|wire)\b').hasMatch(msg)) return ChrisActionType.navigateTransfer;
    if (RegExp(r'\b(add money|deposit|top up)\b').hasMatch(msg)) return ChrisActionType.navigateAddMoney;
    if (RegExp(r'\b(home|dashboard|main page)\b').hasMatch(msg)) return ChrisActionType.navigateHome;

    return null;
  }

  static bool _hasLifexContext(String msg) =>
      RegExp(r'\b(lifex|life x|life coaching|life hub|my)\b').hasMatch(msg) ||
      !RegExp(r'\b(go to|open|show)\b').hasMatch(msg);

  static bool _hasTickpayContext(String msg) =>
      RegExp(r'\b(tickpay|tick pay|bnpl|installment|buy now)\b').hasMatch(msg) ||
      !RegExp(r'\b(go to|open|show)\b').hasMatch(msg);

  static const _currencyKeywords = {
    'usd': 'USD', 'dollar': 'USD', 'dollars': 'USD', 'us dollar': 'USD',
    'eur': 'EUR', 'euro': 'EUR', 'euros': 'EUR',
    'gbp': 'GBP', 'pound': 'GBP', 'pounds': 'GBP', 'sterling': 'GBP',
    'jpy': 'JPY', 'yen': 'JPY',
    'cad': 'CAD', 'canadian': 'CAD',
    'aud': 'AUD', 'australian': 'AUD',
    'chf': 'CHF', 'swiss': 'CHF', 'franc': 'CHF',
    'cny': 'CNY', 'yuan': 'CNY', 'rmb': 'CNY',
    'inr': 'INR', 'rupee': 'INR', 'rupees': 'INR',
    'ngn': 'NGN', 'naira': 'NGN',
    'etb': 'ETB', 'birr': 'ETB',
    'krw': 'KRW', 'won': 'KRW',
    'mxn': 'MXN', 'peso': 'MXN',
    'brl': 'BRL', 'real': 'BRL',
    'zar': 'ZAR', 'rand': 'ZAR',
  };
}
