import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/pexels_service.dart';
import '../../domain/entities/net_worth.dart';
import '../../domain/entities/spending_summary.dart';
import '../../domain/usecases/get_net_worth.dart';
import '../../domain/usecases/get_spending_summary.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'chat_visual.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage sendMessage;
  final GetNetWorthDashboard getNetWorthDashboard;
  final GetSpendingSummary getSpendingSummary;
  final SearchProducts searchProducts;

  ChatBloc({
    required this.sendMessage,
    required this.getNetWorthDashboard,
    required this.getSpendingSummary,
    required this.searchProducts,
  }) : super(const ChatIdle()) {
    on<ChatMessageSent>(_onMessageSent);
  }

  static final _productPattern = RegExp(
    r'\bbuy\b|\bpurchase\b|\bafford\b|shop for|show me a|show me the|find me a|looking for a',
    caseSensitive: false,
  );
  static final _portfolioPattern = RegExp(
    r'portfolio|holdings|invest',
    caseSensitive: false,
  );
  static final _debtPattern = RegExp(
    r'\bdebt\b|liabilit|\bowe\b|credit card balance',
    caseSensitive: false,
  );
  static final _netWorthPattern = RegExp(
    r'net worth|my assets|what do i own|financial picture|wealth',
    caseSensitive: false,
  );
  static final _spendingPattern = RegExp(
    r'spending|budget|expenses|where did my money go|how much did i spend',
    caseSensitive: false,
  );

  Future<void> _onMessageSent(
      ChatMessageSent event, Emitter<ChatState> emit) async {
    emit(const ChatThinking());
    try {
      final response = await sendMessage(event.message);
      final visual = await _resolveVisual(event.message);
      emit(ChatReplied(
        reply: response.reply,
        domain: response.domain,
        visual: visual,
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // Chris's reply always comes back as text first — this only decides
  // whether the question also deserves a chart or product cards attached
  // underneath, using data the app's existing net-worth/spending/marketplace
  // usecases already fetch live. Never lets a failed lookup break the chat:
  // any error here just means no visual gets attached.
  Future<ChatVisual?> _resolveVisual(String message) async {
    try {
      if (_productPattern.hasMatch(message)) {
        final visual = await _resolveProductVisual(message);
        if (visual != null) return visual;
      }

      if (_debtPattern.hasMatch(message)) {
        final nw = await getNetWorthDashboard();
        return _debtVisual(nw);
      }

      if (_portfolioPattern.hasMatch(message)) {
        final nw = await getNetWorthDashboard();
        final visual = _portfolioVisual(nw);
        if (visual != null) return visual;
      }

      if (_netWorthPattern.hasMatch(message)) {
        final nw = await getNetWorthDashboard();
        return _netWorthVisual(nw);
      }

      if (_spendingPattern.hasMatch(message)) {
        final now = DateTime.now();
        final summary =
            await getSpendingSummary(month: now.month, year: now.year);
        return _spendingVisual(summary);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<ChatVisual?> _resolveProductVisual(String message) async {
    final products = await searchProducts(message.trim());
    if (products.isEmpty) return null;

    final top = products.take(3).toList();
    final cards = await Future.wait(top.map((p) async {
      String imageUrl = '';
      try {
        final photos = await PexelsService.searchPhotos(
          p.name,
          perPage: 1,
          orientation: 'square',
        );
        if (photos.isNotEmpty) imageUrl = photos.first.medium;
      } catch (_) {
        // No photo — the card still renders with name/price/vendor.
      }
      return ChatProductCard(
        name: p.name,
        price: p.price,
        vendor: p.vendor,
        bnplEligible: p.bnplEligible,
        imageUrl: imageUrl,
      );
    }));

    return ChatVisual.products(title: 'What I found', products: cards);
  }

  ChatVisual _netWorthVisual(NetWorthSummary nw) {
    final slices = <ChatRingSlice>[
      if (nw.bankBalances > 0)
        ChatRingSlice(
            label: 'Bank', value: nw.bankBalances, color: const Color(0xFF3B82F6)),
      if (nw.investments > 0)
        ChatRingSlice(
            label: 'Investments', value: nw.investments, color: const Color(0xFF7C6EF0)),
      if (nw.crypto > 0)
        ChatRingSlice(label: 'Crypto', value: nw.crypto, color: const Color(0xFFF59E0B)),
      if (nw.otherSavings > 0)
        ChatRingSlice(
            label: 'Other savings', value: nw.otherSavings, color: const Color(0xFF14B8A6)),
    ];
    return ChatVisual.ring(
      title: 'Net worth breakdown',
      centerLabel: _fmtK(nw.netWorth),
      centerSubLabel: 'net worth',
      slices: slices,
    );
  }

  ChatVisual? _portfolioVisual(NetWorthSummary nw) {
    if (nw.investmentHoldings.isEmpty) return null;
    const palette = [
      Color(0xFF7C6EF0),
      Color(0xFF3B82F6),
      Color(0xFF14B8A6),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
    ];
    final slices = <ChatRingSlice>[
      for (var i = 0; i < nw.investmentHoldings.length; i++)
        ChatRingSlice(
          label: nw.investmentHoldings[i].tickerSymbol ??
              nw.investmentHoldings[i].name,
          value: nw.investmentHoldings[i].value,
          color: palette[i % palette.length],
        ),
    ];
    return ChatVisual.ring(
      title: 'Portfolio holdings',
      centerLabel: _fmtK(nw.investments),
      centerSubLabel: 'invested',
      slices: slices,
    );
  }

  ChatVisual _debtVisual(NetWorthSummary nw) {
    final slices = <ChatRingSlice>[
      if (nw.mortgage > 0)
        ChatRingSlice(label: 'Mortgage', value: nw.mortgage, color: const Color(0xFF7C6EF0)),
      if (nw.loans > 0)
        ChatRingSlice(label: 'Loans', value: nw.loans, color: const Color(0xFF3B82F6)),
      if (nw.creditCardDebt > 0)
        ChatRingSlice(
            label: 'Credit cards', value: nw.creditCardDebt, color: const Color(0xFFEF4444)),
    ];
    return ChatVisual.ring(
      title: 'Debt breakdown',
      centerLabel: _fmtK(nw.totalLiabilities),
      centerSubLabel: 'total debt',
      slices: slices,
    );
  }

  ChatVisual _spendingVisual(SpendingSummary summary) {
    const palette = [
      Color(0xFF7C6EF0),
      Color(0xFF3B82F6),
      Color(0xFF14B8A6),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFFEC4899),
    ];
    final slices = <ChatRingSlice>[
      for (var i = 0; i < summary.byCategory.length; i++)
        ChatRingSlice(
          label: summary.byCategory[i].name,
          value: summary.byCategory[i].total,
          color: _parseColor(summary.byCategory[i].color) ??
              palette[i % palette.length],
        ),
    ];
    return ChatVisual.ring(
      title: 'Spending this month',
      centerLabel: _fmtK(summary.totalSpent),
      centerSubLabel: 'spent',
      slices: slices,
    );
  }

  Color? _parseColor(String hex) {
    var v = hex.trim();
    if (v.isEmpty) return null;
    if (v.startsWith('#')) v = v.substring(1);
    if (v.length == 6) v = 'FF$v';
    if (v.length != 8) return null;
    final parsed = int.tryParse(v, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  String _fmtK(double v) {
    final abs = v.abs();
    final sign = v < 0 ? '-' : '';
    if (abs >= 1000) return '$sign\$${(abs / 1000).toStringAsFixed(1)}k';
    return '$sign\$${abs.toStringAsFixed(0)}';
  }
}
