import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setup_wallet_page.dart';

class ChooseExperiencePage extends StatefulWidget {
  const ChooseExperiencePage({super.key});

  @override
  State<ChooseExperiencePage> createState() => _ChooseExperiencePageState();
}

class _ChooseExperiencePageState extends State<ChooseExperiencePage> {
  String? _selected;

  static const _bg = Color(0xFF06060E);
  static const _card = Color(0xFF0F0F1C);
  static const _amber = Color(0xFF3B3B3B);

  static const _levels = [
    _Level(
      'beginner',
      Icons.school_rounded,
      'Beginner',
      'New to crypto',
      'Just starting out with digital assets. I want guided tutorials and simple explanations.',
      Color(0xFF22C55E),
      [
        'Step-by-step tutorials',
        'Simplified market data',
        'Risk warnings & tips',
        'Beginner-safe defaults',
      ],
    ),
    _Level(
      'intermediate',
      Icons.trending_up_rounded,
      'Intermediate',
      'Some experience',
      'I\'ve bought and traded crypto before. Ready for more tools and deeper insights.',
      Color(0xFF3B82F6),
      [
        'Advanced charts',
        'Portfolio analytics',
        'AI market signals',
        'Multi-chain support',
      ],
    ),
    _Level(
      'expert',
      Icons.auto_graph_rounded,
      'Expert',
      'Power trader',
      'I\'m experienced with DeFi, NFTs and on-chain data. I want full control.',
      Color(0xFFF59E0B),
      [
        'Full trading terminal',
        'DeFi & yield tools',
        'On-chain analytics',
        'NFT mint & trade',
      ],
    ),
  ];

  Future<void> _continue() async {
    if (_selected == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('blockhub_experience_level', _selected!);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetupWalletPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 24),
                    ..._levels.map((l) => _buildLevelCard(l)),
                    const SizedBox(height: 24),
                    if (_selected == 'beginner') _buildBeginnerGuide(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Experience',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Step 2 of 3',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11)),
              ],
            ),
          ),
          _stepDots(2),
        ],
      ),
    );
  }

  Widget _stepDots(int current) {
    return Row(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(left: 5),
          width: i + 1 == current ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i + 1 == current
                ? const Color(0xFFE5E5E5)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose your\nlevel.',
            style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.1)),
        const SizedBox(height: 10),
        Text(
          'We\'ll customize your BlockHub experience, layout and AI guidance to match your skill level.',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLevelCard(_Level level) {
    final isSelected = _selected == level.id;
    return GestureDetector(
      onTap: () => setState(() => _selected = level.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? level.color.withValues(alpha: 0.08)
              : _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? level.color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.07),
            width: isSelected ? 1.5 : 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: level.color.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: level.color.withValues(alpha: 0.12),
                  ),
                  child: Icon(level.icon, color: level.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(level.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(level.subtitle,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12)),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? level.color
                        : Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                        color: isSelected
                            ? level.color
                            : Colors.white.withValues(alpha: 0.2),
                        width: 1.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12)
                      : null,
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 14),
              Text(level.description,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      height: 1.5)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: level.features
                    .map((f) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: level.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(f,
                              style: TextStyle(
                                  color: level.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBeginnerGuide() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF22C55E).withValues(alpha: 0.2), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded,
                  color: Color(0xFF22C55E), size: 16),
              const SizedBox(width: 8),
              const Text('Beginner Roadmap',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          _roadmapStep('1', 'Connect your wallet', 'Secure setup in minutes',
              true),
          _roadmapStep('2', 'Buy your first crypto',
              'Start with \$10 — no pressure', false),
          _roadmapStep(
              '3', 'Track your portfolio', 'Watch it grow in real-time', false),
          _roadmapStep('4', 'Explore NFTs',
              'Discover digital art & collectibles', false),
        ],
      ),
    );
  }

  Widget _roadmapStep(
      String num, String title, String sub, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text(sub,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final canContinue = _selected != null;
    final color = _selected != null
        ? const Color(0xFF1A1A2E)
        : _amber;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: GestureDetector(
        onTap: canContinue ? _continue : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: canContinue ? color : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            boxShadow: canContinue
                ? [
                    BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Text('Continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: canContinue
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _Level {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final List<String> features;
  const _Level(this.id, this.icon, this.title, this.subtitle, this.description,
      this.color, this.features);
}
