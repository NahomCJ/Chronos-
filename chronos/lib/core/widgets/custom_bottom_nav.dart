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

  static const _amber = Color(0xFFDC8F4A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              // Apple-style frosted glass — dark tinted
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2A2A3E).withValues(alpha: 0.82),
                  const Color(0xFF1A1A2E).withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  blurRadius: 32,
                  offset: const Offset(0, 10),
                ),
                // Inner top highlight — key to Apple glass look
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.06),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(Icons.home_filled, 'Home', 0),
                _itemImage('assets/lioness 1.png', 'Panther', 1),
                _item(Icons.hub_outlined, 'BlockHub', 2),
                _item(Icons.close, 'LifeX', 3),
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
    final color = active ? _amber : Colors.white.withValues(alpha: 0.55);
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: const BoxDecoration(
                  color: _amber,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
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
    final color = active ? _amber : Colors.white.withValues(alpha: 0.55);
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: const BoxDecoration(
                  color: _amber,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
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
