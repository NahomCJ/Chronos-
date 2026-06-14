import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';

class LifeXOnboardingPage extends StatefulWidget {
  const LifeXOnboardingPage({super.key});

  @override
  State<LifeXOnboardingPage> createState() => _LifeXOnboardingPageState();
}

class _LifeXOnboardingPageState extends State<LifeXOnboardingPage>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF08080F);
  static const _teal = Color(0xFF0F766E);
  static const _tealLight = Color(0xFF14B8A6);
  static const _card = Color(0xFF0F0F1C);

  final List<_ChatMessage> _messages = [];
  List<String> _currentOptions = [];
  bool _isTyping = false;
  bool _surveyComplete = false;
  int _step = 0;
  final ScrollController _scrollCtrl = ScrollController();

  String _situation = '';
  String _debt = '';
  String _debtRange = '';
  String _moneyRel = '';
  String _active = '';
  String _relationship = '';
  String _priority = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSurvey());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _startSurvey() async {
    await _showTyping(900);
    _addMessage(_ChrisMessage(
        "Hey! I'm Chris 👋  I'm your personal life guide here on Chronos."));
    await Future.delayed(const Duration(milliseconds: 700));
    await _showTyping(1100);
    _addMessage(_ChrisMessage(
        "Let me take 2 minutes to understand where you are right now — not to judge, just to actually help."));
    await Future.delayed(const Duration(milliseconds: 500));
    await _showTyping(800);
    _addMessage(_ChrisMessage("What's your current situation?"));
    _showOptions(
        ['Student', 'Working full-time', 'Student + Working', 'Other']);
  }

  Future<void> _showTyping(int ms) async {
    setState(() => _isTyping = true);
    await Future.delayed(Duration(milliseconds: ms));
    if (mounted) setState(() => _isTyping = false);
  }

  void _addMessage(_ChatMessage msg) {
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _showOptions(List<String> options) {
    setState(() => _currentOptions = options);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onOptionTap(String option) async {
    _addMessage(_UserMessage(option));
    setState(() => _currentOptions = []);
    await _processAnswer(option);
  }

  Future<void> _processAnswer(String answer) async {
    await Future.delayed(const Duration(milliseconds: 300));

    switch (_step) {
      case 0:
        _situation = answer;
        _step++;
        await _showTyping(900);
        _addMessage(_ChrisMessage("Got it. Do you carry any debt right now?"));
        _showOptions(
            ['No debt', 'Credit card', 'Student loans', 'Multiple types']);
        break;

      case 1:
        _debt = answer;
        _step++;
        if (answer != 'No debt') {
          await _showTyping(700);
          _addMessage(
              _ChrisMessage("Roughly what range are we talking?"));
          _showOptions(
              ['Under \$5K', '\$5K – \$20K', '\$20K – \$50K', 'Over \$50K']);
        } else {
          _step++;
          await _showTyping(900);
          _addMessage(_ChrisMessage(
              "Nice — no debt is a solid foundation. How's your relationship with money day to day?"));
          _showOptions([
            'I save consistently',
            'I spend most of what I make',
            'I pretty much break even',
            'Honestly not sure',
          ]);
        }
        break;

      case 2:
        _debtRange = answer;
        _step++;
        await _showTyping(900);
        _addMessage(_ChrisMessage(
            "Okay, I've got that. How's your relationship with money day to day?"));
        _showOptions([
          'I save consistently',
          'I spend most of what I make',
          'I pretty much break even',
          'Honestly not sure',
        ]);
        break;

      case 3:
        _moneyRel = answer;
        _step++;
        await _showTyping(800);
        _addMessage(_ChrisMessage("Do you stay active or work out?"));
        _showOptions(['Yes, regularly', 'Here and there', 'Not really']);
        break;

      case 4:
        _active = answer;
        _step++;
        await _showTyping(700);
        _addMessage(_ChrisMessage("Are you in a relationship?"));
        _showOptions(['Yes', 'Single', 'Prefer not to say']);
        break;

      case 5:
        _relationship = answer;
        _step++;
        await _showTyping(800);
        _addMessage(_ChrisMessage(
            "Last one — what's the one area you most want to get a handle on?"));
        _showOptions([
          'My money & finances',
          'My health & energy',
          'My goals & future',
          'My relationships',
        ]);
        break;

      case 6:
        _priority = answer;
        _step++;
        await _showTyping(1200);
        _addMessage(_ChrisMessage(
            "That's all I need for now. Based on what you've shared, here's where you stand."));
        await Future.delayed(const Duration(milliseconds: 900));
        await _showTyping(600);
        _addMessage(_ChrisMessage(
            "I'll guide you from here — one step at a time. No overwhelm. 🙌"));
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) setState(() => _surveyComplete = true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (_isTyping && i == _messages.length) {
                        return const _TypingIndicator();
                      }
                      return _buildMessage(_messages[i]);
                    },
                  ),
                ),
                if (_currentOptions.isNotEmpty && !_surveyComplete)
                  _buildOptions(),
              ],
            ),
          ),
          if (_surveyComplete)
            _LifeSnapshotOverlay(
              situation: _situation,
              debt: _debt,
              moneyRel: _moneyRel,
              active: _active,
              relationship: _relationship,
              priority: _priority,
              onDone: () => context.go(RouteConstants.lifex.toPath),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(RouteConstants.lifex.toPath),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white54, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _teal.withValues(alpha: 0.25),
              border: Border.all(
                  color: _tealLight.withValues(alpha: 0.5), width: 1),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _tealLight, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chris',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Text('LifeX Guide',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11)),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: _teal.withValues(alpha: 0.4), width: 1),
            ),
            child: const Text('Life Survey',
                style: TextStyle(
                    color: _tealLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    if (msg is _ChrisMessage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _teal.withValues(alpha: 0.2),
                border: Border.all(
                    color: _tealLight.withValues(alpha: 0.4), width: 1),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: _tealLight, size: 13),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07), width: 1),
                ),
                child: Text(msg.text,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        height: 1.5)),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      );
    }
    final user = msg as _UserMessage;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 40),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: const BoxDecoration(
              color: _teal,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(user.text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _currentOptions
            .map((opt) => GestureDetector(
                  onTap: () => _onOptionTap(opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: _teal.withValues(alpha: 0.45), width: 1),
                    ),
                    child: Text(opt,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Chat message types ────────────────────────────────────────────────────────

abstract class _ChatMessage {
  final String text;
  const _ChatMessage(this.text);
}

class _ChrisMessage extends _ChatMessage {
  const _ChrisMessage(super.text);
}

class _UserMessage extends _ChatMessage {
  const _UserMessage(super.text);
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        3,
        (i) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 600)));
    _anims = _ctrls
        .map((c) => Tween<double>(begin: 0, end: -5).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F766E).withValues(alpha: 0.2),
              border: Border.all(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.4),
                  width: 1),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF14B8A6), size: 13),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1C),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: _anims[i],
                  builder: (_, __) => Container(
                    margin: EdgeInsets.only(
                        right: i < 2 ? 4 : 0,
                        bottom: (-_anims[i].value).clamp(0.0, 8.0)),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF14B8A6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Life Snapshot overlay ─────────────────────────────────────────────────────

class _LifeSnapshotOverlay extends StatefulWidget {
  final String situation;
  final String debt;
  final String moneyRel;
  final String active;
  final String relationship;
  final String priority;
  final VoidCallback onDone;

  const _LifeSnapshotOverlay({
    required this.situation,
    required this.debt,
    required this.moneyRel,
    required this.active,
    required this.relationship,
    required this.priority,
    required this.onDone,
  });

  @override
  State<_LifeSnapshotOverlay> createState() => _LifeSnapshotOverlayState();
}

class _LifeSnapshotOverlayState extends State<_LifeSnapshotOverlay>
    with TickerProviderStateMixin {
  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late List<AnimationController> _ringCtrls;
  late List<Animation<double>> _ringAnims;

  static const _domains = [
    _Domain('Financial', Color(0xFF10B981), Icons.trending_up_rounded),
    _Domain('Health', Color(0xFF14B8A6), Icons.favorite_rounded),
    _Domain('Social', Color(0xFFEF4444), Icons.group_rounded),
    _Domain('Educational', Color(0xFF6366F1), Icons.school_rounded),
    _Domain('Relationship', Color(0xFFEC4899), Icons.favorite_border_rounded),
    _Domain('Vision', Color(0xFF3B82F6), Icons.remove_red_eye_rounded),
    _Domain('Spiritual', Color(0xFF8B5CF6), Icons.self_improvement_rounded),
  ];

  late List<double> _scores;

  @override
  void initState() {
    super.initState();
    _scores = _calculateScores();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);

    _ringCtrls = List.generate(
        7,
        (_) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1100)));
    _ringAnims = _ringCtrls
        .map((c) =>
            CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _enterCtrl.forward();
    _animateRings();
  }

  List<double> _calculateScores() {
    double fin = 0.5;
    if (widget.moneyRel == 'I save consistently') fin = 0.82;
    else if (widget.moneyRel == 'I pretty much break even') fin = 0.54;
    else if (widget.moneyRel == 'I spend most of what I make') fin = 0.36;
    else fin = 0.44;
    if (widget.debt == 'No debt') fin = (fin + 0.1).clamp(0.0, 1.0);
    else if (widget.debt == 'Multiple types') fin = (fin - 0.1).clamp(0.0, 1.0);

    final health = widget.active == 'Yes, regularly'
        ? 0.78
        : widget.active == 'Here and there'
            ? 0.54
            : 0.33;

    final edu = widget.situation.contains('Student') ? 0.70 : 0.58;
    final rel = widget.relationship == 'Yes' ? 0.64 : 0.54;
    final vision = widget.priority == 'My goals & future' ? 0.70 : 0.48;

    return [fin, health, 0.60, edu, rel, vision, 0.50];
  }

  void _animateRings() async {
    await Future.delayed(const Duration(milliseconds: 350));
    for (int i = 0; i < 7; i++) {
      await Future.delayed(const Duration(milliseconds: 130));
      if (mounted) _ringCtrls[i].forward();
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    for (final c in _ringCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: const Color(0xFF08080F).withValues(alpha: 0.97),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF14B8A6).withValues(alpha: 0.5),
                        width: 1),
                  ),
                  child: const Text('YOUR LIFE SNAPSHOT',
                      style: TextStyle(
                          color: Color(0xFF14B8A6),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                ),
                const SizedBox(height: 14),
                const Text("Here's where\nyou are right now",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15)),
                const SizedBox(height: 8),
                Text(
                    "This is your starting point. Chris will guide you from here — slowly.",
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        height: 1.5)),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: 7,
                    itemBuilder: (ctx, i) {
                      final d = _domains[i];
                      final targetScore = _scores[i];
                      return AnimatedBuilder(
                        animation: _ringAnims[i],
                        builder: (_, __) {
                          final progress =
                              _ringAnims[i].value * targetScore;
                          final pct = (progress * 100).round();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 62,
                                    height: 62,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 5,
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.07),
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              d.color),
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(d.icon, color: d.color, size: 13),
                                      const SizedBox(height: 2),
                                      Text('$pct%',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight:
                                                  FontWeight.w800)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(d.name,
                                  style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.65),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F1C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F766E)
                              .withValues(alpha: 0.15),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Color(0xFF14B8A6), size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "These scores sharpen as you use Chronos. Chris is learning your patterns.",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 12,
                              height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: widget.onDone,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F766E)
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Let's Go",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Domain {
  final String name;
  final Color color;
  final IconData icon;
  const _Domain(this.name, this.color, this.icon);
}
