import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import '../network/api_client.dart';

// Chris's voice is synthesized by Chronos-Backend-'s own ElevenLabs-backed
// POST /api/ai/voice/synthesize (auth'd via the stored JWT, see ApiClient),
// not the Vercel/Groq stand-in used between Bug #18 and this fix — reuses
// ApiClient's own baseUrl (API_BASE_URL dart-define) so voice always points
// at the same backend as the rest of the app, DeepSeek/ElevenLabs included.
// Falls back to on-device TTS if the call fails.
class TtsService {
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  // The premium (ElevenLabs) voice failing used to be invisible — any error
  // silently downgraded to the on-device fallback with only a debugPrint.
  // Callers (e.g. ChrisHomeFab) can set this to surface the real reason.
  String? lastError;
  void Function(String message)? onError;

  // Bumped on every stop() so any in-flight speak() sequence abandons
  // itself instead of playing a sentence that's no longer relevant —
  // this is what makes interrupting Chris mid-sentence possible.
  int _generation = 0;
  bool _isSpeaking = false;
  Completer<void>? _activeCompleter;

  bool get isSpeaking => _isSpeaking;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.95);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  /// Speaks [text] aloud, sentence by sentence — the next sentence's audio
  /// is fetched from ElevenLabs while the current one is still playing, so
  /// a long reply doesn't sit in dead air waiting for the whole thing to
  /// synthesize first. Waits until all speech finishes, or until [stop] is
  /// called from elsewhere (e.g. the user interrupting).
  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await stop();
    final myGen = ++_generation;
    _isSpeaking = true;
    try {
      final sentences = _splitSentences(trimmed);
      Future<Uint8List?>? nextFetch = _fetchAudio(sentences.first);
      for (var i = 0; i < sentences.length; i++) {
        if (myGen != _generation) return;
        final bytes = await nextFetch;
        nextFetch = (i + 1 < sentences.length)
            ? _fetchAudio(sentences[i + 1])
            : null;
        if (myGen != _generation) return;
        if (bytes != null && bytes.isNotEmpty) {
          await _playBytes(bytes, myGen);
        } else {
          await _speakFallback(sentences[i], myGen);
        }
      }
    } finally {
      if (myGen == _generation) _isSpeaking = false;
    }
  }

  /// Interrupts anything currently speaking or queued to speak.
  Future<void> stop() async {
    _generation++;
    _isSpeaking = false;
    _activeCompleter?.complete();
    _activeCompleter = null;
    await _tts.stop();
    await _player.stop();
  }

  List<String> _splitSentences(String text) {
    final matches = RegExp(r'[^.!?\n]+[.!?\n]*').allMatches(text);
    final parts = matches
        .map((m) => m.group(0)!.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.isEmpty ? [text] : parts;
  }

  Future<void> _speakFallback(String text, int myGen) async {
    try {
      await _ensureInit();
      if (myGen != _generation) return;
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS fallback error: $e');
    }
  }

  Future<Uint8List?> _fetchAudio(String text) async {
    try {
      final api = GetIt.instance<ApiClient>();
      final trimmed = text.length > 480 ? text.substring(0, 480) : text;
      final bytes = await api.postBytesWithBase(
        api.baseUrl,
        '/api/ai/voice/synthesize',
        {'text': trimmed},
      );
      if (bytes.isEmpty) {
        _reportError('Voice synthesis returned an empty response.');
        return null;
      }
      return bytes;
    } catch (e) {
      _reportError(e.toString());
      return null;
    }
  }

  void _reportError(String message) {
    lastError = message;
    debugPrint('Chris voice synthesis error: $message');
    onError?.call(message);
  }

  Future<void> _playBytes(Uint8List bytes, int myGen) async {
    final completer = Completer<void>();
    _activeCompleter = completer;
    final sub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
    try {
      // iOS AVPlayer fails on BytesSource for MP3; write to a temp file and
      // play the file URL instead. Android tolerates BytesSource, but going
      // through DeviceFileSource on both keeps behavior consistent.
      final tmp = await getTemporaryDirectory();
      final file = File('${tmp.path}/chris_${DateTime.now().microsecondsSinceEpoch}.mp3');
      await file.writeAsBytes(bytes, flush: true);
      if (myGen != _generation) return;
      await _player.play(DeviceFileSource(file.path));
      await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {},
      );
      // Best-effort cleanup — a missed delete just leaves a small mp3 in
      // the sandboxed tmp dir that iOS/Android will purge on its own.
      try { await file.delete(); } catch (_) {}
    } finally {
      await sub.cancel();
      if (identical(_activeCompleter, completer)) _activeCompleter = null;
    }
  }
}
