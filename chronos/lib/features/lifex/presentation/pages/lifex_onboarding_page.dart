import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/chris_home_fab.dart';

class LifeXOnboardingPage extends StatefulWidget {
  const LifeXOnboardingPage({super.key});

  @override
  State<LifeXOnboardingPage> createState() => _LifeXOnboardingPageState();
}

class _LifeXOnboardingPageState extends State<LifeXOnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  List<String> _currentOptions = [];
  bool _isTyping = false;
  bool _surveyComplete = false;
  int _step = 0;
  String _currentMessage = '';

  String _situation = '';
  String _debt = '';
  String _debtRange = '';
  String _moneyRel = '';
  String _savingsGoal = '';
  String _active = '';
  String _sleepQuality = '';
  String _stressLevel = '';
  String _relationship = '';
  String _socialLife = '';
  String _spiritualPractice = '';
  String _learningHabit = '';
  String _priority = '';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSurvey());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startSurvey() async {
    await _showTyping(900);
    _setMessage("Hey! I'm Chris 👋  I'm your personal life guide here on Chronos.");
    await Future.delayed(const Duration(milliseconds: 1600));
    await _showTyping(1100);
    _setMessage("Let me take 2 minutes to understand where you are right now — not to judge, just to actually help.");
    await Future.delayed(const Duration(milliseconds: 1900));
    await _showTyping(800);
    _setMessage("What's your current situation?");
    _showOptions(['Student', 'Working full-time', 'Student + Working', 'Other']);
  }

  Future<void> _showTyping(int ms) async {
    setState(() {
      _isTyping = true;
      _currentOptions = [];
    });
    await Future.delayed(Duration(milliseconds: ms));
    if (mounted) setState(() => _isTyping = false);
  }

  void _setMessage(String msg) {
    if (mounted) setState(() => _currentMessage = msg);
  }

  void _showOptions(List<String> opts) {
    if (mounted) setState(() => _currentOptions = opts);
  }

  Future<void> _onOptionTap(String option) async {
    setState(() => _currentOptions = []);
    await _processAnswer(option);
  }

  Future<void> _processAnswer(String answer) async {
    await Future.delayed(const Duration(milliseconds: 250));
    switch (_step) {
      case 0:
        _situation = answer;
        _step++;
        await _showTyping(900);
        _setMessage("Got it. Do you carry any debt right now?");
        _showOptions(['No debt', 'Credit card', 'Student loans', 'Multiple types']);
        break;
      case 1:
        _debt = answer;
        _step++;
        if (answer != 'No debt') {
          await _showTyping(700);
          _setMessage("Roughly what range are we talking?");
          _showOptions([r'Under $5K', r'$5K – $20K', r'$20K – $50K', r'Over $50K']);
        } else {
          _step++;
          await _showTyping(900);
          _setMessage("Nice — no debt is a solid foundation. How's your relationship with money day to day?");
          _showOptions(['I save consistently', 'I spend most of what I make', 'I pretty much break even', 'Honestly not sure']);
        }
        break;
      case 2:
        _debtRange = answer;
        _step++;
        await _showTyping(900);
        _setMessage("Okay, I've got that. How's your relationship with money day to day?");
        _showOptions(['I save consistently', 'I spend most of what I make', 'I pretty much break even', 'Honestly not sure']);
        break;
      case 3:
        _moneyRel = answer;
        _step++;
        await _showTyping(700);
        _setMessage("Do you have a savings goal right now?");
        _showOptions(['Yes, specific amount', 'Vaguely, yes', 'Not really', 'Just getting by']);
        break;
      case 4:
        _savingsGoal = answer;
        _step++;
        await _showTyping(800);
        _setMessage("How's your physical activity level?");
        _showOptions(['I work out regularly', 'A few times a week', 'Occasionally', 'Mostly sedentary']);
        break;
      case 5:
        _active = answer;
        _step++;
        await _showTyping(700);
        _setMessage("How would you rate your sleep quality lately?");
        _showOptions(['Great — 7–9 hrs', 'Decent but inconsistent', 'Pretty bad', 'I barely sleep']);
        break;
      case 6:
        _sleepQuality = answer;
        _step++;
        await _showTyping(800);
        _setMessage("On a scale of feelings — how stressed are you day to day?");
        _showOptions(['Pretty calm', 'Some stress, manageable', 'Consistently stressed', 'Overwhelmed']);
        break;
      case 7:
        _stressLevel = answer;
        _step++;
        await _showTyping(700);
        _setMessage("Are you in a relationship right now?");
        _showOptions(['Yes, happy', 'Yes, it's complicated', 'Single', 'Prefer not to say']);
        break;
      case 8:
        _relationship = answer;
        _step++;
        await _showTyping(800);
        _setMessage("How's your social life? Do you feel connected?");
        _showOptions(['Very connected', 'A few close people', 'Mostly isolated', 'Working on it']);
        break;
      case 9:
        _socialLife = answer;
        _step++;
        await _showTyping(700);
        _setMessage("Do you have any spiritual or mindfulness practice?");
        _showOptions(['Yes, daily', 'Occasionally', 'Not really', 'Open to exploring']);
        break;
      case 10:
        _spiritualPractice = answer;
        _step++;
        await _showTyping(800);
        _setMessage("Are you actively learning something new — a skill, course, or book?");
        _showOptions(['Yes, consistently', 'Here and there', 'Not right now', 'Thinking about it']);
        break;
      case 11:
        _learningHabit = answer;
        _step++;
        await _showTyping(800);
        _setMessage("Last one — what's the one area you most want to work on?");
        _showOptions(['My money & finances', 'My health & energy', 'My goals & future', 'My relationships']);
        break;
      case 12:
        _priority = answer;
        _step++;
        await _showTyping(1200);
        _setMessage("That's everything I need. You've given me a real picture of where you are.");
        await Future.delayed(const Duration(milliseconds: 1400));
        await _showTyping(600);
        _setMessage("I'll guide you from here — one step at a time. No overwhelm. 🙌");
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) setState(() => _surveyComplete = true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06060F),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 0.9,
                  colors: [Color(0xFF0D0D2B), Color(0xFF06060F)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      _buildStatusText(),
                      const SizedBox(height: 28),
                      _buildOrb(),
                      const SizedBox(height: 28),
                      _buildMessageText(),
                      const Spacer(),
                      if (_currentOptions.isNotEmpty && !_surveyComplete)
                        _buildOptions(),
                      const SizedBox(height: 20),
                      _buildBottomBar(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(RouteConstants.lifex.toPath),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white54, size: 18),
          ),
          const Spacer(),
          const Text('Voice chat',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go(RouteConstants.lifex.toPath),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white54, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    final text = _isTyping
        ? 'Chris is thinking...'
        : _currentOptions.isNotEmpty
            ? 'Choose an option below'
            : 'Go ahead, I\'m listening';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey(text),
        style: const TextStyle(
          color: Color(0xFF14B8A6),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOrb() {
    return ChrisHomeFab(size: 130);
  }

  Widget _buildMessageText() {
    if (_isTyping) {
      return _TypingDots(pulse: _pulseCtrl);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Text(
          _currentMessage,
          key: ValueKey(_currentMessage),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: _currentOptions
            .map((opt) => GestureDetector(
                  onTap: () => _onOptionTap(opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: const Color(0xFF14B8A6).withValues(alpha: 0.5),
                          width: 1),
                    ),
                    child: Text(opt,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Chat history icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.12), width: 1),
          ),
          child: const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.white54, size: 19),
        ),
        const SizedBox(width: 28),
        // Mic button — blue, larger
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF3B82F6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 28),
        // Close button
        GestureDetector(
          onTap: () => context.go(RouteConstants.lifex.toPath),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12), width: 1),
            ),
            child: const Icon(Icons.close_rounded,
                color: Colors.white54, size: 19),
          ),
        ),
      ],
    );
  }
}

