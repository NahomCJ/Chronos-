import 'dart:convert';
import 'package:http/http.dart' as http;

class PexelsPhoto {
  final int id;
  final String photographer;
  final String medium;
  final String large;
  final String tiny;

  const PexelsPhoto({
    required this.id,
    required this.photographer,
    required this.medium,
    required this.large,
    required this.tiny,
  });

  factory PexelsPhoto.fromJson(Map<String, dynamic> j) => PexelsPhoto(
        id: j['id'] as int,
        photographer: j['photographer'] as String? ?? '',
        medium: (j['src'] as Map)['medium'] as String? ?? '',
        large: (j['src'] as Map)['large'] as String? ?? '',
        tiny: (j['src'] as Map)['tiny'] as String? ?? '',
      );
}

class PexelsVideo {
  final int id;
  final String url;
  final String image;
  final int duration;
  final List<PexelsVideoFile> videoFiles;

  const PexelsVideo({
    required this.id,
    required this.url,
    required this.image,
    required this.duration,
    required this.videoFiles,
  });

  String? get sdUrl {
    for (final f in videoFiles) {
      if (f.quality == 'sd') return f.link;
    }
    return videoFiles.isNotEmpty ? videoFiles.first.link : null;
  }

  /// Best portrait (height > width) HD mp4, falling back to any mp4.
  String? get portraitHdUrl {
    final portrait = videoFiles.where((f) => f.isPortrait && f.quality == 'hd' && f.fileType.contains('mp4')).toList();
    if (portrait.isNotEmpty) return portrait.first.link;
    final anyMp4 = videoFiles.where((f) => f.fileType.contains('mp4')).toList();
    return anyMp4.isNotEmpty ? anyMp4.first.link : null;
  }

  factory PexelsVideo.fromJson(Map<String, dynamic> j) => PexelsVideo(
        id: j['id'] as int,
        url: j['url'] as String? ?? '',
        image: j['image'] as String? ?? '',
        duration: j['duration'] as int? ?? 0,
        videoFiles: ((j['video_files'] as List?) ?? [])
            .map((f) => PexelsVideoFile.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}

class PexelsVideoFile {
  final String link;
  final String quality;
  final String fileType;
  final int width;
  final int height;

  const PexelsVideoFile({
    required this.link,
    required this.quality,
    required this.fileType,
    required this.width,
    required this.height,
  });

  bool get isPortrait => height > width;

  factory PexelsVideoFile.fromJson(Map<String, dynamic> j) => PexelsVideoFile(
        link: j['link'] as String? ?? '',
        quality: j['quality'] as String? ?? '',
        fileType: j['file_type'] as String? ?? '',
        width: (j['width'] as num?)?.toInt() ?? 0,
        height: (j['height'] as num?)?.toInt() ?? 0,
      );
}

// Proxied through the Vercel deployment's serverless function (api/pexels.js),
// which holds the Pexels key as a Vercel env var (`PEXELS_API_KEY`) — same
// reasoning as `_kChrisChatBase`/`_kVoiceBase` elsewhere in this app: keeps
// the key server-side instead of shipping it inside the client binary.
const _kPexelsBase = String.fromEnvironment(
  'PEXELS_BASE_URL',
  defaultValue: 'https://chronosapp-rosy.vercel.app',
);

class PexelsService {
  // ── CDN helpers (public, no auth needed) ─────────────────────────────────
  static String photoUrl(int id, {int w = 600, int h = 400}) =>
      'https://images.pexels.com/photos/$id/pexels-photo-$id.jpeg'
      '?auto=compress&cs=tinysrgb&w=$w&h=$h&fit=crop';

  // ── Photos ────────────────────────────────────────────────────────────────
  static Future<List<PexelsPhoto>> searchPhotos(
    String query, {
    int perPage = 10,
    String orientation = 'landscape',
  }) async {
    try {
      final uri = Uri.parse('$_kPexelsBase/api/pexels').replace(queryParameters: {
        'type': 'photos',
        'query': query,
        'per_page': '$perPage',
        if (orientation.isNotEmpty) 'orientation': orientation,
      });
      final res = await http.get(uri);
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return ((data['photos'] as List?) ?? [])
          .map((p) => PexelsPhoto.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Videos ────────────────────────────────────────────────────────────────
  static Future<List<PexelsVideo>> searchVideos(
    String query, {
    int perPage = 5,
    String orientation = '',
  }) async {
    try {
      final uri = Uri.parse('$_kPexelsBase/api/pexels').replace(queryParameters: {
        'type': 'videos',
        'query': query,
        'per_page': '$perPage',
        if (orientation.isNotEmpty) 'orientation': orientation,
      });
      final res = await http.get(uri);
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return ((data['videos'] as List?) ?? [])
          .map((v) => PexelsVideo.fromJson(v as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
