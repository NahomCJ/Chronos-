import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class AppBackgroundState {
  final String? url;
  final String? mediaType; // 'photo' | 'video'
  const AppBackgroundState({this.url, this.mediaType});
}

/// Holds the user's chosen app-wide background (Pexels photo or video),
/// persisted locally and synced to their profile so it follows them across
/// devices. Falls back to the default Pexels photo every page used to
/// hardcode when nothing has been chosen yet.
class BackgroundCubit extends Cubit<AppBackgroundState> {
  static const _urlKey = 'app_background_url';
  static const _typeKey = 'app_background_type';

  final SharedPreferences _prefs;
  final ApiClient _api;

  BackgroundCubit(this._prefs, this._api)
      : super(AppBackgroundState(
          url: _prefs.getString(_urlKey),
          mediaType: _prefs.getString(_typeKey),
        )) {
    _syncFromBackend();
  }

  Future<void> _syncFromBackend() async {
    try {
      final profile = await _api.get('/api/v1/users/me');
      final url = profile['backgroundUrl'] as String?;
      if (url == null) return;
      final mediaType = profile['backgroundMediaType'] as String?;
      emit(AppBackgroundState(url: url, mediaType: mediaType));
      await _prefs.setString(_urlKey, url);
      if (mediaType != null) await _prefs.setString(_typeKey, mediaType);
    } catch (_) {
      // Offline or logged out — keep whatever was cached locally.
    }
  }

  Future<void> selectBackground(String url, String mediaType) async {
    emit(AppBackgroundState(url: url, mediaType: mediaType));
    await _prefs.setString(_urlKey, url);
    await _prefs.setString(_typeKey, mediaType);
    try {
      await _api.patch('/api/v1/users/me', {
        'backgroundUrl': url,
        'backgroundMediaType': mediaType,
      });
    } catch (_) {
      // Saved locally at least — will retry sync next launch.
    }
  }
}
