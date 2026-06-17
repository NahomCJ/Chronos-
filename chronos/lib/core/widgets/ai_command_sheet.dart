import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/chris_action_service.dart';

// ── Contact model ─────────────────────────────────────────────────────────────

class _Contact {
  final String name;
  final String phone;
  final String initials;
  final String accountId;

  const _Contact({
    required this.name,
    required this.phone,
    required this.initials,
    required this.accountId,
  });
}

const _mockContacts = <_Contact>[
  _Contact(name: 'Martha Johnson', phone: '+1 (555) 204-8801', initials: 'MJ', accountId: 'acc_mj1'),
  _Contact(name: 'Martha Addis', phone: '+251 91 234 5678', initials: 'MA', accountId: 'acc_ma2'),
  _Contact(name: 'Martha Tesfaye', phone: '+251 91 887 3321', initials: 'MT', accountId: 'acc_mt3'),
  _Contact(name: 'Martha Williams', phone: '+1 (555) 789-3344', initials: 'MW', accountId: 'acc_mw4'),
  _Contact(name: 'Sarah Connor', phone: '+1 (555) 100-2300', initials: 'SC', accountId: 'acc_sc1'),
  _Contact(name: 'Sarah Mitchell', phone: '+1 (555) 887-4400', initials: 'SM', accountId: 'acc_sm2'),
  _Contact(name: 'John Smith', phone: '+1 (555) 001-0001', initials: 'JS', accountId: 'acc_js1'),
  _Contact(name: 'John Doe', phone: '+1 (555) 002-0002', initials: 'JD', accountId: 'acc_jd2'),
  _Contact(name: 'Alex Turner', phone: '+1 (555) 300-4000', initials: 'AT', accountId: 'acc_at1'),
  _Contact(name: 'Nahom Teklay', phone: '+251 91 800 0000', initials: 'NT', accountId: 'acc_nt1'),
  _Contact(name: 'Daniel Haile', phone: '+251 91 555 1234', initials: 'DH', accountId: 'acc_dh1'),
  _Contact(name: 'Meron Getachew', phone: '+251 91 777 9900', initials: 'MG', accountId: 'acc_mg1'),
];

// ── Sheet state ───────────────────────────────────────────────────────────────

enum _SheetState { idle, loading, pickingContact, confirming, executing, done }

// ── Widget ────────────────────────────────────────────────────────────────────

class AiCommandSheet extends StatefulWidget {
  final void Function(String command) onCommand;

  const AiCommandSheet({super.key, required this.onCommand});

  @override
  State<AiCommandSheet> createState() => _AiCommandSheetState();
}