// ── Typing dots ───────────────────────────────────────────────────────────────

class _TypingDots extends StatelessWidget {
  final Animation<double> pulse;
  const _TypingDots({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final t = (pulse.value + i * 0.28) % 1.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.25 + t * 0.65),
              ),
            );
          }),
        );
      },
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
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _ringCtrls = List.generate(
        7,
        (_) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 1100)));
    _ringAnims = _ringCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _enterCtrl.forward();
    _animateRings();
  }

  List<double> _calculateScores() {
    double fin = 0.5;
    if (widget.moneyRel == 'I save consistently') {
      fin = 0.82;
    } else if (widget.moneyRel == 'I pretty much break even') {
      fin = 0.54;
    } else if (widget.moneyRel == 'I spend most of what I make') {
      fin = 0.36;
    } else {
      fin = 0.44;
    }
    if (widget.debt == 'No debt') {
      fin = (fin + 0.1).clamp(0.0, 1.0);
    } else if (widget.debt == 'Multiple types') {
      fin = (fin - 0.1).clamp(0.0, 1.0);
    }
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
        color: const Color(0xFF06060F).withValues(alpha: 0.97),
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
                      height: 1.5),
                ),
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
                          final progress = _ringAnims[i].value * targetScore;
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
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.55),
                                      fontSize: 9,
                                      height: 1.3)),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: widget.onDone,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('Enter LifeX',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
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

// ── Data classes ──────────────────────────────────────────────────────────────

class _Domain {
  final String name;
  final Color color;
  final IconData icon;
  const _Domain(this.name, this.color, this.icon);
}
