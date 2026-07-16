
import 'package:flutter/material.dart';

import '../../../../core/theme/constants.dart';

class OnboardingSlide extends StatelessWidget {
  final String? assetPath;
  final String title;
  final String subtitle;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.subtitle,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dpr = MediaQuery.of(context).devicePixelRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Space.verticalExtraLarge,
          Expanded(
            flex: 6,
            child: Center(
              child: assetPath == null
                  ? const _SlidePlaceholder()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final cacheWidth =
                            (constraints.maxWidth * dpr).round();
                        return SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            assetPath!,
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                            filterQuality: FilterQuality.high,
                            isAntiAlias: true,
                            cacheWidth: cacheWidth > 0 ? cacheWidth : null,
                            errorBuilder: (context, error, stackTrace) {
                              return const _SlidePlaceholder();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2A3443),
                  ),
                ),
                Space.verticalMedium,
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.4,
                    color: const Color(0xFF6B7687),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePlaceholder extends StatelessWidget {
  const _SlidePlaceholder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F8),
          borderRadius: Constants.borderRadiusExtraLarge,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 56,
          color: Color(0xFF9AA6B2),
        ),
      ),
    );
  }
}