class _AiCommandSheetState extends State<AiCommandSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  _SheetState _sheetState = _SheetState.idle;
  ChrisActionPlan? _plan;
  ChrisActionResult? _result;

  // Contact disambiguation
  List<_Contact> _matchingContacts = [];
  ChrisIntent? _pendingIntent;

  static const _suggestions = [
    ('Transfer Money', Icons.arrow_upward_rounded),
    ('Add Money', Icons.add_circle_outline),
    ('Exchange', Icons.swap_horiz_rounded),
    ('Crypto', Icons.currency_bitcoin),
    ('Wallet', Icons.account_balance_wallet_outlined),
    ('TickPay', Icons.schedule_outlined),
    ('AI Insights', Icons.psychology_outlined),
  ];

  static const _bg = Color(0xFF111111);
  static const _chipBg = Color(0xFF252525);
  static const _toolbarBtnBg = Color(0xFF1E1E1E);
  static const _pillBg = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _controller.addListener(() => setState(() {}));
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus());
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize();
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    if (!_speechAvailable) return;
    setState(() {
      _isListening = true;
      _controller.clear();
    });
    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _controller.text = result.recognizedWords;
            if (result.finalResult) _isListening = false;
          });
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _pulseCtrl.dispose();
    if (_isListening) _speech.stop();
    super.dispose();
  }

  // ── Action flow ───────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final intent = ChrisActionService.parseIntent(text);

    if (intent.type == ChrisActionType.unknown) {
      widget.onCommand(text);
      return;
    }

    // Transfer with named recipient → check contact list for disambiguation
    if (intent.type == ChrisActionType.transfer &&
        intent.recipientHint != null) {
      final hint = intent.recipientHint!.toLowerCase().trim();
      final matches = _mockContacts.where((c) {
        final nameLower = c.name.toLowerCase();
        final firstName = c.name.split(' ').first.toLowerCase();
        return nameLower.contains(hint) || hint.contains(firstName);
      }).toList();

      if (matches.length > 1) {
        setState(() {
          _pendingIntent = intent;
          _matchingContacts = matches;
          _sheetState = _SheetState.pickingContact;
        });
        return;
      }
    }

    await _executePlan(intent);
  }

  Future<void> _onContactSelected(_Contact contact) async {
    if (_pendingIntent == null) return;
    setState(() => _sheetState = _SheetState.loading);

    final original = _pendingIntent!;
    final resolved = ChrisIntent(
      type: original.type,
      amount: original.amount,
      fromCurrency: original.fromCurrency,
      toCurrency: original.toCurrency,
      recipientHint: contact.name,
      merchant: original.merchant,
      rawMessage: original.rawMessage,
    );

    await _executePlan(resolved);
  }

  Future<void> _executePlan(ChrisIntent intent) async {
    setState(() => _sheetState = _SheetState.loading);
    final plan = await ChrisActionService.buildPlan(intent);

    if (!mounted) return;

    if (plan == null) {
      widget.onCommand(intent.rawMessage);
      return;
    }

    // Balance check runs immediately without confirmation
    if (intent.type == ChrisActionType.checkBalance) {
      setState(() {
        _sheetState = _SheetState.executing;
        _plan = plan;
      });
      final res = await plan.execute();
      if (!mounted) return;
      setState(() {
        _sheetState = _SheetState.done;
        _result = ChrisActionResult(
          success: res.success,
          message: res.message,
          details: {for (final d in plan.details) d.$1: d.$2},
        );
      });
      return;
    }

    setState(() {
      _sheetState = _SheetState.confirming;
      _plan = plan;
    });
  }

  Future<void> _confirmAction() async {
    if (_plan == null) return;
    setState(() => _sheetState = _SheetState.executing);
    final result = await _plan!.execute();
    if (!mounted) return;
    setState(() {
      _sheetState = _SheetState.done;
      _result = result;
    });
  }

  void _cancelAction() {
    setState(() {
      _sheetState = _SheetState.idle;
      _plan = null;
      _result = null;
      _pendingIntent = null;
      _matchingContacts = [];
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            decoration: BoxDecoration(
              color: _bg.withValues(alpha: 0.93),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_sheetState == _SheetState.idle ||
                    _sheetState == _SheetState.loading)
                  ..._buildInputBody()
                else if (_sheetState == _SheetState.pickingContact)
                  ..._buildContactPickerBody()
                else if (_sheetState == _SheetState.confirming)
                  ..._buildConfirmBody()
                else if (_sheetState == _SheetState.executing)
                  ..._buildExecutingBody()
                else if (_sheetState == _SheetState.done)
                  ..._buildResultBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Input state ───────────────────────────────────────────────────────────

  List<Widget> _buildInputBody() {
    final isLoading = _sheetState == _SheetState.loading;
    return [
      TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 16,
          height: 1.55,
        ),
        maxLines: 4,
        minLines: 1,
        enabled: !isLoading,
        decoration: InputDecoration(
          hintText: _isListening
              ? 'Listening...'
              : isLoading
                  ? 'Chris is thinking...'
                  : 'Type / for search modes',
          hintStyle: TextStyle(
            color: _isListening
                ? const Color(0xFF9B59F5).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.28),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        onSubmitted: (_) => _submit(),
      ),
      if (isLoading) ...[
        const SizedBox(height: 10),
        LinearProgressIndicator(
          backgroundColor: const Color(0xFF252525),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9B59F5)),
          minHeight: 2,
          borderRadius: BorderRadius.circular(1),
        ),
      ],
      const SizedBox(height: 16),
      if (!isLoading)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _suggestions.map((s) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => widget.onCommand(s.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: _chipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.$2, color: Colors.grey[500], size: 12),
                        const SizedBox(width: 5),
                        Text(
                          s.$1,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      const SizedBox(height: 14),
      Row(
        children: [
          _circleBtn(
            icon: Icons.add,
            onTap: () => _controller.clear(),
          ),
          const SizedBox(width: 8),
          _pillBtn(
            icon: Icons.psychology_rounded,
            label: 'Chris',
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _circleBtn(
            icon: Icons.keyboard_outlined,
            onTap: () => _focusNode.requestFocus(),
          ),
          const Spacer(),
          Text(
            'Panther AI',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _speechAvailable ? _toggleListening : null,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, _) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnim.value : 1.0,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening
                          ? const Color(0xFFE91E63).withValues(alpha: 0.15)
                          : _toolbarBtnBg,
                      border: Border.all(
                        color: _isListening
                            ? const Color(0xFFE91E63).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.06),
                        width: 0.6,
                      ),
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening
                          ? const Color(0xFFE91E63)
                          : Colors.grey[500],
                      size: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isLoading ? null : _submit,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _controller.text.trim().isEmpty || isLoading
                    ? _toolbarBtnBg
                    : Colors.white,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 0.6,
                ),
              ),
              child: Icon(
                Icons.graphic_eq_rounded,
                color: _controller.text.trim().isEmpty || isLoading
                    ? Colors.grey[600]
                    : Colors.black,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // ── Contact picker state ───────────────────────────────────────────────────

  List<Widget> _buildContactPickerBody() {
    final hint = _pendingIntent?.recipientHint ?? 'someone';
    return [
      Row(
        children: [
          GestureDetector(
            onTap: _cancelAction,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _toolbarBtnBg,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 0.6,
                ),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: Colors.grey[400], size: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Who did you mean?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_matchingContacts.length} contacts match "$hint"',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        child: Column(
          children: _matchingContacts.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Column(
              children: [
                GestureDetector(
                  onTap: () => _onContactSelected(c),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7B3FE4), Color(0xFF4A00E0)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            c.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.phone,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF9B59F5).withValues(alpha: 0.12),
                          ),
                          child: const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFF9B59F5), size: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < _matchingContacts.length - 1)
                  Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: _cancelAction,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ];
  }

  // ── Confirm state ─────────────────────────────────────────────────────────

  List<Widget> _buildConfirmBody() {
    final plan = _plan!;
    return [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF9B59F5).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_planIcon(plan.type),
                color: const Color(0xFF9B59F5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plan.subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      if (plan.details.isNotEmpty) ...[
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 0.5,
            ),
          ),
          child: Column(
            children: plan.details.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(d.$1,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13)),
                        Flexible(
                          child: Text(
                            d.$2,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < plan.details.length - 1)
                    Divider(
                      height: 0,
                      thickness: 0.5,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
      if (plan.warning != null) ...[
        const SizedBox(height: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFF9800).withValues(alpha: 0.28),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFFF9800), size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.warning!,
                  style: TextStyle(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.85),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _cancelAction,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _confirmAction,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B3FE4), Color(0xFF4A00E0)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7B3FE4).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // ── Executing state ───────────────────────────────────────────────────────

  List<Widget> _buildExecutingBody() {
    return [
      const SizedBox(height: 20),
      Center(
        child: Column(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          const Color(0xFF9B59F5).withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF9B59F5)),
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Chris is executing…',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _plan?.title ?? '',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
    ];
  }

  // ── Done state ────────────────────────────────────────────────────────────

  List<Widget> _buildResultBody() {
    final result = _result!;
    final ok = result.success;
    return [
      Center(
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ok
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
                    : const Color(0xFFE53935).withValues(alpha: 0.12),
              ),
              child: Icon(
                ok ? Icons.check_rounded : Icons.close_rounded,
                color: ok
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE53935),
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      if (result.details != null && result.details!.isNotEmpty) ...[
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 0.5,
            ),
          ),
          child: Column(
            children:
                result.details!.entries.toList().asMap().entries.map((e) {
              final i = e.key;
              final kv = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(kv.key,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13)),
                        Flexible(
                          child: Text(
                            kv.value,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < result.details!.length - 1)
                    Divider(
                      height: 0,
                      thickness: 0.5,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
      const SizedBox(height: 16),
      GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Done',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ];
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  IconData _planIcon(ChrisActionType type) {
    switch (type) {
      case ChrisActionType.exchange:
        return Icons.swap_horiz_rounded;
      case ChrisActionType.transfer:
        return Icons.arrow_upward_rounded;
      case ChrisActionType.checkBalance:
        return Icons.account_balance_wallet_outlined;
      case ChrisActionType.bnplCheck:
        return Icons.schedule_outlined;
      case ChrisActionType.addMoney:
        return Icons.add_circle_outline;
      case ChrisActionType.buyCrypto:
        return Icons.currency_bitcoin_rounded;
      case ChrisActionType.sellCrypto:
        return Icons.trending_down_rounded;
      case ChrisActionType.sendCrypto:
        return Icons.send_rounded;
      case ChrisActionType.unknown:
        return Icons.psychology_outlined;
    }
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _toolbarBtnBg,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            width: 0.6,
          ),
        ),
        child: Icon(icon, color: Colors.grey[500], size: 15),
      ),
    );
  }

  Widget _pillBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _pillBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey[400], size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey[600], size: 13),
          ],
        ),
      ),
    );
  }
}
