import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

enum ChrisActionType {
  exchange,
  transfer,
  checkBalance,
  bnplCheck,
  addMoney,
  unknown,
}

class ChrisIntent {
  final ChrisActionType type;
  final double? amount;
  final String? fromCurrency;
  final String? toCurrency;
  final String? recipientHint;
  final String? merchant;
  final String rawMessage;

  const ChrisIntent({
    required this.type,
    this.amount,
    this.fromCurrency,
    this.toCurrency,
    this.recipientHint,
    this.merchant,
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

  const ChrisActionPlan({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.execute,
    this.warning,
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

  // ── Intent parsing ──────────────────────────────────────────────────────

  static ChrisIntent parseIntent(String raw) {
    final msg = raw.toLowerCase().trim();
    final amount = _parseAmount(msg);

    if (_isExchange(msg)) {
      return ChrisIntent(
        type: ChrisActionType.exchange,
        amount: amount,
        fromCurrency: _parseCurrency(msg, isSource: true),
        toCurrency: _parseCurrency(msg, isSource: false),
        rawMessage: raw,
      );
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
    if (_isBalance(msg)) {
      return ChrisIntent(type: ChrisActionType.checkBalance, rawMessage: raw);
    }
    if (_isBnpl(msg)) {
      return ChrisIntent(
        type: ChrisActionType.bnplCheck,
        amount: amount,
        merchant: _parseMerchant(msg),
        rawMessage: raw,
      );
    }
    if (_isAddMoney(msg)) {
      return ChrisIntent(
        type: ChrisActionType.addMoney,
        amount: amount,
        rawMessage: raw,
      );
    }
    return ChrisIntent(type: ChrisActionType.unknown, rawMessage: raw);
  }

  // ── Plan building ───────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> buildPlan(ChrisIntent intent) async {
    switch (intent.type) {
      case ChrisActionType.exchange:
        return _exchangePlan(intent);
      case ChrisActionType.transfer:
        return _transferPlan(intent);
      case ChrisActionType.checkBalance:
        return _balancePlan();
      case ChrisActionType.bnplCheck:
        return _bnplPlan(intent);
      case ChrisActionType.addMoney:
        return _addMoneyPlan(intent);
      case ChrisActionType.unknown:
        return null;
    }
  }

  // ── Exchange ────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _exchangePlan(ChrisIntent intent) async {
    if (intent.amount == null || intent.amount! <= 0) return null;

    final from = (intent.fromCurrency ?? 'USD').toUpperCase();
    final to = (intent.toCurrency ?? 'EUR').toUpperCase();
    if (from == to) return null;

    final amount = intent.amount!;

    try {
      final walletId = await _defaultWalletId();
      if (walletId == null) {
        return _errorPlan(
          ChrisActionType.exchange,
          'No wallet found',
          'Set up a wallet before exchanging currencies.',
        );
      }

      final quoteData = await _api.post('/api/fx/quote', {
        'sourceWalletId': walletId,
        'destCurrency': to,
        'amount': amount,
      });

      final quoteId = quoteData['quoteId']?.toString() ??
          quoteData['id']?.toString() ?? '';
      final rate =
          (quoteData['rate'] as num?)?.toDouble() ?? 0.0;
      final converted =
          (quoteData['convertedAmount'] as num?)?.toDouble() ??
              (amount * rate);
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
            final res =
                await _api.post('/api/fx/execute', {'quoteId': quoteId});
            return ChrisActionResult(
              success: true,
              message:
                  'Done! Exchanged ${amount.toStringAsFixed(2)} $from → ${converted.toStringAsFixed(2)} $to.',
              details: {
                'Status': res['status']?.toString() ?? 'Completed',
                if ((res['orderId'] ?? res['id']) != null)
                  'Order ID': (res['orderId'] ?? res['id']).toString(),
              },
            );
          } catch (e) {
            return ChrisActionResult(
                success: false, message: _clean(e.toString()));
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
        execute: () async => ChrisActionResult(
            success: false,
            message: 'Rate unavailable: ${_clean(e.toString())}'),
        warning: 'Live rate unavailable. Check connection and retry.',
      );
    }
  }

  // ── Transfer ────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _transferPlan(ChrisIntent intent) async {
    if (intent.amount == null || intent.amount! <= 0) return null;

    final amount = intent.amount!;
    final currency =
        (intent.fromCurrency ?? 'USD').toUpperCase();

    try {
      final wallets = await _walletList();
      final source = wallets.isNotEmpty ? wallets.first : <String, dynamic>{};
      final sourceId = source['id']?.toString() ?? '';
      final sourceName =
          source['name']?.toString() ?? source['type']?.toString() ?? 'Main Wallet';
      final balance = (source['balance'] as num?)?.toDouble() ?? 0.0;
      final hasEnough = balance >= amount;
      final recipient = intent.recipientHint;

      // If user named a recipient we try to find their wallet via accounts search
      String? destWalletId;
      String? destLabel;
      if (recipient != null) {
        // Attempt lookup backend may support ?search param
        try {
          final found = await _api.getList(
              '/api/core/accounts?search=${Uri.encodeComponent(recipient)}');
          if (found.isNotEmpty) {
            final acc = found.first as Map<String, dynamic>;
            final accId = acc['id']?.toString() ?? '';
            final accWallets = await _api.getList('/api/wallet/list/$accId');
            if (accWallets.isNotEmpty) {
              destWalletId =
                  (accWallets.first as Map<String, dynamic>)['id']?.toString();
              destLabel =
                  acc['firstName']?.toString() ?? acc['name']?.toString() ?? recipient;
            }
          }
        } catch (_) {
          // Recipient lookup not supported or failed
        }
      }

      final canAutoExecute = sourceId.isNotEmpty &&
          destWalletId != null &&
          hasEnough;

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
          if (recipient != null && destLabel == null)
            ('Recipient', '$recipient: wallet not found'),
          if (!hasEnough) ('⚠ Warning', 'Insufficient balance'),
        ],
        warning: !hasEnough
            ? 'Your balance (${balance.toStringAsFixed(2)} $currency) is less than the transfer amount.'
            : (recipient != null && destWalletId == null)
                ? 'Recipient\'s wallet not found. Chris cannot auto-complete this transfer. Open the Transfer page to search manually.'
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
              message:
                  'Done! Transferred ${amount.toStringAsFixed(2)} $currency to $destLabel.',
              details: {
                'Status': res['status']?.toString() ?? 'Initiated',
                if ((res['id'] ?? res['transferId']) != null)
                  'Reference': (res['id'] ?? res['transferId']).toString(),
              },
            );
          } catch (e) {
            return ChrisActionResult(
                success: false, message: _clean(e.toString()));
          }
        },
      );
    } catch (e) {
      return null;
    }
  }

  // ── Balance ─────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _balancePlan() async {
    try {
      final wallets = await _walletList();
      if (wallets.isEmpty) return null;

      final details = <(String, String)>[];
      for (final w in wallets.take(5)) {
        final name = w['name']?.toString() ??
            w['type']?.toString() ?? 'Wallet';
        final bal = (w['balance'] as num?)?.toDouble() ?? 0.0;
        final cur = w['currency']?.toString() ?? 'USD';
        details.add((name, '${bal.toStringAsFixed(2)} $cur'));
      }

      return ChrisActionPlan(
        type: ChrisActionType.checkBalance,
        title: 'Your Balances',
        subtitle: '${wallets.length} wallet${wallets.length == 1 ? '' : 's'} found.',
        details: details,
        execute: () async => ChrisActionResult(
          success: true,
          message: 'Here are your current balances.',
        ),
      );
    } catch (e) {
      return null;
    }
  }

  // ── BNPL ─────────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _bnplPlan(ChrisIntent intent) async {
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
          final riskScore =
              (res['riskScore'] as num?)?.toDouble() ?? 0;
          final maxAmount =
              (res['maxAmount'] as num?)?.toDouble() ?? 0;
          final msg = res['message']?.toString() ?? '';
          return ChrisActionResult(
            success: approved,
            message: approved ? '✓ Approved: $msg' : '✗ Not approved: $msg',
            details: {
              'Decision': approved ? 'Approved ✓' : 'Declined ✗',
              'Risk Score': '${(riskScore * 100).toStringAsFixed(0)}%',
              if (approved && maxAmount > 0)
                'Max Approved': '\$${maxAmount.toStringAsFixed(2)}',
            },
          );
        } catch (e) {
          return ChrisActionResult(
              success: false,
              message: 'Could not run check: ${_clean(e.toString())}');
        }
      },
    );
  }

  // ── Add Money ─────────────────────────────────────────────────────────────

  static Future<ChrisActionPlan?> _addMoneyPlan(ChrisIntent intent) async {
    final amount = intent.amount;
    return ChrisActionPlan(
      type: ChrisActionType.addMoney,
      title: 'Add Money',
      subtitle: amount != null
          ? '\$${amount.toStringAsFixed(2)} via ACH deposit'
          : 'ACH bank deposit',
      details: [
        if (amount != null) ('Amount', '\$${amount.toStringAsFixed(2)}'),
        ('Method', 'ACH Bank Transfer'),
        ('Processing Time', '1–3 business days'),
      ],
      execute: () async => const ChrisActionResult(
        success: false,
        message: 'Opening the deposit flow. You\'ll need to confirm your linked bank account.',
      ),
      warning: 'ACH deposits require bank account verification.',
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────

  static Future<String?> _defaultWalletId() async {
    final wallets = await _walletList();
    return wallets.isNotEmpty ? wallets.first['id']?.toString() : null;
  }

  static Future<List<Map<String, dynamic>>> _walletList() async {
    try {
      final accounts = await _api.getList('/api/core/accounts');
      if (accounts.isEmpty) return [];
      final accountId =
          (accounts.first as Map<String, dynamic>)['id']?.toString();
      if (accountId == null) return [];
      final wallets = await _api.getList('/api/wallet/list/$accountId');
      return wallets.map((w) => w as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  static ChrisActionPlan _errorPlan(
      ChrisActionType type, String title, String msg) {
    return ChrisActionPlan(
      type: type,
      title: title,
      subtitle: msg,
      details: [],
      execute: () async =>
          ChrisActionResult(success: false, message: msg),
    );
  }

  static String _clean(String err) =>
      err.replaceAll('Exception: ', '').trim();

  // ── Pattern matchers ───────────────────────────────────────────────────

  static bool _isExchange(String m) =>
      RegExp(r'\b(exchange|convert|swap|change.*to|fx)\b').hasMatch(m) ||
      (_hasCurrencyPair(m) && m.contains(' to '));

  static bool _isTransfer(String m) =>
      RegExp(r'\b(transfer|send|pay|wire|move)\b').hasMatch(m);

  static bool _isBalance(String m) =>
      RegExp(r'\b(balance|how much|what.*have|my money|my balance|account balance|funds)\b')
          .hasMatch(m);

  static bool _isBnpl(String m) =>
      RegExp(r'\b(afford|bnpl|tickpay|buy now pay|can i buy|installment|split)\b')
          .hasMatch(m);

  static bool _isAddMoney(String m) =>
      RegExp(r'\b(add money|deposit|top up|fund my|load)\b').hasMatch(m);

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
      // "from USD" or amount directly precedes a currency code
      final m = RegExp(r'\bfrom\s+(\w+)', caseSensitive: false).firstMatch(msg);
      if (m != null) return _resolveCurrency(m.group(1)!);
      // "100 usd to" pattern
      final m2 = RegExp(r'\d\s+(\w{3})\s+to\b', caseSensitive: false).firstMatch(msg);
      if (m2 != null) return _resolveCurrency(m2.group(1)!);
      return 'USD';
    } else {
      // "to EUR" or "into EUR"
      final m = RegExp(r'\b(?:to|into)\s+(\w+)', caseSensitive: false).firstMatch(msg);
      if (m != null) {
        final c = _resolveCurrency(m.group(1)!);
        if (c != null && c != 'USD') return c;
      }
      // Fallback: find any currency that isn't USD
      for (final entry in _currencyKeywords.entries) {
        if (msg.contains(entry.key) && entry.value != 'USD') {
          return entry.value;
        }
      }
      return null;
    }
  }

  static String? _resolveCurrency(String word) {
    final key = word.toLowerCase();
    return _currencyKeywords[key];
  }

  static String? _parseRecipient(String msg) {
    // Avoid matching currency names as recipients
    final m = RegExp(
            r'\bto\s+([A-Za-z][A-Za-z\s]{1,25}?)(?:\s+for|\s*$|\s+\d|\s+from)',
            caseSensitive: false)
        .firstMatch(msg);
    if (m != null) {
      final name = m.group(1)!.trim();
      if (!_currencyKeywords.containsKey(name.toLowerCase())) return name;
    }
    return null;
  }

  static String? _parseMerchant(String msg) {
    final m = RegExp(r'\bat\s+([A-Za-z][A-Za-z\s]{1,25})(?:\s|$)',
            caseSensitive: false)
        .firstMatch(msg);
    return m?.group(1)?.trim();
  }

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
