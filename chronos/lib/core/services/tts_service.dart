import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

// Chris's voice is synthesized by the main Chronos Express backend, which
// holds the ElevenLabs key securely server-side. Falls back to on-device
// TTS if that call fails.
class TtsService {
  static final TtsService _instance = TtsService._();
  factory TtsService() => _instance;
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

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
      return bytes.isEmpty ? null : bytes;
    } catch (e) {
      debugPrint('ElevenLabs TTS error: $e');
      return null;
    }
  }

  Future<void> _playBytes(Uint8List bytes, int myGen) async {
    final completer = Completer<void>();
    _activeCompleter = completer;
    final sub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
    try {
      await _player.play(BytesSource(bytes));
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
