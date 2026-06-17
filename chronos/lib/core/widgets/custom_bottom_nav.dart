import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/text_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const _activeColor = Colors.white;
  static final _inactiveColor = Colors.white.withValues(alpha: 0.38);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0A14).withValues(alpha: 0.82),
                  const Color(0xFF060610).withValues(alpha: 0.88),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(Icons.home_filled, 'Home', 0),
                _itemImage('assets/lioness 1.png', 'Panther', 1),
                _item(Icons.hub_outlined, 'BlockHub', 2),
                _item(Icons.spa_rounded, 'LifeX', 3),
                _item(Icons.menu, 'More', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final active = selectedIndex == index;
    final color = active ? _activeColor : _inactiveColor;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.only(bottom: 3),
                decoration: const BoxDecoration(
                  color: _activeColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyles.labelSmall.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemImage(String path, String label, int index) {
    final active = selectedIndex == index;
    final color = active ? _activeColor : _inactiveColor;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.only(bottom: 3),
                decoration: const BoxDecoration(
                  color: _activeColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4),
            ColorFiltered(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              child: Image.asset(
                path,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.psychology, color: color, size: 20),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyles.labelSmall.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
