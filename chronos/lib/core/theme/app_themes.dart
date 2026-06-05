import 'package:flutter/material.dart';

class ChronosTheme {
  final String id;
  final String name;
  final String previewImageUrl;
  final Color primaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color accentColor;

  const ChronosTheme({
    required this.id,
    required this.name,
    required this.previewImageUrl,
    required this.primaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.accentColor,
  });
}

class AppThemes {
  static const List<ChronosTheme> all = [
    ChronosTheme(
      id: 'midnight',
      name: 'Midnight',
      previewImageUrl:
          'https://images.pexels.com/photos/1525041/pexels-photo-1525041.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFF6C5CE7),
      backgroundColor: Color(0xFF0A0A14),
      cardColor: Color(0xFF141428),
      accentColor: Color(0xFF6C5CE7),
    ),
    ChronosTheme(
      id: 'ocean',
      name: 'Ocean',
      previewImageUrl:
          'https://images.pexels.com/photos/1032650/pexels-photo-1032650.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFF00B4D8),
      backgroundColor: Color(0xFF050D1A),
      cardColor: Color(0xFF0A1628),
      accentColor: Color(0xFF00B4D8),
    ),
    ChronosTheme(
      id: 'forest',
      name: 'Forest',
      previewImageUrl:
          'https://images.pexels.com/photos/775201/pexels-photo-775201.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFF2D9B4E),
      backgroundColor: Color(0xFF050F08),
      cardColor: Color(0xFF0A1E0E),
      accentColor: Color(0xFF2D9B4E),
    ),
    ChronosTheme(
      id: 'sunset',
      name: 'Sunset',
      previewImageUrl:
          'https://images.pexels.com/photos/1237119/pexels-photo-1237119.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFFE85D04),
      backgroundColor: Color(0xFF140A05),
      cardColor: Color(0xFF1E1008),
      accentColor: Color(0xFFE85D04),
    ),
    ChronosTheme(
      id: 'rose_gold',
      name: 'Rose Gold',
      previewImageUrl:
          'https://images.pexels.com/photos/931177/pexels-photo-931177.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFFE8829A),
      backgroundColor: Color(0xFF14080D),
      cardColor: Color(0xFF1E0D14),
      accentColor: Color(0xFFE8829A),
    ),
    ChronosTheme(
      id: 'arctic',
      name: 'Arctic',
      previewImageUrl:
          'https://images.pexels.com/photos/724994/pexels-photo-724994.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFF48CAE4),
      backgroundColor: Color(0xFF08101A),
      cardColor: Color(0xFF101824),
      accentColor: Color(0xFF48CAE4),
    ),
    ChronosTheme(
      id: 'volcanic',
      name: 'Volcanic',
      previewImageUrl:
          'https://images.pexels.com/photos/1264210/pexels-photo-1264210.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFFFF4500),
      backgroundColor: Color(0xFF140505),
      cardColor: Color(0xFF1E0808),
      accentColor: Color(0xFFFF4500),
    ),
    ChronosTheme(
      id: 'galaxy',
      name: 'Galaxy',
      previewImageUrl:
          'https://images.pexels.com/photos/1169754/pexels-photo-1169754.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFFB388FF),
      backgroundColor: Color(0xFF05050F),
      cardColor: Color(0xFF0A0A1E),
      accentColor: Color(0xFFB388FF),
    ),
    ChronosTheme(
      id: 'neon',
      name: 'Neon',
      previewImageUrl:
          'https://images.pexels.com/photos/1191710/pexels-photo-1191710.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFF39FF14),
      backgroundColor: Color(0xFF050A05),
      cardColor: Color(0xFF0A140A),
      accentColor: Color(0xFF39FF14),
    ),
    ChronosTheme(
      id: 'sand',
      name: 'Sand',
      previewImageUrl:
          'https://images.pexels.com/photos/1770809/pexels-photo-1770809.jpeg?auto=compress&cs=tinysrgb&w=400',
      primaryColor: Color(0xFFD4A853),
      backgroundColor: Color(0xFF14100A),
      cardColor: Color(0xFF1E180E),
      accentColor: Color(0xFFD4A853),
    ),
  ];
}
