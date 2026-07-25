import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

// Chris's voice is synthesized by the Vercel deployment's serverless
// function (api/synthesize.js), which holds the ElevenLabs key as a Vercel
// env var — same reasoning as ChrisChatBase in
// panther_ai_remote_data_source.dart: this is the environment actually
// being run/controlled, not the EB Express backend's (also-live)
// /api/ai/voice/synthesize. Falls back to on-device TTS if the call fails.
const _kVoiceBase = String.fromEnvironment(
  'CHRIS_VOICE_BASE_URL',
  defaultValue: 'https://chronosapp-rosy.vercel.app',
);

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
      Future<({Uint8List bytes, String? mimeType})?>? nextFetch =
          _fetchAudio(sentences.first);
      for (var i = 0; i < sentences.length; i++) {
        if (myGen != _generation) return;
        final audio = await nextFetch;
        nextFetch = (i + 1 < sentences.length)
            ? _fetchAudio(sentences[i + 1])
            : null;
        if (myGen != _generation) return;
        if (audio != null && audio.bytes.isNotEmpty) {
          await _playBytes(audio.bytes, myGen, mimeType: audio.mimeType);
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

  Future<({Uint8List bytes, String? mimeType})?> _fetchAudio(String text) async {
    try {
      final api = GetIt.instance<ApiClient>();
      final trimmed = text.length > 480 ? text.substring(0, 480) : text;
      final audio = await api.postBytesWithBase(
        _kVoiceBase,
        '/api/synthesize',
        {'text': trimmed},
      );
      if (audio.bytes.isEmpty) {
        _reportError('Voice synthesis returned an empty response.');
        return null;
      }
      return (bytes: audio.bytes, mimeType: audio.contentType);
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

  Future<void> _playBytes(
    Uint8List bytes,
    int myGen, {
    String? mimeType,
  }) async {
    final completer = Completer<void>();
    _activeCompleter = completer;
    final sub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
    try {
      await _player.play(
        BytesSource(bytes, mimeType: mimeType ?? 'audio/mpeg'),
      );
      await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {},
      );
    } finally {
      await sub.cancel();
      if (identical(_activeCompleter, completer)) _activeCompleter = null;
    }
  }
}
