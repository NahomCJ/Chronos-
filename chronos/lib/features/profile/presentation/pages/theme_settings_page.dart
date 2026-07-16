import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_themes.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/background_cubit.dart';
import '../../../../core/services/pexels_service.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ChronosTheme>(
      builder: (context, selectedTheme) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A14),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A0A14),
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            title: const Text(
              'Choose Theme',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
          ),
          body: Stack(
              children: [
                Positioned.fill(child: Image.network('https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)))),
                Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.20))),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppThemes.all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final theme = AppThemes.all[index];
                final isSelected = selectedTheme.id == theme.id;
                return _ThemeCard(
                  theme: theme,
                  isSelected: isSelected,
                  onTap: () {
                    context.read<ThemeCubit>().selectTheme(theme);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Theme applied!',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: theme.accentColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(milliseconds: 1500),
                      ),
                    );
                  },
                );
              },
                      ),
                      const SizedBox(height: 28),
                      const _CustomBackgroundSection(),
                    ],
                  ),
                ),
              ],
            ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ChronosTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.accentColor
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.accentColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview image
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: theme.previewImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.cardColor,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.accentColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.cardColor,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: theme.accentColor.withValues(alpha: 0.4),
                          size: 28,
                        ),
                      ),
                    ),
                    // Dark overlay for readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                    // Checkmark overlay
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.accentColor,
                            boxShadow: [
                              BoxShadow(
                                color: theme.accentColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Theme name + accent dot
              Container(
                color: theme.backgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: theme.accentColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        theme.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lets the user search Pexels for a custom photo or video and apply it as
/// the background across the whole app (via [BackgroundCubit]), instead of
/// being limited to the fixed theme presets above.
class _CustomBackgroundSection extends StatefulWidget {
  const _CustomBackgroundSection();

  @override
  State<_CustomBackgroundSection> createState() => _CustomBackgroundSectionState();
}

class _CustomBackgroundSectionState extends State<_CustomBackgroundSection> {
  final _searchCtrl = TextEditingController();
  bool _searchingVideos = false;
  bool _loading = false;
  List<PexelsPhoto> _photos = [];
  List<PexelsVideo> _videos = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() => _loading = true);
    if (_searchingVideos) {
      final results = await PexelsService.searchVideos(query, perPage: 8);
      if (mounted) setState(() { _videos = results; _photos = []; _loading = false; });
    } else {
      final results = await PexelsService.searchPhotos(query, perPage: 12);
      if (mounted) setState(() { _photos = results; _videos = []; _loading = false; });
    }
  }

  void _apply(String url, String mediaType) {
    context.read<BackgroundCubit>().selectBackground(url, mediaType);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Background applied across the app!', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Custom Background',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Search Pexels for a photo or video and set it as your background everywhere.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12.5)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: (_) => _search(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. mountains, city night, ocean',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _search,
              icon: const Icon(Icons.search_rounded, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ChoiceChip(
              label: const Text('Photos'),
              selected: !_searchingVideos,
              onSelected: (_) => setState(() => _searchingVideos = false),
              selectedColor: Colors.white.withValues(alpha: 0.2),
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Videos'),
              selected: _searchingVideos,
              onSelected: (_) => setState(() => _searchingVideos = true),
              selectedColor: Colors.white.withValues(alpha: 0.2),
              labelStyle: const TextStyle(color: Colors.white),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white))),
        if (!_loading && _photos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (_, i) {
              final photo = _photos[i];
              return GestureDetector(
                onTap: () => _apply(photo.large, 'photo'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(imageUrl: photo.medium, fit: BoxFit.cover),
                ),
              );
            },
          ),
        if (!_loading && _videos.isNotEmpty)
          ..._videos.map((video) {
            final url = video.portraitHdUrl ?? video.sdUrl;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: url == null ? null : () => _apply(url, 'video'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(imageUrl: video.image, height: 140, width: double.infinity, fit: BoxFit.cover),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
