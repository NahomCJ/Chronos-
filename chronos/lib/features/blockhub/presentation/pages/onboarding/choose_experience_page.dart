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

  static const _bg = Color(0xFFF7F8FA);
  static const _titleColor = Color(0xFF1A1A2E);
  static const _subtitleColor = Color(0xFF6B7080);
  static const _border = Color(0xFFEEEEEE);

  static const _levels = [
    _Level('beginner', Icons.school_rounded, 'Beginner', 'New to crypto',
        Color(0xFF22C55E)),
    _Level('intermediate', Icons.trending_up_rounded, 'Intermediate',
        'Some experience', Color(0xFF3B82F6)),
    _Level('expert', Icons.auto_graph_rounded, 'Expert', 'Power trader',
        Color(0xFFF59E0B)),
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
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 18),
                    ..._levels.map(_buildLevelRow),
                    const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _border, width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _titleColor, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Experience',
                    style: TextStyle(
                        color: _titleColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const Text('Step 2 of 3',
                    style: TextStyle(color: _subtitleColor, fontSize: 11)),
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
            color: i + 1 == current ? _titleColor : const Color(0xFFDADEE6),
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
                color: _titleColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.1)),
        const SizedBox(height: 8),
        const Text(
          'We\'ll tailor your BlockHub layout and AI guidance to match.',
          style: TextStyle(color: _subtitleColor, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }

  Widget _buildLevelRow(_Level level) {
    final isSelected = _selected == level.id;
    return GestureDetector(
      onTap: () => setState(() => _selected = level.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? level.color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? level.color.withValues(alpha: 0.45) : _border,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: level.color.withValues(alpha: 0.12),
              ),
              child: Icon(level.icon, color: level.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.title,
                      style: const TextStyle(
                          color: _titleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(level.subtitle,
                      style: const TextStyle(
                          color: _subtitleColor, fontSize: 11.5)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? level.color : Colors.transparent,
                border: Border.all(
                    color: isSelected ? level.color : const Color(0xFFD5D8DE),
                    width: 1.5),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final canContinue = _selected != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: GestureDetector(
        onTap: canContinue ? _continue : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: canContinue ? _titleColor : const Color(0xFFE9EBEF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('Continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: canContinue ? Colors.white : _subtitleColor,
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
  final Color color;
  const _Level(this.id, this.icon, this.title, this.subtitle, this.color);
}
