import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

// Chris's voice is synthesized by the same Vercel serverless function that
// serves chat (api/synthesize.js), which holds the ElevenLabs key securely
// server-side. Falls back to on-device TTS if that call fails.
const _kVoiceBase = String.fromEnvironment(
  'CHRIS_VOICE_BASE_URL',
  defaultValue: 'https://chronosapp-nahomp.vercel.app',
);

class TtsService {
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.95);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  /// Speaks [text] aloud and waits until playback finishes.
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await stop();
    final playedRemotely = await _speakElevenLabs(text);
    if (!playedRemotely) {
      await _speakFallback(text);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    await _player.stop();
  }

  Future<void> _speakFallback(String text) async {
    try {
      await _ensureInit();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS fallback error: $e');
    }
  }

  Future<bool> _speakElevenLabs(String text) async {
    try {
      final api = GetIt.instance<ApiClient>();
      final trimmed = text.length > 480 ? text.substring(0, 480) : text;
      final bytes = await api.postBytesWithBase(
        _kVoiceBase,
        '/api/synthesize',
        {'text': trimmed},
      );
      if (bytes.isEmpty) return false;

      final completer = Completer<void>();
      late final StreamSubscription<void> sub;
      sub = _player.onPlayerComplete.listen((_) {
        if (!completer.isCompleted) completer.complete();
        sub.cancel();
      });

      await _player.play(BytesSource(bytes));
      await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {},
      );
      return true;
    } catch (e) {
      debugPrint('ElevenLabs TTS error: $e');
      return false;
    }
  }
}
