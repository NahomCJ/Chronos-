import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../theme/background_cubit.dart';

const kDefaultAppBackgroundUrl =
    'https://images.pexels.com/photos/30004067/pexels-photo-30004067.jpeg?auto=compress&cs=tinysrgb&w=900';

/// Drop-in replacement for the `Stack([Image.network(...), dark overlay,
/// child])` pattern that used to be hardcoded on most pages. Reads the
/// user's chosen background (photo or video) from [BackgroundCubit] so
/// changing it in Theme Settings applies here automatically.
class AppBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;

  const AppBackground({super.key, required this.child, this.overlayOpacity = 0.20});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundCubit, AppBackgroundState>(
      builder: (context, state) {
        final url = state.url ?? kDefaultAppBackgroundUrl;
        final isVideo = state.mediaType == 'video' && !kIsWeb;
        return Stack(
          fit: StackFit.expand,
          children: [
            isVideo
                ? _VideoBackground(url: url)
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A2A3A)),
                  ),
            Container(color: Colors.black.withValues(alpha: overlayOpacity)),
            child,
          ],
        );
      },
    );
  }
}

class _VideoBackground extends StatefulWidget {
  final String url;
  const _VideoBackground({required this.url});

  @override
  State<_VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<_VideoBackground> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      setState(() {});
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: const Color(0xFF1A2A3A));
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
